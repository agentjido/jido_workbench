defmodule AgentJido.ContentGen.WriterTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentGen.Writer

  test "merge_frontmatter preserves route-critical keys and published draft state" do
    existing = %{
      title: "Old title",
      description: "Old description",
      category: :docs,
      order: 42,
      draft: false,
      in_menu: false,
      legacy_paths: ["/legacy"]
    }

    generated = %{
      title: "New title",
      description: "New description",
      draft: true
    }

    entry = %{title: "Entry title", purpose: "Entry purpose", order: 11}

    merged = Writer.merge_frontmatter(existing, generated, entry, "/docs/reference/example")

    assert merged.title == "New title"
    assert merged.description == "New description"
    assert merged.category == :docs
    assert merged.order == 42
    assert merged.in_menu == false
    assert merged.legacy_paths == ["/legacy"]
    assert merged.draft == false
  end

  test "noop? ignores trailing whitespace noise" do
    existing = "line one  \nline two\n"
    generated = "line one\nline two   \n"
    assert Writer.noop?(existing, generated)
  end

  test "render/write/read round trip for markdown page" do
    tmp_dir = tmp_dir!("content_gen_writer")
    path = Path.join(tmp_dir, "sample.md")

    frontmatter = %{title: "Sample", description: "Sample description", draft: false}
    body = "# Heading\n\nBody.\n"
    rendered = Writer.render_file(frontmatter, body)

    assert :ok = Writer.write(path, rendered)
    assert {:ok, parsed} = Writer.read_existing(path)
    assert parsed.frontmatter.title == "Sample"
    assert parsed.body =~ "Heading"
  end

  defp tmp_dir!(prefix) do
    path = Path.join(System.tmp_dir!(), "#{prefix}_#{System.unique_integer([:positive])}")
    :ok = File.mkdir_p(path)
    on_exit(fn -> File.rm_rf(path) end)
    path
  end
end
