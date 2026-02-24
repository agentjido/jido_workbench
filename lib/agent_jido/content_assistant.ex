defmodule AgentJido.ContentAssistant do
  @moduledoc """
  Unified content assistant API for retrieval-grounded responses with optional LLM enhancement.
  """

  require Logger

  alias AgentJido.ContentAssistant.LinkPolicy
  alias AgentJido.ContentAssistant.Response
  alias AgentJido.ContentAssistant.Result
  alias AgentJido.ContentAssistant.Retrieval
  alias AgentJido.ContentAssistant.Turnstile
  alias AgentJido.ContentAssistant.URL

  @default_temperature 0.1
  @default_citation_limit 6
  @default_query_max_length 500
  @default_assistant_timeout_ms 12_000
  @default_link_source "content_assistant"
  @max_reference_snippet 240
  @fallback_snippet "Open this reference for full context."

  @type llm_budget_result :: :ok | {:error, term()}

  @doc """
  Responds to a content query with deterministic citations and optional LLM enhancement.

  This function always returns `{:ok, Response.t()}` and degrades to deterministic output
  whenever LLM enhancement is unavailable or blocked.
  """
  @spec respond(String.t(), keyword()) :: {:ok, Response.t()}
  def respond(query, opts \\ [])

  def respond(query, opts) when is_binary(query) and is_list(opts) do
    normalized_query = normalize_query(query, query_max_length(opts))

    cond do
      normalized_query == "" ->
        {:ok,
         build_response(normalized_query,
           answer_markdown: "",
           answer_mode: :no_results,
           citations: [],
           related_queries: [],
           retrieval_status: :success,
           llm_attempted?: false,
           llm_enhanced?: false,
           enhancement_blocked_reason: nil,
           link_source: @default_link_source,
           link_channel: link_channel(opts),
           query_log_id: Keyword.get(opts, :query_log_id)
         )}

      true ->
        do_respond(normalized_query, opts)
    end
  end

  def respond(_query, opts), do: respond("", opts)

  defp do_respond(query, opts) do
    with {:ok, citations, retrieval_status} <- run_retrieval(query, opts) do
      query_log_id = Keyword.get(opts, :query_log_id)

      if citations == [] do
        {:ok,
         build_response(query,
           answer_markdown: "",
           answer_mode: :no_results,
           citations: [],
           related_queries: related_queries(query, opts),
           retrieval_status: retrieval_status,
           llm_attempted?: false,
           llm_enhanced?: false,
           enhancement_blocked_reason: nil,
           link_source: @default_link_source,
           link_channel: link_channel(opts),
           query_log_id: query_log_id
         )}
      else
        deterministic_answer = deterministic_summary(query, citations)

        case llm_enhancement_state(query, citations, opts) do
          {:blocked, reason} ->
            {:ok,
             build_response(query,
               answer_markdown: deterministic_answer,
               answer_mode: :deterministic,
               citations: citations,
               related_queries: [],
               retrieval_status: retrieval_status,
               llm_attempted?: false,
               llm_enhanced?: false,
               enhancement_blocked_reason: reason,
               link_source: @default_link_source,
               link_channel: link_channel(opts),
               query_log_id: query_log_id
             )}

          {:ready, llm} ->
            llm_opts =
              opts
              |> Keyword.get(:llm_opts, [])
              |> Keyword.put_new(:temperature, @default_temperature)
              |> Keyword.put_new(:system_prompt, llm_system_prompt())

            llm_complete_fun = Keyword.get(opts, :llm_complete_fun, &Arcana.LLM.complete/4)
            timeout_ms = assistant_timeout_ms(opts)

            case safe_llm_complete(llm_complete_fun, llm, llm_prompt(query, citations), llm_opts, timeout_ms) do
              {:ok, llm_answer} ->
                normalized_answer = normalize_llm_answer(llm_answer)

                if normalized_answer == "" do
                  {:ok,
                   build_response(query,
                     answer_markdown: deterministic_answer,
                     answer_mode: :deterministic_fallback,
                     citations: citations,
                     related_queries: [],
                     retrieval_status: retrieval_status,
                     llm_attempted?: true,
                     llm_enhanced?: false,
                     enhancement_blocked_reason: nil,
                     link_source: @default_link_source,
                     link_channel: link_channel(opts),
                     query_log_id: query_log_id
                   )}
                else
                  {:ok,
                   build_response(query,
                     answer_markdown: normalized_answer,
                     answer_mode: :llm,
                     citations: citations,
                     related_queries: [],
                     retrieval_status: retrieval_status,
                     llm_attempted?: true,
                     llm_enhanced?: true,
                     enhancement_blocked_reason: nil,
                     link_source: @default_link_source,
                     link_channel: link_channel(opts),
                     query_log_id: query_log_id
                   )}
                end

              {:error, reason} ->
                Logger.warning("ContentAssistant LLM enhancement failed: #{inspect(reason)}")

                mode = if quota_error?(reason), do: :quota_fallback, else: :deterministic_fallback

                {:ok,
                 build_response(query,
                   answer_markdown: deterministic_answer,
                   answer_mode: mode,
                   citations: citations,
                   related_queries: [],
                   retrieval_status: retrieval_status,
                   llm_attempted?: true,
                   llm_enhanced?: false,
                   enhancement_blocked_reason: nil,
                   link_source: @default_link_source,
                   link_channel: link_channel(opts),
                   query_log_id: query_log_id
                 )}
            end
        end
      end
    else
      _error ->
        {:ok,
         build_response(query,
           answer_markdown: "",
           answer_mode: :error,
           citations: [],
           related_queries: [],
           retrieval_status: :failure,
           llm_attempted?: false,
           llm_enhanced?: false,
           enhancement_blocked_reason: nil,
           link_source: @default_link_source,
           link_channel: link_channel(opts),
           query_log_id: Keyword.get(opts, :query_log_id)
         )}
    end
  rescue
    error ->
      Logger.warning("ContentAssistant failed to respond: #{Exception.message(error)}")

      {:ok,
       build_response(query,
         answer_markdown: "",
         answer_mode: :error,
         citations: [],
         related_queries: [],
         retrieval_status: :failure,
         llm_attempted?: false,
         llm_enhanced?: false,
         enhancement_blocked_reason: nil,
         link_source: @default_link_source,
         link_channel: link_channel(opts),
         query_log_id: Keyword.get(opts, :query_log_id)
       )}
  end

  defp run_retrieval(query, opts) do
    retrieval_module = Keyword.get(opts, :retrieval_module, retrieval_module())
    retrieval_opts = Keyword.get(opts, :retrieval_opts, [])
    citation_limit = Keyword.get(opts, :citation_limit, @default_citation_limit)

    response =
      cond do
        function_exported?(retrieval_module, :query_with_status, 2) ->
          retrieval_module.query_with_status(query, retrieval_opts)

        function_exported?(retrieval_module, :query, 2) ->
          retrieval_module.query(query, retrieval_opts)

        true ->
          {:error, :invalid_retrieval_module}
      end

    case response do
      {:ok, results, status} when is_list(results) ->
        {:ok, normalize_results(results, citation_limit), normalize_retrieval_status(status)}

      {:ok, results} when is_list(results) ->
        {:ok, normalize_results(results, citation_limit), :success}

      _other ->
        {:error, :retrieval_failed}
    end
  rescue
    _ -> {:error, :retrieval_failed}
  end

  defp llm_enhancement_state(query, citations, opts) do
    llm = Keyword.get(opts, :llm, Application.get_env(:arcana, :llm))

    cond do
      is_nil(llm) ->
        {:blocked, :llm_unconfigured}

      llm_budget_blocked?(query, citations, opts) ->
        {:blocked, :budget}

      turnstile_blocked?(opts) ->
        {:blocked, :turnstile}

      true ->
        {:ready, llm}
    end
  end

  defp llm_budget_blocked?(query, citations, opts) do
    budget_module =
      Keyword.get_lazy(opts, :llm_budget_module, fn ->
        content_assistant_cfg()
        |> config_value(:llm_budget_module)
      end)

    context = %{
      query: query,
      citations: citations,
      citation_count: length(citations),
      surface: Keyword.get(opts, :surface),
      metadata: Keyword.get(opts, :metadata, %{})
    }

    case allow_llm?(budget_module, context) do
      :ok -> false
      {:error, _reason} -> true
    end
  end

  defp allow_llm?(nil, _context), do: :ok

  defp allow_llm?(module, context) when is_atom(module) do
    cond do
      function_exported?(module, :allow_llm?, 1) ->
        module.allow_llm?(context)

      true ->
        {:error, :invalid_budget_module}
    end
  rescue
    _ -> {:error, :budget_guard_failed}
  end

  defp allow_llm?(_module, _context), do: {:error, :invalid_budget_module}

  defp safe_llm_complete(llm_complete_fun, llm, prompt, llm_opts, timeout_ms)
       when is_function(llm_complete_fun, 4) do
    timeout = normalize_assistant_timeout(timeout_ms)
    task_supervisor = task_supervisor(llm_opts)

    task =
      Task.Supervisor.async_nolink(task_supervisor, fn ->
        llm_complete_fun.(llm, prompt, [], llm_opts)
      end)

    case Task.yield(task, timeout) || Task.shutdown(task, :brutal_kill) do
      {:ok, {:ok, _answer} = ok} ->
        ok

      {:ok, {:error, _reason} = error} ->
        error

      {:ok, other} ->
        {:error, {:unexpected_llm_response, other}}

      nil ->
        {:error, :timeout}
    end
  rescue
    error ->
      {:error, {:exception, error.__struct__, Exception.message(error)}}
  catch
    kind, reason ->
      {:error, {:caught, kind, reason}}
  end

  defp safe_llm_complete(_llm_complete_fun, _llm, _prompt, _llm_opts, _timeout_ms), do: {:error, :invalid_llm_complete_fun}

  defp turnstile_blocked?(opts) do
    require_turnstile =
      case Keyword.get(opts, :require_turnstile) do
        value when is_boolean(value) -> value
        _ -> require_turnstile?()
      end

    if require_turnstile do
      token = Keyword.get(opts, :turnstile_token)
      remote_ip = Keyword.get(opts, :remote_ip)

      verifier =
        Keyword.get(
          opts,
          :turnstile_module,
          Application.get_env(:agent_jido, :content_assistant_turnstile_module, Turnstile)
        )

      case verifier.verify(token, remote_ip) do
        :ok -> false
        {:error, _reason} -> true
      end
    else
      false
    end
  rescue
    _ -> true
  end

  defp require_turnstile? do
    content_assistant_cfg()
    |> config_value(:require_turnstile, false)
    |> truthy?()
  end

  defp normalize_results(results, limit) when is_list(results) do
    limit = normalize_limit(limit, @default_citation_limit)

    results
    |> Enum.map(&normalize_result/1)
    |> Enum.reject(&is_nil/1)
    |> dedupe_results()
    |> Enum.take(limit)
  end

  defp normalize_results(_results, _limit), do: []

  defp normalize_result(%Result{} = result) do
    with url when is_binary(url) <- URL.normalize_href(result.url) do
      %Result{
        result
        | url: url,
          snippet: normalize_snippet(result.snippet)
      }
    else
      _ -> nil
    end
  end

  defp normalize_result(%{title: title, snippet: snippet, url: url, source_type: source_type} = map)
       when is_binary(title) and is_binary(snippet) and is_binary(url) do
    with normalized_url when is_binary(normalized_url) <- URL.normalize_href(url) do
      %Result{
        title: String.trim(title),
        snippet: normalize_snippet(snippet),
        url: normalized_url,
        source_type: normalize_source_type(source_type),
        score: Map.get(map, :score) || Map.get(map, "score")
      }
    else
      _ -> nil
    end
  end

  defp normalize_result(_result), do: nil

  defp normalize_source_type(source_type) when source_type in [:docs, :blog, :ecosystem], do: source_type

  defp normalize_source_type(source_type) when is_binary(source_type) do
    case String.downcase(String.trim(source_type)) do
      "docs" -> :docs
      "documentation" -> :docs
      "blog" -> :blog
      "ecosystem" -> :ecosystem
      _ -> :docs
    end
  end

  defp normalize_source_type(_source_type), do: :docs

  defp normalize_retrieval_status(:success), do: :success
  defp normalize_retrieval_status(:fallback), do: :fallback
  defp normalize_retrieval_status(_status), do: :success

  defp normalize_limit(limit, _default) when is_integer(limit) and limit > 0, do: limit
  defp normalize_limit(_limit, default), do: default

  defp dedupe_results(results) when is_list(results) do
    results
    |> Enum.reduce(%{}, fn
      %Result{url: url, score: score} = result, acc ->
        case Map.get(acc, url) do
          nil ->
            Map.put(acc, url, result)

          %Result{score: existing_score} = existing ->
            if score_value(score) > score_value(existing_score) do
              Map.put(acc, url, result)
            else
              Map.put(acc, url, existing)
            end
        end

      _, acc ->
        acc
    end)
    |> Map.values()
    |> Enum.sort_by(fn %Result{score: score} -> score_value(score) end, :desc)
  end

  defp dedupe_results(_results), do: []

  defp score_value(score) when is_number(score), do: score * 1.0
  defp score_value(_score), do: 0.0

  defp normalize_snippet(snippet) when is_binary(snippet) do
    snippet
    |> String.replace(~r/\s+/u, " ")
    |> String.trim()
    |> case do
      "" ->
        @fallback_snippet

      cleaned ->
        if Regex.match?(~r{^/[^\s]*$}, cleaned) do
          @fallback_snippet
        else
          truncate_line(cleaned, 320)
        end
    end
  end

  defp normalize_snippet(_snippet), do: @fallback_snippet

  defp build_response(query, attrs) when is_binary(query) and is_list(attrs) do
    markdown = Keyword.get(attrs, :answer_markdown, "")
    citations = Keyword.fetch!(attrs, :citations)
    link_source = Keyword.get(attrs, :link_source, @default_link_source)
    link_channel = Keyword.get(attrs, :link_channel, "content_assistant")

    html =
      markdown
      |> markdown_to_html()
      |> LinkPolicy.apply(citations, source: link_source, channel: link_channel)

    %Response{
      query: query,
      answer_markdown: markdown,
      answer_html: html,
      answer_mode: Keyword.fetch!(attrs, :answer_mode),
      citations: citations,
      related_queries: normalize_related_queries(Keyword.get(attrs, :related_queries, [])),
      retrieval_status: Keyword.fetch!(attrs, :retrieval_status),
      llm_attempted?: Keyword.fetch!(attrs, :llm_attempted?),
      llm_enhanced?: Keyword.fetch!(attrs, :llm_enhanced?),
      enhancement_blocked_reason: Keyword.fetch!(attrs, :enhancement_blocked_reason),
      query_log_id: Keyword.get(attrs, :query_log_id)
    }
  end

  defp markdown_to_html(markdown) when is_binary(markdown) do
    case MDEx.to_html(markdown) do
      {:ok, html} ->
        html

      {:error, _reason} ->
        markdown
        |> Phoenix.HTML.html_escape()
        |> Phoenix.HTML.safe_to_string()
    end
  end

  defp markdown_to_html(_markdown), do: ""

  @spec llm_system_prompt() :: String.t()
  defp llm_system_prompt do
    """
    You are AgentJido's documentation assistant.
    Answer using only the provided references.

    Rules:
    - Do not invent APIs, features, routes, links, or package names.
    - If the references are insufficient, say what is missing.
    - Keep the answer concise (about 120-180 words).
    - Use markdown. Do not wrap the answer in code fences.
    """
  end

  @spec llm_prompt(String.t(), [Result.t()]) :: String.t()
  defp llm_prompt(query, citations) do
    references =
      citations
      |> Enum.with_index(1)
      |> Enum.map_join("\n\n", fn {citation, index} ->
        source = source_label(citation.source_type)
        snippet = citation.snippet |> String.trim() |> truncate_line(@max_reference_snippet)

        """
        [#{index}] Source: #{source}
        Title: #{citation.title}
        URL: #{citation.url}
        Snippet: #{snippet}
        """
      end)

    """
    User question:
    #{query}

    References:
    #{references}

    Write a grounded answer that synthesizes the references.
    """
  end

  @spec deterministic_summary(String.t(), [Result.t()]) :: String.t()
  defp deterministic_summary(query, citations) do
    bullets =
      citations
      |> Enum.take(3)
      |> Enum.map(fn citation ->
        source = source_label(citation.source_type)
        summary = citation.snippet |> String.trim() |> truncate_line(180)
        "- [#{source}] [#{citation.title}](#{citation.url}): #{summary}"
      end)
      |> Enum.join("\n")

    [
      "I searched the site content for \"#{query}\" and found these relevant references:",
      "",
      bullets,
      "",
      "Open the citations below for full context."
    ]
    |> Enum.join("\n")
  end

  @spec normalize_llm_answer(term()) :: String.t()
  defp normalize_llm_answer(answer) when is_binary(answer) do
    answer
    |> String.trim()
    |> strip_markdown_fence()
    |> String.trim()
  end

  defp normalize_llm_answer(_answer), do: ""

  @spec quota_error?(term()) :: boolean()
  defp quota_error?(reason) when is_atom(reason) do
    reason in [:rate_limited, :insufficient_quota, :quota_exceeded, :too_many_requests]
  end

  defp quota_error?(reason) when is_binary(reason) do
    normalized = String.downcase(reason)

    String.contains?(normalized, "quota") or
      String.contains?(normalized, "rate limit") or
      String.contains?(normalized, "too many requests") or
      String.contains?(normalized, "insufficient_quota") or
      String.contains?(normalized, "429")
  end

  defp quota_error?(reason) when is_tuple(reason) do
    reason
    |> Tuple.to_list()
    |> Enum.any?(&quota_error?/1)
  end

  defp quota_error?(reason) when is_list(reason) do
    Enum.any?(reason, &quota_error?/1)
  end

  defp quota_error?(reason) when is_map(reason) do
    reason
    |> Map.values()
    |> Enum.any?(&quota_error?/1)
  end

  defp quota_error?(_reason), do: false

  defp normalize_related_queries(related_queries) when is_list(related_queries) do
    related_queries
    |> Enum.filter(&is_binary/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
    |> Enum.take(4)
  end

  defp normalize_related_queries(_related_queries), do: []

  @spec strip_markdown_fence(String.t()) :: String.t()
  defp strip_markdown_fence(answer) do
    answer
    |> String.replace_prefix("```markdown\n", "")
    |> String.replace_prefix("```\n", "")
    |> String.replace_suffix("\n```", "")
  end

  @spec source_label(atom()) :: String.t()
  defp source_label(:docs), do: "Docs"
  defp source_label(:blog), do: "Blog"
  defp source_label(:ecosystem), do: "Ecosystem"
  defp source_label(_), do: "Content"

  @spec truncate_line(String.t(), pos_integer()) :: String.t()
  defp truncate_line(text, max_len) when is_binary(text) and max_len > 0 do
    if String.length(text) <= max_len do
      text
    else
      String.slice(text, 0, max_len) <> "..."
    end
  end

  defp content_assistant_cfg do
    Application.get_env(:agent_jido, AgentJido.ContentAssistant, [])
  end

  defp config_value(config, key, default \\ nil)
  defp config_value(config, key, default) when is_list(config), do: Keyword.get(config, key, default)
  defp config_value(config, key, default) when is_map(config), do: Map.get(config, key, default)
  defp config_value(_config, _key, default), do: default

  defp truthy?(value), do: value in [true, "true", 1, "1", "on"]

  defp query_max_length(opts) when is_list(opts) do
    case Keyword.get(opts, :query_max_length, config_value(content_assistant_cfg(), :query_max_length, @default_query_max_length)) do
      value when is_integer(value) and value > 0 -> value
      _ -> @default_query_max_length
    end
  end

  defp query_max_length(_opts), do: @default_query_max_length

  defp normalize_query(query, max_length) when is_binary(query) and is_integer(max_length) and max_length > 0 do
    query
    |> String.trim()
    |> String.slice(0, max_length)
  end

  defp normalize_query(_query, _max_length), do: ""

  defp assistant_timeout_ms(opts) when is_list(opts) do
    case Keyword.get(opts, :assistant_timeout_ms, config_value(content_assistant_cfg(), :assistant_timeout_ms, @default_assistant_timeout_ms)) do
      value when is_integer(value) and value > 0 -> value
      _ -> @default_assistant_timeout_ms
    end
  end

  defp assistant_timeout_ms(_opts), do: @default_assistant_timeout_ms

  defp normalize_assistant_timeout(value) when is_integer(value) and value > 0, do: value
  defp normalize_assistant_timeout(_value), do: @default_assistant_timeout_ms

  defp task_supervisor(llm_opts) when is_list(llm_opts) do
    Keyword.get(llm_opts, :task_supervisor, AgentJido.ContentAssistant.TaskSupervisor)
  end

  defp task_supervisor(_llm_opts), do: AgentJido.ContentAssistant.TaskSupervisor

  defp link_channel(opts) when is_list(opts) do
    case Keyword.get(opts, :surface) do
      "content_assistant_modal" -> "content_assistant_modal"
      "content_assistant_page" -> "content_assistant_page"
      _ -> "content_assistant_page"
    end
  end

  defp link_channel(_opts), do: "content_assistant_page"

  defp related_queries(query, opts) when is_binary(query) and is_list(opts) do
    retrieval_module = Keyword.get(opts, :retrieval_module, retrieval_module())
    retrieval_opts = Keyword.get(opts, :retrieval_opts, [])

    if function_exported?(retrieval_module, :suggest_related_queries, 2) do
      retrieval_module.suggest_related_queries(query, retrieval_opts)
    else
      []
    end
  rescue
    _ -> []
  end

  defp related_queries(_query, _opts), do: []

  defp retrieval_module do
    Application.get_env(:agent_jido, :content_assistant_retrieval_module, Retrieval)
  end
end
