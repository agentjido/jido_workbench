defmodule AgentJido.Demos.DemandTrackerAgentTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.DemandTrackerAgent
  alias AgentJido.Demos.Demand.{BoostAction, CleanupAction, CoolAction, DecayAction, HeartbeatAction}

  describe "DemandTrackerAgent.new/0" do
    test "creates agent with default state" do
      agent = DemandTrackerAgent.new()
      assert agent.state.demand == 50
      assert agent.state.ticks == 0
      assert agent.state.listing_id == "demo-listing"
    end
  end

  describe "DemandTrackerAgent schedules" do
    test "declares heartbeat and cleanup schedules" do
      schedules =
        DemandTrackerAgent.plugin_schedules()
        |> Enum.filter(fn schedule -> match?({:agent_schedule, _, _}, schedule.job_id) end)

      assert length(schedules) == 2

      assert Enum.any?(schedules, fn schedule ->
               schedule.cron_expression == "*/5 * * * *" and
                 schedule.signal_type == "heartbeat.tick" and
                 schedule.job_id == {:agent_schedule, "demand_tracker", :heartbeat} and
                 schedule.timezone == "Etc/UTC"
             end)

      assert Enum.any?(schedules, fn schedule ->
               schedule.cron_expression == "@daily" and
                 schedule.signal_type == "cleanup.run" and
                 schedule.job_id == {:agent_schedule, "demand_tracker", :cleanup} and
                 schedule.timezone == "America/New_York"
             end)
    end
  end

  describe "BoostAction" do
    test "increases demand by default amount" do
      agent = DemandTrackerAgent.new()
      {agent, directives} = DemandTrackerAgent.cmd(agent, BoostAction)
      assert agent.state.demand == 60
      assert agent.state.last_updated_at != nil
      # Should emit a domain event
      assert [%Jido.Agent.Directive.Emit{signal: signal}] = directives
      assert signal.type == "listing.demand.changed"
    end

    test "increases demand by custom amount" do
      agent = DemandTrackerAgent.new()
      {agent, directives} = DemandTrackerAgent.cmd(agent, {BoostAction, %{amount: 25}})
      assert agent.state.demand == 75
      assert [%Jido.Agent.Directive.Emit{}] = directives
    end

    test "caps demand at 100" do
      agent = DemandTrackerAgent.new()
      {agent, _} = DemandTrackerAgent.cmd(agent, {BoostAction, %{amount: 60}})
      assert agent.state.demand == 100
    end

    test "emit signal contains correct data" do
      agent = DemandTrackerAgent.new()

      {_agent, [%Jido.Agent.Directive.Emit{signal: signal}]} =
        DemandTrackerAgent.cmd(agent, BoostAction)

      assert signal.data.previous == 50
      assert signal.data.current == 60
      assert signal.data.delta == 10
      assert signal.data.reason == :boost
      assert signal.data.listing_id == "demo-listing"
    end
  end

  describe "CoolAction" do
    test "decreases demand by default amount" do
      agent = DemandTrackerAgent.new()
      {agent, directives} = DemandTrackerAgent.cmd(agent, CoolAction)
      assert agent.state.demand == 40
      assert [%Jido.Agent.Directive.Emit{signal: signal}] = directives
      assert signal.data.reason == :cool
    end

    test "floors demand at 0" do
      agent = DemandTrackerAgent.new()
      {agent, _} = DemandTrackerAgent.cmd(agent, {CoolAction, %{amount: 60}})
      assert agent.state.demand == 0
    end
  end

  describe "HeartbeatAction" do
    test "matches decay behavior for scheduled heartbeat ticks" do
      agent = DemandTrackerAgent.new()
      {agent, directives} = DemandTrackerAgent.cmd(agent, HeartbeatAction)

      assert agent.state.demand == 48
      assert agent.state.ticks == 1
      assert [%Jido.Agent.Directive.Emit{}] = directives
    end
  end

  describe "CleanupAction" do
    test "resets tick count during scheduled cleanup" do
      agent = DemandTrackerAgent.new()
      {agent, _} = DemandTrackerAgent.cmd(agent, DecayAction)
      {agent, _} = DemandTrackerAgent.cmd(agent, DecayAction)

      assert agent.state.ticks == 2

      {agent, directives} = DemandTrackerAgent.cmd(agent, CleanupAction)

      assert agent.state.ticks == 0
      assert agent.state.last_updated_at != nil
      assert directives == []
    end
  end

  describe "DecayAction" do
    test "decays demand by 2" do
      agent = DemandTrackerAgent.new()
      {agent, directives} = DemandTrackerAgent.cmd(agent, DecayAction)
      assert agent.state.demand == 48
      assert agent.state.ticks == 1
      # Should emit since demand changed
      assert [%Jido.Agent.Directive.Emit{}] = directives
    end

    test "increments tick counter" do
      agent = DemandTrackerAgent.new()
      {agent, _} = DemandTrackerAgent.cmd(agent, DecayAction)
      {agent, _} = DemandTrackerAgent.cmd(agent, DecayAction)
      assert agent.state.ticks == 2
    end

    test "floors demand at 0" do
      agent = DemandTrackerAgent.new()
      # Set demand low first
      {agent, _} = DemandTrackerAgent.cmd(agent, {CoolAction, %{amount: 49}})
      assert agent.state.demand == 1
      {agent, _} = DemandTrackerAgent.cmd(agent, DecayAction)
      assert agent.state.demand == 0
    end

    test "no emit directive when demand is already 0" do
      agent = DemandTrackerAgent.new()
      {agent, _} = DemandTrackerAgent.cmd(agent, {CoolAction, %{amount: 50}})
      assert agent.state.demand == 0
      {_agent, directives} = DemandTrackerAgent.cmd(agent, DecayAction)
      # No emit when demand doesn't change
      emit_directives = Enum.filter(directives, &match?(%Jido.Agent.Directive.Emit{}, &1))
      assert emit_directives == []
    end
  end

  describe "combined operations" do
    test "boost then decay" do
      agent = DemandTrackerAgent.new()
      {agent, _} = DemandTrackerAgent.cmd(agent, {BoostAction, %{amount: 20}})
      assert agent.state.demand == 70
      {agent, _} = DemandTrackerAgent.cmd(agent, DecayAction)
      assert agent.state.demand == 68
    end
  end
end
