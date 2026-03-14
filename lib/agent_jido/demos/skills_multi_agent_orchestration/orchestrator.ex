defmodule AgentJido.Demos.SkillsMultiAgentOrchestration.Orchestrator do
  @moduledoc """
  Deterministic orchestration walkthrough backed by module and file-loaded skills.
  """

  alias AgentJido.Demos.SkillsMultiAgentOrchestration.{
    ArithmeticSkill,
    ConversionSpecialist,
    EndurancePlannerSkill
  }

  alias Jido.AI.Skill
  alias Jido.AI.Skill.{Prompt, Registry, Spec}

  @project_root Path.expand("../../../..", __DIR__)
  @skills_root_source_path "priv/skills/skills-multi-agent-orchestration"
  @unit_converter_source_path Path.join(@skills_root_source_path, "demo-unit-converter/SKILL.md")
  @demo_skill_names ["demo-orchestrator-arithmetic", "demo-unit-converter", "demo-endurance-planner"]

  @scenario_requests %{
    arithmetic: %{
      label: "Arithmetic",
      question: "What is 42 * 17 + 100?"
    },
    conversion: %{
      label: "Conversion",
      question: "Convert 98.6 degrees Fahrenheit to Celsius."
    },
    combined: %{
      label: "Combined",
      question: "If I run 5 kilometers, how many miles is that? Then estimate calories at 100 calories per mile."
    }
  }

  defstruct registry_specs: [],
            loaded_count: 0,
            last_run: nil,
            history: [],
            skills_root_source_path: @skills_root_source_path,
            unit_converter_source_path: @unit_converter_source_path

  @type log_entry :: %{
          required(:label) => String.t(),
          required(:detail) => String.t()
        }

  @type run_result :: %{
          required(:scenario) => atom(),
          required(:label) => String.t(),
          required(:question) => String.t(),
          required(:route) => String.t(),
          required(:selected_skills) => [Spec.t()],
          required(:selected_skill_names) => [String.t()],
          required(:tool_trace) => [map()],
          required(:response) => String.t(),
          required(:prompt) => String.t()
        }

  @type t :: %__MODULE__{
          registry_specs: [Spec.t()],
          loaded_count: non_neg_integer(),
          last_run: run_result() | nil,
          history: [log_entry()],
          skills_root_source_path: String.t(),
          unit_converter_source_path: String.t()
        }

  @doc "Builds a new orchestrator state with the demo specialist skills preloaded."
  @spec new() :: t()
  def new do
    cleanup_demo_skills()

    %__MODULE__{}
    |> bootstrap_demo_skills()
    |> append_history("Bootstrap", "Registered 2 module skills and loaded 1 file-backed conversion skill.")
    |> refresh()
  end

  @doc "Runs one of the fixed public demo scenarios through the deterministic router."
  @spec run_scenario(t(), :arithmetic | :conversion | :combined) :: t()
  def run_scenario(%__MODULE__{} = demo, scenario) when scenario in [:arithmetic, :conversion, :combined] do
    demo = ensure_bootstrapped(demo)
    request = Map.fetch!(@scenario_requests, scenario)

    {selected_skill_names, route, tool_trace, response} =
      case scenario do
        :arithmetic ->
          arithmetic = ArithmeticSkill.run_demo_request()

          {
            [arithmetic.skill_name],
            "Router matched an arithmetic-only request and delegated it to the arithmetic specialist.",
            arithmetic.tool_trace,
            arithmetic.response
          }

        :conversion ->
          conversion = ConversionSpecialist.convert_demo_temperature()

          {
            [conversion.skill_name],
            "Router matched a unit conversion request and delegated it to the file-backed unit converter skill.",
            conversion.tool_trace,
            conversion.response
          }

        :combined ->
          conversion = ConversionSpecialist.convert_demo_distance()
          endurance = EndurancePlannerSkill.estimate_demo_run(conversion.miles, 100)
          miles = :erlang.float_to_binary(conversion.miles, decimals: 2)

          {
            [conversion.skill_name, endurance.skill_name],
            "Router detected a compound request and composed the unit converter with the endurance planner specialist.",
            conversion.tool_trace ++ endurance.tool_trace,
            "Combined route converted 5.0 kilometers to #{miles} miles and estimated about #{endurance.calories} calories at 100 calories per mile."
          }
      end

    selected_specs = Enum.map(selected_skill_names, &Skill.manifest/1)

    last_run = %{
      scenario: scenario,
      label: request.label,
      question: request.question,
      route: route,
      selected_skills: selected_specs,
      selected_skill_names: selected_skill_names,
      tool_trace: tool_trace,
      response: response,
      prompt:
        Prompt.render(selected_specs,
          include_body: false,
          header: "Selected skills for this request:"
        )
    }

    demo
    |> Map.put(:last_run, last_run)
    |> append_history(request.label, response)
    |> refresh()
  end

  @doc "Restores the initial bootstrapped orchestrator state."
  @spec reset(t()) :: t()
  def reset(%__MODULE__{}) do
    cleanup_demo_skills()

    %__MODULE__{}
    |> bootstrap_demo_skills()
    |> append_history("Reset", "Reset the orchestrator and reloaded the demo specialist skills.")
    |> refresh()
  end

  defp ensure_bootstrapped(%__MODULE__{registry_specs: []} = demo), do: bootstrap_demo_skills(demo)
  defp ensure_bootstrapped(%__MODULE__{} = demo), do: demo

  defp bootstrap_demo_skills(%__MODULE__{} = demo) do
    :ok = Registry.ensure_started()
    :ok = Registry.register(Skill.manifest(ArithmeticSkill))
    :ok = Registry.register(Skill.manifest(EndurancePlannerSkill))
    {:ok, count} = Registry.load_from_paths([unit_converter_root_path()])

    demo
    |> Map.put(:loaded_count, count)
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

  defp unit_converter_root_path, do: Path.join(@project_root, @skills_root_source_path)

  defp append_history(%__MODULE__{} = demo, label, detail) do
    entry = %{label: label, detail: detail}
    %{demo | history: [entry | demo.history] |> Enum.take(30)}
  end
end
