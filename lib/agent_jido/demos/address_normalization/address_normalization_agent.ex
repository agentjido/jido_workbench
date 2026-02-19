defmodule AgentJido.Demos.AddressNormalizationAgent do
  @moduledoc """
  Demo agent for deterministic US address normalization.

  This agent is intentionally small and focused on one learning goal:
  action contracts and validation.
  """
  use Jido.Agent,
    name: "address_normalization_agent",
    description: "Normalizes a US address with strict action contracts",
    schema: [
      last_input: [type: :map, default: %{}],
      normalized: [type: :map, default: %{}],
      normalized_address: [type: :string, default: ""],
      last_status: [type: {:in, [:idle, :ok, :error]}, default: :idle],
      validation_errors: [type: {:list, :string}, default: []],
      successful_runs: [type: :integer, default: 0]
    ]

  alias AgentJido.Demos.AddressNormalization.{ExecuteAction, ResetAction}

  @impl true
  def signal_routes(_ctx) do
    [
      {"address.normalize.execute", ExecuteAction},
      {"address.normalize.reset", ResetAction}
    ]
  end
end
