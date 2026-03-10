defmodule AgentJido.JidoActionLoggingRegressionTest do
  use ExUnit.Case, async: true

  alias Jido.Exec.Telemetry

  @moduledoc false

  defmodule CounterAgent do
    use Jido.Agent,
      name: "counter_agent",
      description: "Tracks a simple counter",
      schema:
        Zoi.object(%{
          count: Zoi.integer() |> Zoi.default(0)
        })
  end

  defmodule IncrementAction do
    use Jido.Action,
      name: "increment",
      description: "Increments the counter by a specified amount",
      schema:
        Zoi.object(%{
          by: Zoi.integer() |> Zoi.default(1)
        })

    @impl true
    def run(params, context) do
      current = Map.get(context.state, :count, 0)
      {:ok, %{count: current + params.by}}
    end
  end

  @tag skip: "Unskip after the next jido_action Hex release includes the safe_inspect fix for Zoi-backed action metadata."
  test "sanitized action metadata with Zoi object schemas stays inspect-safe" do
    context = %{
      state: %{count: 0},
      action_metadata: IncrementAction.__action_metadata__()
    }

    inspected =
      context
      |> Telemetry.sanitize_value()
      |> inspect(charlists: :as_lists, printable_limit: :infinity, limit: :infinity)

    refute inspected =~ "#Inspect.Error<"
    refute inspected =~ "FunctionClauseError"
    assert inspected =~ "Zoi.Types.Map"
  end

  test "counter command still executes with Zoi object schemas" do
    agent = CounterAgent.new()
    {updated_agent, directives} = CounterAgent.cmd(agent, {IncrementAction, %{by: 3}})

    assert updated_agent.state == %{count: 3}
    assert directives == []
  end
end
