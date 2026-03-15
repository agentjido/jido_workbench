defmodule Mix.Tasks.Mcp.Docs do
  use Mix.Task

  alias AgentJido.MCP.Stdio

  @shortdoc "Starts the Agent Jido docs MCP server over stdio"

  @moduledoc """
  Starts the read-only Agent Jido docs MCP server over stdio.

  This task is intended for MCP clients that launch a local subprocess.
  Ensure the project is compiled before use so stdout stays reserved for
  newline-delimited JSON-RPC messages.
  """

  @impl true
  def run(_args) do
    Mix.Task.run("app.start")
    Stdio.run()
  end
end
