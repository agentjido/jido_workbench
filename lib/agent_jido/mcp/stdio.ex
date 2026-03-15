defmodule AgentJido.MCP.Stdio do
  @moduledoc """
  Newline-delimited stdio transport for the docs MCP server.
  """

  alias AgentJido.MCP.Server

  @spec run(keyword()) :: no_return()
  def run(opts \\ []) when is_list(opts) do
    loop(Server.new(opts), opts)
  end

  defp loop(state, opts) do
    case IO.binread(:stdio, :line) do
      :eof ->
        exit(:normal)

      {:error, reason} ->
        IO.binwrite(:stderr, "[mcp-docs] stdin read failed: #{inspect(reason)}\n")
        exit(:normal)

      line when is_binary(line) ->
        next_state =
          line
          |> String.trim()
          |> handle_line(state, opts)

        loop(next_state, opts)
    end
  end

  defp handle_line("", state, _opts), do: state

  defp handle_line(line, state, opts) do
    case Jason.decode(line) do
      {:ok, message} when is_map(message) ->
        case Server.handle_message(message, state, opts) do
          {:reply, response, next_state} ->
            write_response(response)
            next_state

          {:noreply, next_state} ->
            next_state
        end

      {:error, _reason} ->
        response = %{
          "jsonrpc" => "2.0",
          "id" => nil,
          "error" => %{
            "code" => -32_700,
            "message" => "Parse error"
          }
        }

        write_response(response)
        state
    end
  end

  defp write_response(response) when is_map(response) do
    response
    |> Jason.encode!()
    |> Kernel.<>("\n")
    |> then(&IO.binwrite(:stdio, &1))
  end
end
