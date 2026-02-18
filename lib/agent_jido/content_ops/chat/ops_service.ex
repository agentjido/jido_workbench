defmodule AgentJido.ContentOps.Chat.OpsService do
  @moduledoc """
  Shared operations service used by both slash commands and ReAct tools.
  """

  require Logger

  alias AgentJido.ContentOps.Chat.{
    Config,
    ContentResolver,
    ContextRetriever,
    GithubClient,
    Policy
  }

  alias AgentJido.ContentOps.OrchestratorAgent

  @type actor_context :: %{channel: atom() | nil, external_user_id: String.t()}
  @issue_subtype_label "ops-issue"

  @doc """
  Trigger a ContentOps run asynchronously.
  """
  @spec run(atom(), actor_context()) :: {:ok, map()} | {:error, term()}
  def run(mode, actor_context) when mode in [:hourly, :nightly, :weekly, :monthly] do
    log_mutation(:info, :mutation_attempted, %{action: :run, mode: mode})

    with :ok <- authorize(actor_context),
         :ok <- ensure_orchestrator_ready(),
         {:ok, _pid} <- start_run_task(mode) do
      emit_metric([:contentops, :chatops, :mutation, :total], %{action: :run, mode: mode})
      log_mutation(:info, :mutation_succeeded, %{action: :run, mode: mode})

      {:ok, %{action: :run_started, mode: mode, message: "Started ContentOps #{mode} run."}}
    else
      {:error, reason} when reason in [:unauthorized, :mutations_disabled] ->
        emit_metric([:contentops, :chatops, :mutation, :denied], %{action: :run, reason: reason})
        log_mutation(:warning, :mutation_denied, %{action: :run, mode: mode, reason: reason})
        {:error, reason}

      {:error, :already_running} ->
        emit_metric([:contentops, :chatops, :mutation, :denied], %{action: :run, reason: :already_running})
        log_mutation(:info, :mutation_denied, %{action: :run, mode: mode, reason: :already_running})
        {:error, :already_running}

      {:error, :orchestrator_unavailable} ->
        emit_metric([:contentops, :chatops, :orchestrator, :error], %{action: :run, reason: :unavailable})
        log_mutation(:warning, :mutation_failed, %{action: :run, mode: mode, reason: :orchestrator_unavailable})
        {:error, :orchestrator_unavailable}

      {:error, reason} ->
        emit_metric([:contentops, :chatops, :orchestrator, :error], %{action: :run, reason: reason})
        log_mutation(:warning, :mutation_failed, %{action: :run, mode: mode, reason: reason})
        {:error, reason}
    end
  end

  def run(_mode, _actor_context), do: {:error, :invalid_mode}

  @doc """
  Create an issue in the configured repository.
  """
  @spec create_issue(map(), actor_context()) :: {:ok, map()} | {:error, term()}
  def create_issue(request, actor_context) when is_map(request) do
    log_mutation(:info, :mutation_attempted, %{action: :create_issue})

    with :ok <- authorize(actor_context),
         cfg <- Config.load!(),
         title <- request[:title] || request["title"],
         true <- is_binary(title) and String.trim(title) != "",
         labels <-
           merged_labels(
             cfg.github_labels_base ++ [@issue_subtype_label],
             request[:labels] || request["labels"]
           ),
         body <- issue_body(request),
         context <- github_context(cfg, request),
         {:ok, result} <-
           github_client().create_issue(
             %{
               title: String.trim(title),
               body: body,
               labels: labels
             },
             context
           ) do
      emit_metric([:contentops, :chatops, :mutation, :total], %{action: :create_issue})
      log_mutation(:info, :mutation_succeeded, %{action: :create_issue, issue_number: result.number, issue_url: result.url})

      {:ok,
       %{
         action: :issue_created,
         number: result.number,
         url: result.url,
         owner: result.owner,
         repo: result.repo,
         message: "Created issue ##{result.number}: #{result.url}"
       }}
    else
      false ->
        {:error, :missing_title}

      {:error, reason} = error when reason in [:unauthorized, :mutations_disabled] ->
        emit_metric([:contentops, :chatops, :mutation, :denied], %{action: :create_issue, reason: reason})
        log_mutation(:warning, :mutation_denied, %{action: :create_issue, reason: reason})
        error

      {:error, {:github_error, _status, _body} = reason} = error ->
        emit_metric([:contentops, :chatops, :github, :error], %{action: :create_issue, reason: reason})
        log_mutation(:warning, :mutation_failed, %{action: :create_issue, reason: reason})
        error

      {:error, reason} = error ->
        emit_metric([:contentops, :chatops, :github, :error], %{action: :create_issue, reason: reason})
        log_mutation(:warning, :mutation_failed, %{action: :create_issue, reason: reason})
        error
    end
  end

  @doc """
  Add a docs note as an issue comment or a new docs-note issue.
  """
  @spec add_doc_note(map(), actor_context()) :: {:ok, map()} | {:error, term()}
  def add_doc_note(request, actor_context) when is_map(request) do
    log_mutation(:info, :mutation_attempted, %{action: :add_doc_note})

    with :ok <- authorize(actor_context),
         note <- normalize_string(request[:note] || request["note"]),
         true <- note != "",
         page_ref <- normalize_string(request[:page_ref] || request["page_ref"]),
         true <- page_ref != "",
         cfg <- Config.load!(),
         {:ok, target} <- resolve_target(page_ref),
         {:ok, snippets} <- retrieve_context(note, target),
         context <- github_context(cfg, request),
         {:ok, result} <- persist_doc_note(request, note, target, snippets, cfg, context) do
      emit_metric([:contentops, :chatops, :mutation, :total], %{action: :add_doc_note})
      log_mutation(:info, :mutation_succeeded, %{action: :add_doc_note, outcome: result.action, issue_number: result[:number]})
      {:ok, result}
    else
      false ->
        {:error, :invalid_note_request}

      {:ambiguous, candidates} ->
        {:ok,
         %{
           action: :clarify_target,
           status: :needs_clarification,
           message: ambiguity_message(candidates),
           candidates: candidates
         }}

      {:error, reason} = error ->
        if reason in [:unauthorized, :mutations_disabled] do
          emit_metric([:contentops, :chatops, :mutation, :denied], %{action: :add_doc_note, reason: reason})
          log_mutation(:warning, :mutation_denied, %{action: :add_doc_note, reason: reason})
        end

        if match?({:github_error, _status, _body}, reason) do
          emit_metric([:contentops, :chatops, :github, :error], %{action: :add_doc_note, reason: :github_error})
          log_mutation(:warning, :mutation_failed, %{action: :add_doc_note, reason: :github_error})
        end

        error
    end
  end

  defp resolve_target(page_ref) do
    resolver = resolver()

    case resolver.resolve(page_ref) do
      {:ok, target} -> {:ok, target}
      {:ambiguous, candidates} -> {:ambiguous, candidates}
      {:error, :not_found} -> {:error, :target_not_found}
      {:error, :missing_ref} -> {:error, :target_missing}
      other -> other
    end
  end

  defp retrieve_context(note, target) do
    query = "#{target.title} #{note}"
    retriever().fetch(query, preferred_collection: "site_docs", limit: 3)
  end

  defp persist_doc_note(request, note, target, snippets, cfg, context) do
    maybe_number = parse_issue_number(request[:issue_number] || request["issue_number"])
    body = doc_note_body(note, target, snippets)

    if maybe_number do
      with {:ok, comment} <- github_client().create_issue_comment(maybe_number, body, context) do
        {:ok,
         %{
           action: :issue_commented,
           number: maybe_number,
           url: comment.url,
           target: target,
           message: "Added note to issue ##{maybe_number}: #{comment.url}"
         }}
      end
    else
      labels = merged_labels(cfg.github_labels_base ++ cfg.github_labels_docs_note, request[:labels] || request["labels"])

      title = doc_note_title(target)

      with {:ok, issue} <- github_client().create_issue(%{title: title, body: body, labels: labels}, context) do
        {:ok,
         %{
           action: :issue_created,
           number: issue.number,
           url: issue.url,
           target: target,
           message: "Created docs note issue ##{issue.number}: #{issue.url}"
         }}
      end
    end
  end

  defp issue_body(request) do
    details = normalize_string(request[:body] || request["body"])
    related = normalize_string(request[:related_page] || request["related_page"])
    reason = normalize_string(request[:reason] || request["reason"])

    [
      "Created via ContentOps ChatOps.",
      related_line("Related page", related),
      related_line("Reason", reason),
      if(details != "", do: "\nDetails:\n#{details}", else: nil)
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
    |> String.trim()
  end

  defp doc_note_body(note, target, snippets) do
    snippet_section =
      case snippets do
        [] ->
          nil

        list ->
          lines =
            list
            |> Enum.map(fn snippet ->
              "- #{snippet.snippet}"
            end)
            |> Enum.join("\n")

          "Context:\n" <> lines
      end

    [
      "Doc note submitted via ContentOps ChatOps.",
      "Target: #{target.type} #{target.id}",
      if(target.path, do: "Path: #{target.path}", else: nil),
      "",
      "Note:",
      note,
      snippet_section
    ]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
    |> String.trim()
  end

  defp doc_note_title(target) do
    base = String.trim(target.title || target.id || "Untitled")
    "Docs note: " <> base
  end

  defp ambiguity_message(candidates) do
    options =
      candidates
      |> Enum.map(fn candidate ->
        "- #{candidate.id} (#{candidate.type})#{if candidate.path, do: " path=#{candidate.path}", else: ""}"
      end)
      |> Enum.join("\n")

    "I found multiple matching content targets. Reply with an exact id/path:\n#{options}"
  end

  defp related_line(_label, ""), do: nil
  defp related_line(label, value), do: "#{label}: #{value}"

  defp merged_labels(base, extra) do
    ((base || []) ++ normalize_labels(extra))
    |> normalize_labels()
  end

  defp normalize_labels(labels) when is_list(labels) do
    labels
    |> Enum.map(&to_string/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end

  defp normalize_labels(labels) when is_binary(labels) do
    labels
    |> String.split(",", trim: true)
    |> normalize_labels()
  end

  defp normalize_labels(_), do: []

  defp parse_issue_number(nil), do: nil
  defp parse_issue_number(number) when is_integer(number) and number > 0, do: number

  defp parse_issue_number(number) when is_binary(number) do
    cleaned = number |> String.trim() |> String.trim_leading("#")

    case Integer.parse(cleaned) do
      {parsed, ""} when parsed > 0 -> parsed
      _ -> nil
    end
  end

  defp parse_issue_number(_), do: nil

  defp normalize_string(nil), do: ""
  defp normalize_string(value) when is_binary(value), do: String.trim(value)
  defp normalize_string(value), do: value |> to_string() |> normalize_string()

  defp github_context(cfg, request) do
    %{
      github_owner: request[:github_owner] || request["github_owner"] || cfg.github_owner,
      github_repo: request[:github_repo] || request["github_repo"] || cfg.github_repo,
      github_client: request[:github_client] || request["github_client"],
      github_api: request[:github_api] || request["github_api"]
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp authorize(actor_context) do
    try do
      Policy.authorize_mutation!(actor_context)
      :ok
    rescue
      Policy.MutationsDisabledError ->
        {:error, :mutations_disabled}

      Policy.UnauthorizedError ->
        {:error, :unauthorized}
    end
  end

  defp github_client do
    Application.get_env(:agent_jido, __MODULE__, [])
    |> Keyword.get(:github_client, GithubClient)
  end

  defp resolver do
    Application.get_env(:agent_jido, __MODULE__, [])
    |> Keyword.get(:resolver, ContentResolver)
  end

  defp retriever do
    Application.get_env(:agent_jido, __MODULE__, [])
    |> Keyword.get(:retriever, ContextRetriever)
  end

  defp run_fun do
    Application.get_env(:agent_jido, __MODULE__, [])
    |> Keyword.get(:run_fun, fn mode -> OrchestratorAgent.run(mode: mode, timeout: 30_000) end)
  end

  defp task_supervisor do
    Application.get_env(:agent_jido, __MODULE__, [])
    |> Keyword.get(:task_supervisor, AgentJido.ContentOps.TaskSupervisor)
  end

  defp start_run_task(mode) do
    Task.Supervisor.start_child(task_supervisor(), fn ->
      _ = run_fun().(mode)
    end)
  end

  defp ensure_orchestrator_ready do
    case orchestrator_ready_fun().() do
      :ok -> :ok
      {:error, :already_running} -> {:error, :already_running}
      {:error, _reason} -> {:error, :orchestrator_unavailable}
    end
  end

  defp orchestrator_ready_fun do
    Application.get_env(:agent_jido, __MODULE__, [])
    |> Keyword.get(:orchestrator_ready_fun, fn -> OrchestratorAgent.check_ready() end)
  end

  defp emit_metric(event_name, metadata) do
    :telemetry.execute(event_name, %{count: 1}, metadata)
  rescue
    _ -> :ok
  end

  defp log_mutation(level, event, metadata) do
    message = "[ContentOps.Chat.OpsService] #{event} #{format_metadata(metadata)}"

    case level do
      :warning -> Logger.warning(message)
      :error -> Logger.error(message)
      _ -> Logger.info(message)
    end
  end

  defp format_metadata(metadata) when is_map(metadata) do
    metadata
    |> Enum.map(fn {key, value} -> "#{key}=#{inspect(value)}" end)
    |> Enum.join(" ")
  end
end
