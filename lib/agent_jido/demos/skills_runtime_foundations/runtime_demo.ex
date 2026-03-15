defmodule AgentJido.Demos.SkillsRuntimeFoundations.RuntimeDemo do
  @moduledoc """
  Deterministic skills runtime walkthrough backed by real module and SKILL.md specs.
  """

  alias AgentJido.Demos.SkillsRuntimeFoundations.CalculatorSkill
  alias Jido.AI.Skill
  alias Jido.AI.Skill.{Loader, Prompt, Registry, Spec}

  @project_root Path.expand("../../../..", __DIR__)
  @skills_root_source_path "priv/skills/skills-runtime-foundations"
  @primary_skill_source_path Path.join(@skills_root_source_path, "demo-code-review/SKILL.md")
  @runtime_skill_names ["demo-runtime-calculator", "demo-code-review", "demo-release-notes"]
  @builder_skill_names [
    "builder-action-scaffold",
    "builder-agent-scaffold",
    "builder-plugin-scaffold",
    "builder-adapter-package",
    "builder-ecosystem-page-author",
    "builder-example-tutorial-author",
    "builder-package-review"
  ]
  @builder_skill_source_paths [
    "priv/skills/builder-action-scaffold/SKILL.md",
    "priv/skills/builder-agent-scaffold/SKILL.md",
    "priv/skills/builder-plugin-scaffold/SKILL.md",
    "priv/skills/builder-adapter-package/SKILL.md",
    "priv/skills/builder-ecosystem-page-author/SKILL.md",
    "priv/skills/builder-example-tutorial-author/SKILL.md",
    "priv/skills/builder-package-review/SKILL.md"
  ]
  @builder_task %{
    title: "Refresh Jido Skill package coverage",
    summary: "Review jido_skill boundaries, tighten the workbench ecosystem page, and outline the next truthful companion example.",
    target_package: "jido_skill",
    reference_paths: [
      "priv/ecosystem/jido_skill.md",
      "priv/pages/docs/learn/multi-agent-orchestration.livemd",
      "priv/examples/jido-ai-skills-runtime-foundations.md"
    ],
    deliverable_paths: [
      "priv/ecosystem/jido_skill.md",
      "priv/examples/jido-ai-skills-runtime-foundations.md"
    ],
    selected_skill_names: [
      "builder-package-review",
      "builder-ecosystem-page-author",
      "builder-example-tutorial-author"
    ]
  }

  defstruct file_manifest: nil,
            module_manifest: nil,
            registry_specs: [],
            prompt: "",
            allowed_tools: [],
            loaded_count: 0,
            builder_specs: [],
            builder_loaded_count: 0,
            builder_prompt: "",
            builder_allowed_tools: [],
            builder_task: @builder_task,
            builder_selected_skill_names: [],
            builder_runtime_targets: [],
            builder_workflow_steps: [],
            builder_boundary_notes: [],
            log: [],
            primary_skill_source_path: @primary_skill_source_path,
            skills_root_source_path: @skills_root_source_path,
            builder_skill_source_paths: @builder_skill_source_paths

  @type log_entry :: %{
          required(:label) => String.t(),
          required(:detail) => String.t()
        }

  @type builder_task :: %{
          required(:title) => String.t(),
          required(:summary) => String.t(),
          required(:target_package) => String.t(),
          required(:reference_paths) => [String.t()],
          required(:deliverable_paths) => [String.t()],
          required(:selected_skill_names) => [String.t()]
        }

  @type builder_workflow_step :: %{
          required(:title) => String.t(),
          required(:detail) => String.t(),
          required(:deliverable) => String.t()
        }

  @type t :: %__MODULE__{
          file_manifest: Spec.t() | nil,
          module_manifest: Spec.t() | nil,
          registry_specs: [Spec.t()],
          prompt: String.t(),
          allowed_tools: [String.t()],
          loaded_count: non_neg_integer(),
          builder_specs: [Spec.t()],
          builder_loaded_count: non_neg_integer(),
          builder_prompt: String.t(),
          builder_allowed_tools: [String.t()],
          builder_task: builder_task(),
          builder_selected_skill_names: [String.t()],
          builder_runtime_targets: [String.t()],
          builder_workflow_steps: [builder_workflow_step()],
          builder_boundary_notes: [String.t()],
          log: [log_entry()],
          primary_skill_source_path: String.t(),
          skills_root_source_path: String.t(),
          builder_skill_source_paths: [String.t()]
        }

  @doc "Builds a new demo state and removes any previously registered demo skills."
  @spec new() :: t()
  def new do
    cleanup_demo_skills()
    refresh(%__MODULE__{})
  end

  @doc "Loads the checked-in file-backed skill manifest without registering it."
  @spec load_file_manifest(t()) :: t()
  def load_file_manifest(%__MODULE__{} = demo) do
    {:ok, spec} = Loader.load(primary_skill_path())

    demo
    |> Map.put(:file_manifest, spec)
    |> append_log("Manifest load", "Loaded #{spec.name} from #{demo.primary_skill_source_path}.")
    |> refresh()
  end

  @doc "Registers the module-backed demo skill into the runtime registry."
  @spec register_module_skill(t()) :: t()
  def register_module_skill(%__MODULE__{} = demo) do
    spec = Skill.manifest(CalculatorSkill)
    :ok = Registry.register(spec)

    demo
    |> Map.put(:module_manifest, spec)
    |> append_log("Module register", "Registered #{spec.name} into the runtime registry.")
    |> refresh()
  end

  @doc "Loads the checked-in SKILL.md fixtures from the demo skills directory."
  @spec load_runtime_skills(t()) :: t()
  def load_runtime_skills(%__MODULE__{} = demo) do
    {:ok, count} = Registry.load_from_paths([skills_root_path()])

    demo
    |> Map.put(:loaded_count, count)
    |> append_log("Registry load", "Loaded #{count} SKILL.md file(s) from #{demo.skills_root_source_path}.")
    |> refresh()
  end

  @doc "Loads the checked-in builder skill catalog for contributor workflows."
  @spec load_builder_catalog(t()) :: t()
  def load_builder_catalog(%__MODULE__{} = demo) do
    {:ok, count} = Registry.load_from_paths(builder_skill_paths())

    demo
    |> Map.put(:builder_loaded_count, count)
    |> append_log(
      "Builder catalog",
      "Loaded #{count} builder SKILL.md file(s) from priv/skills/builder-*/SKILL.md."
    )
    |> refresh()
  end

  @doc "Renders the combined prompt for the currently registered demo skills."
  @spec render_prompt(t()) :: t()
  def render_prompt(%__MODULE__{} = demo) do
    demo = refresh(demo)

    case demo.registry_specs do
      [] ->
        demo
        |> Map.put(:prompt, "")
        |> Map.put(:allowed_tools, [])
        |> append_log("Prompt render", "Register the demo skills before rendering the prompt.")
        |> refresh()

      specs ->
        prompt = Prompt.render(specs, include_body: true)
        allowed_tools = Prompt.collect_allowed_tools(specs)

        demo
        |> Map.put(:prompt, prompt)
        |> Map.put(:allowed_tools, allowed_tools)
        |> append_log(
          "Prompt render",
          "Rendered a prompt for #{length(specs)} skill(s) with #{length(allowed_tools)} allowed tool(s)."
        )
        |> refresh()
    end
  end

  @doc "Runs one real workbench builder workflow against the checked-in jido_skill package page."
  @spec run_builder_workflow(t()) :: t()
  def run_builder_workflow(%__MODULE__{} = demo) do
    demo =
      case demo.builder_specs do
        [] -> load_builder_catalog(demo)
        _specs -> refresh(demo)
      end

    selected_skill_names = demo.builder_task.selected_skill_names
    selected_specs = resolve_specs(selected_skill_names)
    builder_prompt = Prompt.render(selected_specs, include_body: true)
    builder_allowed_tools = Prompt.collect_allowed_tools(selected_specs)

    demo
    |> Map.put(:builder_selected_skill_names, selected_skill_names)
    |> Map.put(:builder_prompt, builder_prompt)
    |> Map.put(:builder_allowed_tools, builder_allowed_tools)
    |> Map.put(:builder_runtime_targets, metadata_values(selected_specs, "intended_runtimes"))
    |> Map.put(:builder_boundary_notes, metadata_values(selected_specs, "boundary"))
    |> Map.put(:builder_workflow_steps, build_builder_workflow_steps(selected_specs, demo.builder_task))
    |> append_log(
      "Builder workflow",
      "Rendered a builder workflow for #{demo.builder_task.target_package} using #{length(selected_specs)} catalog skill(s)."
    )
    |> refresh()
  end

  @doc "Removes the demo skills from the registry and restores the initial state."
  @spec reset(t()) :: t()
  def reset(%__MODULE__{}) do
    cleanup_demo_skills()

    %__MODULE__{}
    |> append_log("Reset", "Cleared the demo skills from the runtime registry.")
    |> refresh()
  end

  defp refresh(%__MODULE__{} = demo) do
    %{
      demo
      | registry_specs: resolve_specs(@runtime_skill_names ++ @builder_skill_names),
        builder_specs: resolve_specs(@builder_skill_names)
    }
  end

  defp cleanup_demo_skills do
    :ok = Registry.ensure_started()

    Enum.each(@runtime_skill_names ++ @builder_skill_names, fn name ->
      try do
        case Registry.unregister(name) do
          :ok -> :ok
          {:error, _reason} -> :ok
        end
      catch
        :exit, _reason -> :ok
      end
    end)
  end

  defp resolve_specs(names) do
    Enum.flat_map(names, fn name ->
      case Registry.lookup(name) do
        {:ok, spec} -> [spec]
        {:error, _reason} -> []
      end
    end)
  end

  defp build_builder_workflow_steps(selected_specs, builder_task) do
    Enum.map(selected_specs, fn spec ->
      case spec.name do
        "builder-package-review" ->
          %{
            title: "Review #{builder_task.target_package} package boundaries",
            detail: "Separate package-repo findings from workbench follow-up items before any docs changes land.",
            deliverable: "package review findings + docs-gap summary"
          }

        "builder-ecosystem-page-author" ->
          %{
            title: "Refresh #{builder_task.target_package} ecosystem page copy",
            detail: "Update boundary lines, limitations, and companion links in #{Enum.at(builder_task.deliverable_paths, 0)}.",
            deliverable: "ecosystem page refresh"
          }

        "builder-example-tutorial-author" ->
          %{
            title: "Outline the next truthful companion example",
            detail:
              "Turn the package source into a deterministic follow-up example or tutorial plan in #{Enum.at(builder_task.deliverable_paths, 1)}.",
            deliverable: "example or tutorial outline"
          }

        _other ->
          %{
            title: spec.name,
            detail: spec.description,
            deliverable: "builder workflow step"
          }
      end
    end)
  end

  defp metadata_values(specs, key) do
    specs
    |> Enum.flat_map(fn spec ->
      case spec.metadata do
        %{} = metadata -> metadata |> Map.get(key, "") |> metadata_list()
        _other -> []
      end
    end)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end

  defp metadata_list(values) when is_list(values), do: values

  defp metadata_list(value) when is_binary(value) do
    value
    |> String.split(",")
    |> Enum.map(&String.trim/1)
  end

  defp metadata_list(_other), do: []

  defp primary_skill_path, do: Path.join(@project_root, @primary_skill_source_path)
  defp skills_root_path, do: Path.join(@project_root, @skills_root_source_path)
  defp builder_skill_paths, do: Enum.map(@builder_skill_source_paths, &Path.join(@project_root, &1))

  defp append_log(%__MODULE__{} = demo, label, detail) do
    entry = %{label: label, detail: detail}
    %{demo | log: [entry | demo.log] |> Enum.take(30)}
  end
end
