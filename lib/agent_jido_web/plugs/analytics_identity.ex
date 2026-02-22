defmodule AgentJidoWeb.Plugs.AnalyticsIdentity do
  @moduledoc """
  Ensures first-party analytics visitor/session identity is present for browser requests.
  """

  import Plug.Conn

  @visitor_cookie "_agent_jido_visitor_id"
  @session_key :analytics_session_id
  @cookie_max_age 60 * 60 * 24 * 365 * 2

  @spec init(term()) :: term()
  def init(opts), do: opts

  @spec call(Plug.Conn.t(), term()) :: Plug.Conn.t()
  def call(conn, _opts) do
    conn = fetch_cookies(conn, signed: [@visitor_cookie])

    visitor_id =
      conn.cookies[@visitor_cookie] ||
        Ecto.UUID.generate()

    session_id = get_session(conn, @session_key) || Ecto.UUID.generate()
    referrer_host = referrer_host(conn)

    analytics_identity = %{
      visitor_id: visitor_id,
      session_id: session_id,
      path: conn.request_path,
      referrer_host: referrer_host
    }

    conn
    |> maybe_put_visitor_cookie(conn.cookies[@visitor_cookie], visitor_id)
    |> put_session(@session_key, session_id)
    |> put_session(:analytics_identity, analytics_identity)
    |> assign(:analytics_identity, analytics_identity)
  end

  defp maybe_put_visitor_cookie(conn, existing_cookie, _visitor_id) when is_binary(existing_cookie), do: conn

  defp maybe_put_visitor_cookie(conn, _existing_cookie, visitor_id) do
    put_resp_cookie(conn, @visitor_cookie, visitor_id,
      sign: true,
      http_only: true,
      same_site: "Lax",
      max_age: @cookie_max_age
    )
  end

  defp referrer_host(conn) do
    case get_req_header(conn, "referer") do
      [referrer | _] ->
        case URI.parse(referrer).host do
          host when is_binary(host) -> host
          _ -> nil
        end

      _ ->
        nil
    end
  end
end
