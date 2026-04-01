defmodule AgentJidoWeb.EcosystemBookmarksControllerTest do
  use AgentJidoWeb.ConnCase, async: true

  test "downloads the public ecosystem bookmarks export", %{conn: conn} do
    conn = get(conn, "/ecosystem/bookmarks.html")

    assert response(conn, 200) =~ "<!DOCTYPE NETSCAPE-Bookmark-file-1>"
    assert get_resp_header(conn, "content-type") == ["text/html; charset=utf-8"]
    assert get_resp_header(conn, "content-disposition") == ["attachment; filename=\"jido-ecosystem-repos.bookmarks.html\""]
    assert response(conn, 200) =~ "Jido Ecosystem Repos"
    assert response(conn, 200) =~ "github.com/agentjido"
  end
end
