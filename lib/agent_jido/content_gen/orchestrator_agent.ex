defmodule AgentJido.ContentGen.OrchestratorAgent do
  @moduledoc """
  Runic orchestrator for single-entry content generation.
  """

  use Jido.Agent,
    name: "content_gen_orchestrator",
    description: "Orchestrates content generation for one selected content-plan entry",
    strategy: {Jido.Runic.Strategy, workflow_fn: &__MODULE__.build_workflow/0},
    schema: []

  alias AgentJido.ContentGen.Actions.{
    AuditAndGate,
    BuildEntryContext,
    GenerateDraftEnvelope,
    GenerateStructurePlan,
    LoadExisting,
    ParseAndAssembleCandidate,
    PersistAndFinalize,
    ResolveTarget,
    VerifyIfRequested
  }

  alias Runic.Workflow

  @doc false
  @spec plugin_specs() :: [Jido.Plugin.Spec.t()]
  def plugin_specs, do: []

  @doc """
  Build the explicit one-entry content generation workflow.
  """
  @spec build_workflow() :: struct()
  def build_workflow do
    Workflow.new(name: :content_gen_entry_pipeline)
    |> Workflow.add(BuildEntryContext)
    |> Workflow.add(ResolveTarget, to: :build_entry_context)
    |> Workflow.add(LoadExisting, to: :resolve_target)
    |> Workflow.add(GenerateStructurePlan, to: :load_existing)
    |> Workflow.add(GenerateDraftEnvelope, to: :generate_structure_plan)
    |> Workflow.add(ParseAndAssembleCandidate, to: :generate_draft_envelope)
    |> Workflow.add(AuditAndGate, to: :parse_and_assemble_candidate)
    |> Workflow.add(VerifyIfRequested, to: :audit_and_gate)
    |> Workflow.add(PersistAndFinalize, to: :verify_if_requested)
  end
end
