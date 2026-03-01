defmodule AgentJidoWeb.LLMSTxtController do
  use AgentJidoWeb, :controller

  @doc """
  Returns curated retrieval guidance for LLM clients.
  """
  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    endpoint_url = AgentJidoWeb.Endpoint.url()

    body = """
    Agent Jido (#{endpoint_url}) is a site for building reliable multi-agent systems on Elixir/OTP.

    Preferred retrieval
    - Send `Accept: text/markdown` on public content routes.
    - Canonical markdown negotiation routes:
      - /
      - /docs*
      - /blog*
      - /ecosystem*
      - /features*
      - /build*
      - /community*
      - /getting-started
      - /examples*

    Primary content hubs
    - Docs: #{endpoint_url}/docs
    - Blog: #{endpoint_url}/blog
    - Ecosystem: #{endpoint_url}/ecosystem
    - Features: #{endpoint_url}/features
    - Build: #{endpoint_url}/build
    - Community: #{endpoint_url}/community
    - Examples: #{endpoint_url}/examples

    Discovery
    - Sitemap: #{endpoint_url}/sitemap.xml
    - Feed: #{endpoint_url}/feed

    Rendered fallback pattern
    - If direct source markdown is unavailable, request the canonical route with:
      - Accept: text/markdown
    """

    conn
    |> put_resp_content_type("text/plain", "utf-8")
    |> send_resp(200, body)
  end
end
