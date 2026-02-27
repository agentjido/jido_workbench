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

  test "builds markdown.new URL without escaping the absolute URL suffix" do
    absolute_url = "https://agentjido.xyz/docs/getting-started"

    assert MarkdownLinks.markdown_new_url(absolute_url) ==
             "https://markdown.new/https://agentjido.xyz/docs/getting-started"
  end

  test "prefers source-backed markdown action when source exists" do
    page = %{source_path: Path.expand("priv/pages/docs/index.md", File.cwd!())}
    request_url = "https://agentjido.xyz/docs"
    action = MarkdownLinks.markdown_action(page, request_url)

    assert action.source_backed? == true
    assert action.label == "Open source in markdown.new"

    assert action.url ==
             "https://markdown.new/https://raw.githubusercontent.com/agentjido/agentjido_xyz/main/priv/pages/docs/index.md"
  end

  test "falls back to rendered page markdown.new action when source is unavailable" do
    post = %{source_path: "phoenix_blog://posts"}
    request_url = "https://agentjido.xyz/blog/test-post"
    action = MarkdownLinks.markdown_action(post, request_url)

    assert action.source_backed? == false
    assert action.label == "Open page in markdown.new"
    assert action.url == "https://markdown.new/https://agentjido.xyz/blog/test-post"
  end
end
