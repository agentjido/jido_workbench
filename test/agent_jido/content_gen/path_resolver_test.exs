defmodule AgentJido.ContentGen.PathResolverTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentGen.PathResolver

  describe "target_path_for_route/2" do
    test "maps docs root and docs section roots correctly" do
      assert PathResolver.target_path_for_route("/docs", :md) == "priv/pages/docs/index.md"
      assert PathResolver.target_path_for_route("/docs/guides", :md) == "priv/pages/docs/guides.md"

      assert PathResolver.target_path_for_route("/docs/reference/packages/jido", :md) ==
               "priv/pages/docs/reference/packages/jido.md"
    end

    test "maps non-docs roots and nested routes" do
      assert PathResolver.target_path_for_route("/build", :md) == "priv/pages/build/index.md"
      assert PathResolver.target_path_for_route("/build/quickstart", :md) == "priv/pages/build/quickstart.md"
      assert PathResolver.target_path_for_route("/", :md) == "priv/pages/index.md"
    end
  end

  describe "resolve/2" do
    test "skips non-file-backed routes" do
      entry = %{id: "examples/overview", destination_route: "/examples", section: "examples", tags: []}
      assert {:skip, :skipped_non_file_target, %{route: "/examples"}} = PathResolver.resolve(entry, page_index: %{})
    end

    @tag :flaky
    test "preserves existing extension/path when page index has route" do
      entry = %{
        id: "docs/actions",
        destination_route: "/docs/concepts/actions",
        section: "docs",
        tags: [:format_markdown]
      }

      existing_path = "priv/pages/docs/concepts/actions.livemd"

      assert {:ok, target} =
               PathResolver.resolve(entry, page_index: %{"/docs/concepts/actions" => existing_path})

      assert target.target_path == existing_path
      assert target.format == :livemd
      assert target.exists?
    end

    test "chooses livebook format from docs tag when file missing" do
      entry = %{
        id: "docs/path-resolver-missing",
        destination_route: "/docs/concepts/path-resolver-missing",
        section: "docs",
        tags: [:format_livebook]
      }

      assert {:ok, target} = PathResolver.resolve(entry, page_index: %{})
      assert target.format == :livemd
      assert target.target_path == "priv/pages/docs/concepts/path-resolver-missing.livemd"
      refute target.exists?
    end

    @tag :flaky
    test "maps build output page paths back to source tree paths" do
      entry = %{
        id: "docs/agents",
        destination_route: "/docs/concepts/agents",
        section: "docs",
        tags: [:format_markdown]
      }

      build_path =
        Path.join([
          "_build",
          "dev",
          "lib",
          "agent_jido",
          "priv",
          "pages",
          "docs",
          "concepts",
          "agents.md"
        ])

      assert {:ok, target} =
               PathResolver.resolve(entry, page_index: %{"/docs/concepts/agents" => build_path})

      assert target.target_path == "priv/pages/docs/concepts/agents.livemd"
      assert target.read_path == "priv/pages/docs/concepts/agents.livemd"
      assert target.format == :livemd
      assert target.exists?
    end

    test "docs_format livemd converts existing markdown target safely" do
      existing_md = "priv/pages/docs/tmp/format-switch.md"
      :ok = File.mkdir_p(Path.dirname(existing_md))
      :ok = File.write(existing_md, "%{}\n---\n## Overview\n")

      on_exit(fn -> File.rm(existing_md) end)

      entry = %{
        id: "docs/format-switch",
        destination_route: "/docs/tmp/format-switch",
        section: "docs",
        tags: [:format_markdown]
      }

      assert {:ok, target} =
               PathResolver.resolve(entry,
                 page_index: %{"/docs/tmp/format-switch" => existing_md},
                 docs_format: :livemd
               )

      assert target.target_path == "priv/pages/docs/tmp/format-switch.livemd"
      assert target.read_path == existing_md
      assert target.conversion_source_path == existing_md
      assert target.format == :livemd
      assert target.exists?
    end
  end
end
