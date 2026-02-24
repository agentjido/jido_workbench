defmodule AgentJidoWeb.BlogTagRedirectTest do
  use AgentJidoWeb.ConnCase, async: true

  alias AgentJido.Blog.TagAlias
  alias AgentJido.Repo

  setup do
    Repo.delete_all(TagAlias)
    :ok
  end

  describe "legacy tag redirect plug" do
    test "redirects stored legacy tag alias to canonical tag with 301", %{conn: conn} do
      {:ok, _alias} = TagAlias.upsert("legacy_req_tag", "req_llm")

      conn = get(conn, "/blog/tags/legacy_req_tag")

      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["/blog/tags/req_llm"]
    end

    test "redirects built-in taxonomy aliases", %{conn: conn} do
      conn = get(conn, "/blog/tags/reqllm")

      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["/blog/tags/req_llm"]
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
