defmodule AgentJido.Demos.SkillsRuntimeFoundationsRuntimeDemoTest do
  use ExUnit.Case, async: false

  alias AgentJido.Demos.SkillsRuntimeFoundations.RuntimeDemo
  alias Jido.AI.Skill

  setup do
    demo = RuntimeDemo.new()

    on_exit(fn ->
      RuntimeDemo.reset(demo)
    end)

    %{demo: demo}
  end

  test "loads the checked-in file-backed manifest without mutating the registry", %{demo: demo} do
    demo = RuntimeDemo.load_file_manifest(demo)

    assert demo.file_manifest.name == "demo-code-review"
    assert demo.file_manifest.description =~ "skills runtime demo"
    assert demo.file_manifest.allowed_tools == ["read_file", "grep", "git_diff"]
    assert demo.registry_specs == []
  end

  test "registers the module-backed skill into the runtime registry", %{demo: demo} do
    demo = RuntimeDemo.register_module_skill(demo)

    assert demo.module_manifest.name == "demo-runtime-calculator"
    assert Enum.map(demo.registry_specs, & &1.name) == ["demo-runtime-calculator"]
    assert {:ok, spec} = Skill.resolve("demo-runtime-calculator")
    assert spec.description =~ "arithmetic"
  end

  test "loads the file-backed skill directory into the runtime registry", %{demo: demo} do
    demo =
      demo
      |> RuntimeDemo.register_module_skill()
      |> RuntimeDemo.load_runtime_skills()

    assert demo.loaded_count == 2

    assert Enum.map(demo.registry_specs, & &1.name) == [
             "demo-runtime-calculator",
             "demo-code-review",
             "demo-release-notes"
           ]
  end

  test "renders a combined prompt and tool union from the registered demo skills", %{demo: demo} do
    demo =
      demo
      |> RuntimeDemo.register_module_skill()
      |> RuntimeDemo.load_runtime_skills()
      |> RuntimeDemo.render_prompt()

    assert demo.prompt =~ "You have access to the following skills:"
    assert demo.prompt =~ "demo-runtime-calculator"
    assert demo.prompt =~ "demo-code-review"
    assert demo.prompt =~ "demo-release-notes"
    assert "add" in demo.allowed_tools
    assert "format_release_notes" in demo.allowed_tools
  end
end
