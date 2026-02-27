defmodule AgentJidoWeb.Plugs.LLMAcceptCompat do
  @moduledoc """
  Makes `Accept: text/markdown` browser requests pass Phoenix's `:accepts`
  check by adding an HTML fallback media type.
  """

  import Plug.Conn

  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    accept_value =
      conn
      |> get_req_header("accept")
      |> Enum.join(", ")
      |> String.trim()

    cond do
      accept_value == "" ->
        conn

      markdown_requested?(accept_value) and not html_compatible?(accept_value) ->
        conn
        |> delete_req_header("accept")
        |> put_req_header("accept", accept_value <> ", text/html;q=0.9")

      true ->
        conn
    end
  end

  defp markdown_requested?(accept_value) do
    String.contains?(String.downcase(accept_value), "text/markdown")
  end

  defp html_compatible?(accept_value) do
    downcased = String.downcase(accept_value)
    String.contains?(downcased, "text/html") or String.contains?(downcased, "*/*")
  end
end
