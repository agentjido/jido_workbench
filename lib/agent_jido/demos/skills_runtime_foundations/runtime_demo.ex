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
  @demo_skill_names ["demo-runtime-calculator", "demo-code-review", "demo-release-notes"]

  defstruct file_manifest: nil,
            module_manifest: nil,
            registry_specs: [],
            prompt: "",
            allowed_tools: [],
            loaded_count: 0,
            log: [],
            primary_skill_source_path: @primary_skill_source_path,
            skills_root_source_path: @skills_root_source_path

  @type log_entry :: %{
          required(:label) => String.t(),
          required(:detail) => String.t()
        }

  @type t :: %__MODULE__{
          file_manifest: Spec.t() | nil,
          module_manifest: Spec.t() | nil,
          registry_specs: [Spec.t()],
          prompt: String.t(),
          allowed_tools: [String.t()],
          loaded_count: non_neg_integer(),
          log: [log_entry()],
          primary_skill_source_path: String.t(),
          skills_root_source_path: String.t()
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

  @doc "Removes the demo skills from the registry and restores the initial state."
  @spec reset(t()) :: t()
  def reset(%__MODULE__{}) do
    cleanup_demo_skills()

    %__MODULE__{}
    |> append_log("Reset", "Cleared the demo skills from the runtime registry.")
    |> refresh()
  end

  defp refresh(%__MODULE__{} = demo) do
    registry_specs =
      @demo_skill_names
      |> Enum.flat_map(fn name ->
        case Registry.lookup(name) do
          {:ok, spec} -> [spec]
          {:error, _reason} -> []
        end
      end)

    %{demo | registry_specs: registry_specs}
  end

  defp cleanup_demo_skills do
    :ok = Registry.ensure_started()

    Enum.each(@demo_skill_names, fn name ->
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

  defp primary_skill_path, do: Path.join(@project_root, @primary_skill_source_path)
  defp skills_root_path, do: Path.join(@project_root, @skills_root_source_path)

  defp append_log(%__MODULE__{} = demo, label, detail) do
    entry = %{label: label, detail: detail}
    %{demo | log: [entry | demo.log] |> Enum.take(30)}
  end
end
