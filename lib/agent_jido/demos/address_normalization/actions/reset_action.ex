defmodule AgentJido.Demos.AddressNormalization.ResetAction do
  @moduledoc """
  Resets the address-normalization demo state.
  """
  use Jido.Action,
    name: "address_normalization_reset",
    description: "Resets normalized output and validation state",
    schema: []

  alias Jido.Agent.StateOp

  @impl true
  def run(_params, _context) do
    reset_state = %{
      last_input: %{},
      normalized: %{},
      normalized_address: "",
      last_status: :idle,
      validation_errors: [],
      successful_runs: 0
    }

    {:ok, %{}, StateOp.replace_state(reset_state)}
  end
end
