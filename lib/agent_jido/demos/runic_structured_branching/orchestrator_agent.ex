defmodule AgentJido.Demos.RunicStructuredBranching.OrchestratorAgent do
  @moduledoc """
  Deterministic Runic orchestrator for the structured branching example.
  """

  use Jido.Agent,
    name: "runic_structured_branching_orchestrator",
    description: "Routes questions into deterministic direct, analysis, or safe workflows",
    strategy: {Jido.Runic.Strategy, workflow_fn: &__MODULE__.build_phase_1/0},
    schema: []

  alias AgentJido.Demos.RunicStructuredBranching.Actions.{
    AnalysisAnswer,
    AnalysisPlan,
    DirectAnswer,
    RouteQuestion,
    SafeResponse
  }

  alias Runic.Workflow

  @type route :: :direct | :analysis | :safe

  @doc false
  @spec plugin_specs() :: [Jido.Plugin.Spec.t()]
  def plugin_specs, do: []

  @doc "Builds the phase-1 routing workflow."
  @spec build_phase_1() :: Runic.Workflow.t()
  def build_phase_1 do
    Workflow.new(name: :phase_1_route)
    |> Workflow.add(RouteQuestion)
  end

  @doc "Builds the selected phase-2 branch workflow."
  @spec build_phase_2(route()) :: Runic.Workflow.t()
  def build_phase_2(:direct) do
    Workflow.new(name: :phase_2_direct)
    |> Workflow.add(DirectAnswer)
  end

  def build_phase_2(:analysis) do
    Workflow.new(name: :phase_2_analysis)
    |> Workflow.add(AnalysisPlan)
    |> Workflow.add(AnalysisAnswer, to: :analysis_plan)
  end

  def build_phase_2(:safe) do
    Workflow.new(name: :phase_2_safe)
    |> Workflow.add(SafeResponse)
  end
end
