defmodule AgentJido.ContentOps.RunicStrategyTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentOps.{OrchestratorAgent, RunicStrategy}

  @server_name AgentJido.ContentOps.OrchestratorServer
  @jido_registry AgentJido.Jido.Registry

  setup_all do
    ensure_jido_started()
    ensure_orchestrator_started()
    :ok
  end

  test "declares cadence and run-request routes" do
    routes = RunicStrategy.signal_routes(%{})

    assert {"contentops.tick.hourly", {:strategy_cmd, :contentops_tick_hourly}, 100} in routes
    assert {"contentops.tick.nightly", {:strategy_cmd, :contentops_tick_nightly}, 100} in routes
    assert {"contentops.tick.weekly", {:strategy_cmd, :contentops_tick_weekly}, 100} in routes
    assert {"contentops.tick.monthly", {:strategy_cmd, :contentops_tick_monthly}, 100} in routes
    assert {"contentops.run.requested", {:strategy_cmd, :contentops_run_requested}, 100} in routes
  end

  test "scheduled weekly signal maps to weekly mode" do
    assert :ok = wait_until_ready(20)

    signal = Jido.Signal.new!("contentops.tick.weekly", %{}, source: "/test/runic_strategy")
    :ok = Jido.AgentServer.cast(@server_name, signal)
    {:ok, %{status: :completed}} = Jido.AgentServer.await_completion(@server_name, timeout: 30_000)
    {:ok, server_state} = Jido.AgentServer.state(@server_name)

    report =
      server_state.agent
      |> run_productions()
      |> then(&OrchestratorAgent.run_report(%{productions: &1}))

    assert report.mode == :weekly
  end

  test "contentops.run.requested normalizes string mode payload" do
    assert :ok = wait_until_ready(20)

    signal =
      Jido.Signal.new!(
        "contentops.run.requested",
        %{"mode" => "monthly"},
        source: "/test/runic_strategy"
      )

    :ok = Jido.AgentServer.cast(@server_name, signal)
    {:ok, %{status: :completed}} = Jido.AgentServer.await_completion(@server_name, timeout: 30_000)
    {:ok, server_state} = Jido.AgentServer.state(@server_name)

    report =
      server_state.agent
      |> run_productions()
      |> then(&OrchestratorAgent.run_report(%{productions: &1}))

    assert report.mode == :monthly
  end

  defp run_productions(agent) do
    strat = Jido.Agent.Strategy.State.get(agent)
    Runic.Workflow.raw_productions(strat.workflow)
  end

  defp wait_until_ready(0), do: {:error, :timeout}

  defp wait_until_ready(attempts_left) do
    case OrchestratorAgent.check_ready() do
      :ok ->
        :ok

      {:error, :already_running} ->
        Process.sleep(50)
        wait_until_ready(attempts_left - 1)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp ensure_jido_started do
    case Process.whereis(@jido_registry) do
      pid when is_pid(pid) ->
        {:ok, pid}

      nil ->
        start_supervised!({Jido, name: AgentJido.Jido})
        wait_for_registry(50)
    end
  end

  defp wait_for_registry(0), do: raise("AgentJido.Jido.Registry did not start in time")

  defp wait_for_registry(attempts_left) do
    case Process.whereis(@jido_registry) do
      pid when is_pid(pid) ->
        {:ok, pid}

      nil ->
        Process.sleep(10)
        wait_for_registry(attempts_left - 1)
    end
  end

  defp ensure_orchestrator_started do
    case Process.whereis(@server_name) do
      pid when is_pid(pid) ->
        Process.exit(pid, :kill)
        Process.sleep(25)

      _other ->
        :ok
    end

    Jido.AgentServer.start_link(
      id: @server_name,
      agent: OrchestratorAgent,
      jido: AgentJido.Jido,
      name: @server_name,
      skip_schedules: true
    )
  end
end
