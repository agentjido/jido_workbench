defmodule AgentJidoWeb.PageLiveCopyMarkdownTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @moduletag :flaky

  test "docs right rail renders Copy Markdown above Quick Links", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/docs/concepts/agents")

    assert html =~ ~s(data-copy-source-url="/docs/concepts/agents.md")
    assert html =~ ~s(data-copy-success-label="Copied")

    toc_index = :binary.match(html, ~s(id="docs-right-toc"))
    copy_index = :binary.match(html, "Copy Markdown")
    quick_links_index = :binary.match(html, "QUICK LINKS")

    assert match?({_, _}, toc_index)
    assert match?({_, _}, copy_index)
    assert match?({_, _}, quick_links_index)

    {toc_pos, _} = toc_index
    {copy_pos, _} = copy_index
    {quick_links_pos, _} = quick_links_index

    assert toc_pos < copy_pos
    assert copy_pos < quick_links_pos
  end
end
