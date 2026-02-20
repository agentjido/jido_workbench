defmodule AgentJido.ContentOps.Chat.OpsAgent do
  @moduledoc """
  Room-scoped ReAct agent for ContentOps ChatOps.
  """

  use Jido.AI.Agent,
    name: "contentops_chat_ops_agent",
    description: "ContentOps chat assistant with run and GitHub mutation tools",
    tools: [
      AgentJido.ContentOps.Chat.Actions.GetStatus,
      AgentJido.ContentOps.Chat.Actions.GetRecentRuns,
      AgentJido.ContentOps.Chat.Actions.GetCoverage,
      AgentJido.ContentOps.Chat.Actions.TriggerRun,
      AgentJido.ContentOps.Chat.Actions.CreateIssue,
      AgentJido.ContentOps.Chat.Actions.AddDocNote,
      AgentJido.ContentOps.Chat.Actions.ResolveContentTarget,
      AgentJido.ContentOps.Chat.Actions.FetchContextSnippets
    ],
    model: :fast,
    max_iterations: 5,
    system_prompt: """
    You are AgentJido ContentOps ChatOps assistant.

    Responsibilities:
    - Answer ContentOps questions (status, coverage, runs).
    - Execute allowed operations via tools: trigger run, create issue, add docs note.

    Safety:
    - All mutations are policy-checked in tools/services.
    - If a docs target is ambiguous, ask the user to choose from candidates.
    - Prefer deterministic, concise operational answers with concrete values.
    """

  @default_timeout 30_000

  @doc "Runs a synchronous turn against the room-scoped Ops agent."
  @spec chat(pid(), String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def chat(pid, prompt, opts \\ []) do
    ask_sync(pid, prompt, Keyword.put_new(opts, :timeout, @default_timeout))
  end

  @impl true
  def on_before_cmd(agent, {:react_start, %{tool_context: tool_context} = params}) do
    updated = Map.put(params, :tool_context, maybe_put_github_client(tool_context))
    super(agent, {:react_start, updated})
  end

  @impl true
  def on_before_cmd(agent, {:react_start, params}) when is_map(params) do
    updated = Map.put(params, :tool_context, maybe_put_github_client(%{}))
    super(agent, {:react_start, updated})
  end

  @impl true
  def on_before_cmd(agent, action), do: super(agent, action)

  defp maybe_put_github_client(tool_context) when is_map(tool_context) do
    if Map.has_key?(tool_context, :github_client) or Map.has_key?(tool_context, :client) do
      tool_context
    else
      case System.get_env("GITHUB_TOKEN") do
        token when is_binary(token) and token != "" ->
          Map.put(tool_context, :github_client, Tentacat.Client.new(%{access_token: token}))

        _other ->
          tool_context
      end
    end
  end

  defp maybe_put_github_client(_other), do: maybe_put_github_client(%{})
end
