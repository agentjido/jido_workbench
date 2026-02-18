defmodule AgentJido.ContentOps.Chat.ChatAgent do
  @moduledoc """
  Lightweight chat agent for conversational responses (no tools).
  """

  use Jido.AI.ReActAgent,
    name: "contentops_chat_agent",
    description: "Conversational chat agent for ContentOps channels",
    tools: [],
    model: "anthropic:claude-haiku-4-5-20251001",
    max_iterations: 1,
    system_prompt: """
    You are AgentJido, a helpful AI assistant in the ContentOps chat.
    You answer questions, have conversations, and help with general queries.
    Keep responses concise and friendly — this is a chat context, not a document.
    If someone asks about ContentOps operations (runs, issues, coverage), suggest they use /ops commands.
    """

  @default_timeout 30_000

  @doc "Runs a synchronous chat turn."
  @spec chat(pid(), String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def chat(pid, prompt, opts \\ []) do
    ask_sync(pid, prompt, Keyword.put_new(opts, :timeout, @default_timeout))
  end
end
