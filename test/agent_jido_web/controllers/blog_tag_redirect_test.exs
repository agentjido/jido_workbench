defmodule AgentJidoWeb.BlogTagRedirectTest do
  use AgentJidoWeb.ConnCase, async: true

  describe "legacy tag redirect plug" do
    test "redirects built-in req tag aliases", %{conn: conn} do
      conn = get(conn, "/blog/tags/reqllm")

      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["/blog/tags/req_llm"]
    end

    test "redirects built-in signal tag aliases", %{conn: conn} do
      conn = get(conn, "/blog/tags/signal")

      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["/blog/tags/signals"]
    end

    test "preserves query string when redirecting", %{conn: conn} do
      conn = get(conn, "/blog/tags/reqllm?utm_source=test")

      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["/blog/tags/req_llm?utm_source=test"]
    end

    test "does not redirect canonical tag routes", %{conn: conn} do
      conn = get(conn, "/blog/tags/req_llm")

      refute conn.status == 301
      assert get_resp_header(conn, "location") == []
    end
  end
end
