defmodule AgentJido.Demos.CounterAgentTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.CounterAgent
  alias AgentJido.Demos.Counter.{IncrementAction, DecrementAction, ResetAction}

  describe "CounterAgent.new/0" do
    test "creates agent with default state" do
      agent = CounterAgent.new()
      assert agent.state.count == 0
    end
  end

  describe "IncrementAction" do
    test "increments count by 1" do
      agent = CounterAgent.new()
      {agent, _directives} = CounterAgent.cmd(agent, {IncrementAction, %{by: 1}})
      assert agent.state.count == 1
    end

    test "increments count by custom amount" do
      agent = CounterAgent.new()
      {agent, _directives} = CounterAgent.cmd(agent, {IncrementAction, %{by: 5}})
      assert agent.state.count == 5
    end

    test "accumulates multiple increments" do
      agent = CounterAgent.new()
      {agent, _} = CounterAgent.cmd(agent, {IncrementAction, %{by: 3}})
      {agent, _} = CounterAgent.cmd(agent, {IncrementAction, %{by: 2}})
      assert agent.state.count == 5
    end
  end

  describe "DecrementAction" do
    test "decrements count by 1" do
      agent = CounterAgent.new()
      {agent, _} = CounterAgent.cmd(agent, {IncrementAction, %{by: 5}})
      {agent, _} = CounterAgent.cmd(agent, {DecrementAction, %{by: 1}})
      assert agent.state.count == 4
    end

    test "can go negative" do
      agent = CounterAgent.new()
      {agent, _} = CounterAgent.cmd(agent, {DecrementAction, %{by: 3}})
      assert agent.state.count == -3
    end
  end

  describe "ResetAction" do
    test "resets count to 0" do
      agent = CounterAgent.new()
      {agent, _} = CounterAgent.cmd(agent, {IncrementAction, %{by: 42}})
      {agent, _} = CounterAgent.cmd(agent, {ResetAction, %{}})
      assert agent.state.count == 0
    end
  end

  describe "signal_routes" do
    test "maps signal types to actions" do
      agent = CounterAgent.new()
      routes = CounterAgent.signal_routes(%{agent: agent})
      assert {"counter.increment", IncrementAction} in routes
      assert {"counter.decrement", DecrementAction} in routes
      assert {"counter.reset", ResetAction} in routes
    end
  end
end
