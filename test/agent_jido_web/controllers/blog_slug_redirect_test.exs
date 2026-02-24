defmodule AgentJidoWeb.BlogSlugRedirectTest do
  use AgentJidoWeb.ConnCase, async: true

  alias AgentJido.Blog.SlugAlias

  describe "legacy slug redirect plug" do
    test "redirects legacy blog slug to canonical slug with 301", %{conn: conn} do
      {:ok, _alias} = SlugAlias.upsert("legacy_slug", "canonical-slug")

      conn = get(conn, "/blog/legacy_slug")

      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["/blog/canonical-slug"]
    end

    test "preserves query string when redirecting", %{conn: conn} do
      {:ok, _alias} = SlugAlias.upsert("legacy_query_slug", "canonical-query-slug")

      conn = get(conn, "/blog/legacy_query_slug?utm_source=test")

      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["/blog/canonical-query-slug?utm_source=test"]
    end

    test "does not redirect blog tag pages", %{conn: conn} do
      {:ok, _alias} = SlugAlias.upsert("elixir", "elixir-canonical")

      conn = get(conn, "/blog/tags/elixir")
      assert conn.status == 200
    end
  end
end
