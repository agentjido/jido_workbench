defmodule AgentJido.Demos.RunicResearchStudio.OrchestratorAgent do
  @moduledoc """
  Deterministic Runic orchestrator used by the research studio example pages.
  """

  use Jido.Agent,
    name: "runic_research_studio_orchestrator",
    description: "Runs a deterministic five-node research workflow with Jido.Runic.Strategy",
    strategy: {Jido.Runic.Strategy, workflow_fn: &__MODULE__.build_workflow/0},
    schema: [
      status: [type: {:in, [:idle, :completed, :failed]}, default: :idle]
    ]

  alias AgentJido.Demos.RunicResearchStudio.Actions.{
    BuildOutline,
    DraftArticle,
    EditAndAssemble,
    PlanQueries,
    SimulateSearch
  }

  alias Runic.Workflow

  @doc false
  @spec plugin_specs() :: [Jido.Plugin.Spec.t()]
  def plugin_specs, do: []

  @doc "Builds the deterministic five-stage research DAG."
  @spec build_workflow() :: Runic.Workflow.t()
  def build_workflow do
    Workflow.new(name: :runic_research_studio)
    |> Workflow.add(PlanQueries)
    |> Workflow.add(SimulateSearch, to: :plan_queries)
    |> Workflow.add(BuildOutline, to: :simulate_search)
    |> Workflow.add(DraftArticle, to: :build_outline)
    |> Workflow.add(EditAndAssemble, to: :draft_article)
  end
end
