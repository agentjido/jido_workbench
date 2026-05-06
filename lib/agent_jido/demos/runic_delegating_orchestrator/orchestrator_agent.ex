defmodule AgentJido.Demos.RunicDelegatingOrchestrator.OrchestratorAgent do
  @moduledoc """
  Deterministic Runic orchestrator that delegates drafting and editing nodes.
  """

  @child_modules %{
    drafter: Jido.Runic.ChildWorker,
    editor: Jido.Runic.ChildWorker
  }

  use Jido.Agent,
    name: "runic_delegating_orchestrator",
    description: "Runs deterministic local and delegated Runic stages with child-worker handoffs",
    strategy: {Jido.Runic.Strategy, workflow_fn: &__MODULE__.build_workflow/0, child_modules: @child_modules},
    schema: []

  alias AgentJido.Demos.RunicResearchStudio.Actions.{
    BuildOutline,
    DraftArticle,
    EditAndAssemble,
    PlanQueries,
    SimulateSearch
  }

  alias Jido.Runic.ActionNode
  alias Runic.Workflow

  @doc false
  @spec plugin_specs() :: [Jido.Plugin.Spec.t()]
  def plugin_specs, do: []

  @doc "Returns the deterministic child-module mapping used by the delegating example."
  @spec child_modules() :: %{drafter: module(), editor: module()}
  def child_modules, do: @child_modules

  @doc "Builds the five-stage delegating workflow DAG."
  @spec build_workflow() :: Runic.Workflow.t()
  def build_workflow do
    draft_node =
      ActionNode.new(DraftArticle, %{}, name: :draft_article, executor: {:child, :drafter})

    edit_node =
      ActionNode.new(EditAndAssemble, %{}, name: :edit_and_assemble, executor: {:child, :editor})

    Workflow.new(name: :delegating_pipeline)
    |> Workflow.add(PlanQueries)
    |> Workflow.add(SimulateSearch, to: :plan_queries, validate: :off)
    |> Workflow.add(BuildOutline, to: :simulate_search, validate: :off)
    |> Workflow.add(draft_node, to: :build_outline, validate: :off)
    |> Workflow.add(edit_node, to: :draft_article, validate: :off)
  end
end
