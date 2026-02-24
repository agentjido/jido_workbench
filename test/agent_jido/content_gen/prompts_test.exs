defmodule AgentJido.ContentGen.PromptsTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentGen.Prompts

  @prompt_files [
    "base.md.eex",
    "pass_structure.md.eex",
    "pass_writer.md.eex",
    "system_planner.md",
    "system_writer.md",
    "templates/build-guide.md",
    "templates/training-module.md",
    "templates/feature-page.md",
    "templates/ecosystem-package.md",
    "templates/docs-reference.md",
    "templates/docs-concept.md"
  ]

  setup do
    original_prompt_root = Application.get_env(:agent_jido, :content_gen_prompt_root)

    on_exit(fn ->
      if original_prompt_root do
        Application.put_env(:agent_jido, :content_gen_prompt_root, original_prompt_root)
      else
        Application.delete_env(:agent_jido, :content_gen_prompt_root)
      end
    end)

    :ok
  end

  test "required prompt files exist under priv/prompts/content_gen" do
    root = Path.join(Application.app_dir(:agent_jido), "priv/prompts/content_gen")

    Enum.each(@prompt_files, fn relative_path ->
      assert File.exists?(Path.join(root, relative_path)),
             "expected prompt file to exist: #{relative_path}"
    end)
  end

  test "template routing includes section-specific guidance" do
    concept_prompt =
      Prompts.build(
        entry(%{id: "docs/concepts/agents", section: "docs", destination_route: "/docs/concepts/agents"}),
        %{route: "/docs/concepts/agents", target_path: "priv/pages/docs/concepts/agents.livemd", format: :livemd},
        %{update_mode: :improve, existing: nil}
      )

    assert concept_prompt =~ "Concept Overview"

    reference_prompt =
      Prompts.build(
        entry(%{id: "docs/reference/actions", section: "docs", destination_route: "/docs/reference/actions"}),
        %{route: "/docs/reference/actions", target_path: "priv/pages/docs/reference/actions.livemd", format: :livemd},
        %{update_mode: :improve, existing: nil}
      )

    assert reference_prompt =~ "## Public API"

    build_prompt =
      Prompts.build(
        entry(%{id: "build/installation", section: "build", destination_route: "/build/installation"}),
        %{route: "/build/installation", target_path: "priv/pages/build/installation.md", format: :md},
        %{update_mode: :improve, existing: nil}
      )

    assert build_prompt =~ "## What You'll Build"
  end

  test "missing prompt files raise a clear error" do
    tmp_root = Path.join(System.tmp_dir!(), "content_gen_prompts_missing_#{System.unique_integer([:positive])}")
    File.rm_rf!(tmp_root)
    File.mkdir_p!(tmp_root)
    Application.put_env(:agent_jido, :content_gen_prompt_root, tmp_root)

    on_exit(fn ->
      File.rm_rf(tmp_root)
    end)

    assert_raise RuntimeError, ~r/missing prompt file/, fn ->
      Prompts.build(
        entry(%{id: "docs/concepts/agents", section: "docs", destination_route: "/docs/concepts/agents"}),
        %{route: "/docs/concepts/agents", target_path: "priv/pages/docs/concepts/agents.livemd", format: :livemd},
        %{update_mode: :improve, existing: nil}
      )
    end
  end

  defp entry(overrides) do
    Map.merge(
      %{
        id: "docs/concepts/agents",
        title: "Agents",
        section: "docs",
        order: 100,
        status: :outline,
        purpose: "Define agents",
        audience: :intermediate,
        content_type: :guide,
        learning_outcomes: [],
        repos: [],
        source_modules: [],
        source_files: [],
        prerequisites: [],
        related: [],
        ecosystem_packages: [],
        destination_route: "/docs/concepts/agents",
        tags: [:hub_concepts, :format_livebook],
        prompt_overrides: %{},
        body: "Content brief"
      },
      overrides
    )
  end
end
