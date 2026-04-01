defmodule AgentJido.EcosystemBookmarksTest do
  use ExUnit.Case, async: true

  alias AgentJido.Ecosystem.Bookmarks

  test "export_html uses custom bookmark titles and excludes opted-out packages" do
    html =
      Bookmarks.export_html([
        %{
          id: "jido",
          github_url: "https://github.com/agentjido/jido",
          github_org: "agentjido",
          github_repo: "jido",
          tagline: "Core framework"
        },
        %{
          id: "jido_ai",
          github_url: "https://github.com/agentjido/jido_ai",
          github_org: "agentjido",
          github_repo: "jido_ai",
          bookmark_title: "Jido AI Custom Title",
          tagline: "Ignored because custom title wins"
        },
        %{
          id: "hidden",
          github_url: "https://github.com/agentjido/hidden",
          github_org: "agentjido",
          github_repo: "hidden",
          bookmark_include: false
        }
      ])

    assert html =~ "<TITLE>Jido Ecosystem Repos</TITLE>"
    assert html =~ ~s(<A HREF="https://github.com/agentjido">agentjido</A>)
    assert html =~ ~s(<A HREF="https://github.com/agentjido/jido">agentjido/jido: Core framework</A>)
    assert html =~ ~s(<A HREF="https://github.com/agentjido/jido_ai">Jido AI Custom Title</A>)
    refute html =~ "agentjido/hidden"
  end

  test "count only includes public bookmark-eligible packages" do
    assert Bookmarks.count() > 0
  end
end
