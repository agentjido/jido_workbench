defmodule AgentJido.Demos.RunicAdaptiveResearcher.OrchestratorAgent do
  @moduledoc """
  Deterministic Runic orchestrator for the adaptive researcher example.
  """

  use Jido.Agent,
    name: "runic_adaptive_researcher_orchestrator",
    description: "Runs deterministic phase selection and workflow hot-swapping based on research richness",
    strategy: {Jido.Runic.Strategy, workflow_fn: &__MODULE__.build_phase_1/0},
    schema: []

  alias AgentJido.Demos.RunicAdaptiveResearcher.Actions.{
    BuildOutline,
    DraftArticle,
    EditAndAssemble,
    PlanQueries,
    SimulateSearch
  }

  alias Runic.Workflow

  @rich_threshold 180

  @doc false
  @spec plugin_specs() :: [Jido.Plugin.Spec.t()]
  def plugin_specs, do: []

  @doc "Builds the phase-1 research workflow."
  @spec build_phase_1() :: Runic.Workflow.t()
  def build_phase_1 do
    Workflow.new(name: :phase_1_research)
    |> Workflow.add(PlanQueries)
    |> Workflow.add(SimulateSearch, to: :plan_queries, validate: :off)
  end

  @doc "Builds the selected phase-2 workflow based on research summary richness."
  @spec build_phase_2([map()]) :: Runic.Workflow.t()
  def build_phase_2(productions) do
    if rich_research?(productions) do
      Workflow.new(name: :phase_2_full)
      |> Workflow.add(BuildOutline)
      |> Workflow.add(DraftArticle, to: :build_outline, validate: :off)
      |> Workflow.add(EditAndAssemble, to: :draft_article, validate: :off)
    else
      Workflow.new(name: :phase_2_slim)
      |> Workflow.add(DraftArticle)
      |> Workflow.add(EditAndAssemble, to: :draft_article, validate: :off)
    end
  end

  @doc "Returns the phase selection label for the current research results."
  @spec phase_2_type([map()]) :: :full | :slim
  def phase_2_type(productions) do
    if rich_research?(productions), do: :full, else: :slim
  end

  @doc "Returns the summary-length threshold that decides between the full and slim workflows."
  @spec rich_threshold() :: pos_integer()
  def rich_threshold, do: @rich_threshold

  defp rich_research?(productions) do
    productions
    |> Enum.find_value("", fn
      %{research_summary: summary} when is_binary(summary) -> summary
      _ -> nil
    end)
    |> String.length()
    |> Kernel.>=(rich_threshold())
  end
end
