defmodule AgentJido.ContentOps.Actions.LoadPolicyBundle do
  @moduledoc """
  Loads and normalizes the policy bundle from marketing spec files.

  Stub implementation: returns a static policy bundle. Will be replaced
  by a real agent that reads `marketing/` spec files and normalizes them
  via LLM (GLM-5).
  """
  use Jido.Action,
    name: "contentops_load_policy_bundle",
    description: "Loads the policy bundle for content governance",
    schema: [
      run_id: [type: :string, required: true, doc: "Current run identifier"],
      mode: [type: :any, doc: "Run cadence mode"],
      started_at: [type: :any, doc: "Run start timestamp"]
    ]

  @impl true
  def run(%{run_id: run_id} = params, _context) do
    {:ok,
     %{
       run_id: run_id,
       mode: params[:mode],
       started_at: params[:started_at],
       policy_bundle: %{
         run_id: run_id,
         allowed_claims: ["Jido is an Elixir agent framework"],
         voice_constraints: %{tone: :technical, avoided_phrases: ["cutting-edge", "revolutionary"]},
         proof_gates: %{requires_code_example: true},
         loaded_at: DateTime.utc_now()
       }
     }}
  end
end
