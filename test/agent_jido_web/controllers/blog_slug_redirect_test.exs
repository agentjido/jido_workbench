defmodule AgentJidoWeb.BlogSlugRedirectTest do
  use AgentJidoWeb.ConnCase, async: true

  describe "legacy slug redirect plug" do
    test "redirects legacy filename slug to canonical slug with 301", %{conn: conn} do
      conn = get(conn, "/blog/introducing-req_llm")

      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["/blog/introducing-req-llm"]
    end

    test "preserves query string when redirecting", %{conn: conn} do
      conn = get(conn, "/blog/announcing-req_llm-1_0?utm_source=test")

      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["/blog/announcing-req-llm-1-0?utm_source=test"]
    end

    test "does not redirect blog tag pages", %{conn: conn} do
      conn = get(conn, "/blog/tags/elixir")
      assert conn.status == 200
    end
  end
end
