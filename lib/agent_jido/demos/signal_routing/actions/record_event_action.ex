defmodule AgentJido.Demos.SignalRouting.RecordEventAction do
  @moduledoc """
  Records a typed event in agent state.
  """

  use Jido.Action,
    name: "record_event",
    description: "Records an event payload",
    schema: [
      event_type: [type: :string, required: true, doc: "Event type label"],
      payload: [type: :map, default: %{}, doc: "Event payload map"]
    ]

  @impl true
  @spec run(map(), map()) :: {:ok, map()}
  def run(%{event_type: event_type, payload: payload}, context) do
    events = Map.get(context.state, :events, [])

    event = %{
      type: event_type,
      payload: payload,
      recorded_at: DateTime.utc_now()
    }

    {:ok, %{events: [event | events]}}
  end
end
