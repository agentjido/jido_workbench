defmodule AgentJidoWeb.MarkdownLinksTest do
  use ExUnit.Case, async: true

  alias AgentJidoWeb.MarkdownLinks

  test "converts github blob URLs to raw URLs" do
    blob_url = "https://github.com/agentjido/agentjido_xyz/blob/main/priv/pages/docs/index.md"

    assert MarkdownLinks.github_blob_to_raw(blob_url) ==
             "https://raw.githubusercontent.com/agentjido/agentjido_xyz/main/priv/pages/docs/index.md"
  end

  test "builds source URL from absolute source path" do
    absolute_path = Path.expand("priv/pages/docs/index.md", File.cwd!())

    assert MarkdownLinks.source_url_from_path(absolute_path) ==
             "https://github.com/agentjido/agentjido_xyz/blob/main/priv/pages/docs/index.md"
  end

  test "prefers source-backed markdown action when source exists" do
    page = %{source_path: Path.expand("priv/pages/docs/index.md", File.cwd!())}
    request_url = AgentJidoWeb.Endpoint.url() <> "/docs"
    action = MarkdownLinks.markdown_action(page, request_url)

    assert action.source_backed? == true
    assert action.label == "Open source on GitHub"

    assert action.url ==
             "https://github.com/agentjido/agentjido_xyz/blob/main/priv/pages/docs/index.md"
  end

  test "falls back to canonical page action when source path is unsupported" do
    post = %{source_path: "db://posts"}
    request_url = AgentJidoWeb.Endpoint.url() <> "/blog/test-post"
    action = MarkdownLinks.markdown_action(post, request_url)

    assert action.source_backed? == false
    assert action.label == "Open canonical page"
    assert action.url == request_url
  end
end
