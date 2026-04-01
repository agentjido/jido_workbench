defmodule AgentJido.ContentIngest.EcosystemDocs.ManifestParserTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentIngest.EcosystemDocs.ManifestParser

  test "parses meta refresh targets and sidebar assets" do
    html = """
    <html>
      <head>
        <meta http-equiv="refresh" content="0; url=overview.html">
        <script defer src="dist/sidebar_items-ABC123.js"></script>
      </head>
    </html>
    """

    assert ManifestParser.follow_meta_refresh(html, "https://hexdocs.pm/jido/2.1.0/") ==
             "https://hexdocs.pm/jido/2.1.0/overview.html"

    assert ManifestParser.sidebar_asset_url(html, "https://hexdocs.pm/jido/2.1.0/overview.html") ==
             "https://hexdocs.pm/jido/2.1.0/dist/sidebar_items-ABC123.js"
  end

  test "builds normalized page entries from sidebar_items payloads" do
    manifest =
      Jason.decode!(
        ~s({"modules":[{"id":"Jido.Agent","title":"Jido.Agent"}],"extras":[{"id":"overview","title":"Overview"},{"id":"getting-started","title":"Getting Started"}],"tasks":[{"id":"Mix.Tasks.Jido.Install","title":"mix jido.install"}]})
      )

    entries = ManifestParser.page_entries(manifest, "https://hexdocs.pm/jido/2.1.0/")

    assert Enum.any?(entries, &(&1.page_kind == :readme and &1.page_id == "overview"))
    assert Enum.any?(entries, &(&1.page_kind == :guide and &1.page_id == "getting-started"))
    assert Enum.any?(entries, &(&1.page_kind == :module and &1.page_id == "Jido.Agent"))
    assert Enum.any?(entries, &(&1.page_kind == :task and &1.page_id == "Mix.Tasks.Jido.Install"))
  end
end
