defmodule AgentJido.Demos.EmitDirective.MultiEmitAction do
  @moduledoc """
  Emits a batch of synthetic events in a single action execution.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "multi_emit",
    description: "Emits multiple batch.event signals",
    schema: [
      event_count: [type: :integer, default: 3]
    ]

  @impl true
  def run(%{event_count: event_count}, _context) do
    emissions =
      for idx <- 1..event_count do
        signal = Signal.new!("batch.event", %{index: idx}, source: "/emit")
        %Directive.Emit{signal: signal}
      end

    {:ok, %{emitted_count: event_count}, emissions}
  end
end
