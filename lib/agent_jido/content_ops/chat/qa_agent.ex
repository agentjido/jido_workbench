defmodule AgentJido.ContentOps.Chat.QAAgent do
  @moduledoc """
  Backward-compatibility shim for the renamed OpsAgent module.
  """

  @spec chat(pid(), String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  defdelegate chat(pid, prompt, opts \\ []), to: AgentJido.ContentOps.Chat.OpsAgent
end
