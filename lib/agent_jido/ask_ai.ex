defmodule AgentJido.AskAi do
  @moduledoc """
  Ask AI answer synthesis with LLM-first summarization and deterministic fallback.
  """

  require Logger

  alias AgentJido.Search.Result

  @default_temperature 0.1
  @max_reference_snippet 240

  @type mode :: :llm | :deterministic | :deterministic_fallback | :quota_fallback

  def summarize(query, citations, opts \\ [])

  @spec summarize(String.t(), [Result.t()], keyword()) :: {:ok, String.t(), mode()}
  def summarize(query, citations, opts) when is_binary(query) and is_list(citations) do
    deterministic = deterministic_summary(query, citations)
    llm = Keyword.get(opts, :llm, Application.get_env(:arcana, :llm))

    cond do
      citations == [] ->
        {:ok, "", :deterministic}

      is_nil(llm) ->
        {:ok, deterministic, :deterministic}

      true ->
        summarize_with_llm(query, citations, llm, deterministic, opts)
    end
  end

  def summarize(_query, _citations, _opts), do: {:ok, "", :deterministic}

  defp summarize_with_llm(query, citations, llm, deterministic, opts) do
    llm_opts =
      opts
      |> Keyword.get(:llm_opts, [])
      |> Keyword.put_new(:temperature, @default_temperature)
      |> Keyword.put_new(:system_prompt, llm_system_prompt())

    case Arcana.LLM.complete(llm, llm_prompt(query, citations), [], llm_opts) do
      {:ok, answer} ->
        answer = normalize_llm_answer(answer)

        if answer == "" do
          {:ok, deterministic, :deterministic_fallback}
        else
          {:ok, answer, :llm}
        end

      {:error, reason} ->
        Logger.warning("Ask AI LLM summarization failed: #{inspect(reason)}")

        if quota_error?(reason) do
          {:ok, deterministic, :quota_fallback}
        else
          {:ok, deterministic, :deterministic_fallback}
        end
    end
  end

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
end
