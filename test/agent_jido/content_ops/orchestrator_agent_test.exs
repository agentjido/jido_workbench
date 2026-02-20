defmodule AgentJido.ContentOps.OrchestratorAgentTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentOps.OrchestratorAgent

  alias AgentJido.ContentOps.Actions.{
    BuildRunContext,
    LoadPolicyBundle,
    SelectWork,
    CollectChangeRequests,
    DeliverySink,
    PublishRunReport
  }

  @server_name AgentJido.ContentOps.OrchestratorServer
  @jido_registry AgentJido.Jido.Registry

  setup_all do
    ensure_jido_started()
    ensure_orchestrator_started()
    :ok
  end

  describe "OrchestratorAgent.new/0" do
    test "creates agent with default state" do
      agent = OrchestratorAgent.new()
      assert agent.state.last_run_id == nil
      assert agent.state.last_run_mode == nil
      assert agent.state.last_run_at == nil
      assert agent.state.total_runs == 0
    end
  end

  describe "OrchestratorAgent schedules" do
    test "does not declare plugin schedules while cadence scheduling is disabled" do
      schedules =
        OrchestratorAgent.plugin_schedules()
        |> Enum.filter(fn schedule -> match?({:agent_schedule, _, _}, schedule.job_id) end)

      assert schedules == []
    end
  end

  describe "build_workflow/0" do
    test "builds a valid workflow" do
      workflow = OrchestratorAgent.build_workflow()
      assert workflow != nil
    end
  end

  describe "BuildRunContext" do
    test "creates run context with default hourly mode" do
      {:ok, result} = BuildRunContext.run(%{mode: :hourly}, %{state: %{}})
      assert result.run_id =~ ~r/^run_[0-9a-f]{16}$/
      assert result.mode == :hourly
      assert result.status == :running
      assert %DateTime{} = result.started_at
    end

    test "creates run context with weekly mode" do
      {:ok, result} = BuildRunContext.run(%{mode: :weekly}, %{state: %{}})
      assert result.mode == :weekly
    end
  end

  describe "LoadPolicyBundle" do
    test "returns a stub policy bundle" do
      {:ok, result} = LoadPolicyBundle.run(%{run_id: "run_test123"}, %{state: %{}})
      assert result.policy_bundle.run_id == "run_test123"
      assert is_list(result.policy_bundle.allowed_claims)
      assert is_map(result.policy_bundle.voice_constraints)
    end
  end

  describe "SelectWork" do
    test "returns work orders for weekly mode" do
      {:ok, result} = SelectWork.run(%{run_id: "run_test123", mode: :weekly}, %{state: %{}})
      assert length(result.work_orders) == 1
      [order] = result.work_orders
      assert order.kind == :docs
      assert order.run_id == "run_test123"
      assert is_float(order.priority_score)
    end

    test "returns empty work orders for hourly mode" do
      {:ok, result} = SelectWork.run(%{run_id: "run_test123", mode: :hourly}, %{state: %{}})
      assert result.work_orders == []
    end

    test "returns empty work orders for nightly mode" do
      {:ok, result} = SelectWork.run(%{run_id: "run_test123", mode: :nightly}, %{state: %{}})
      assert result.work_orders == []
    end

    test "returns work orders for monthly mode" do
      {:ok, result} = SelectWork.run(%{run_id: "run_test123", mode: :monthly}, %{state: %{}})
      assert length(result.work_orders) == 1
    end
  end

  describe "CollectChangeRequests" do
    test "builds change requests from work orders" do
      work_orders = [
        %{id: "wo_test", kind: :docs, slug: "docs/test", priority_score: 0.85}
      ]

      {:ok, result} =
        CollectChangeRequests.run(
          %{run_id: "run_test123", work_orders: work_orders, mode: :weekly},
          %{state: %{}}
        )

      assert result.change_request_count == 1
      [cr] = result.change_requests
      assert cr.type == "content.change_request"
      assert cr.run_id == "run_test123"
      assert length(cr.changes) == 1
      assert hd(cr.changes).op == :create
      assert hd(cr.changes).path == "priv/pages/docs/docs/test.md"
    end

    test "returns empty change requests when no work orders" do
      {:ok, result} =
        CollectChangeRequests.run(
          %{run_id: "run_test123", work_orders: [], mode: :hourly},
          %{state: %{}}
        )

      assert result.change_request_count == 0
      assert result.change_requests == []
    end
  end

  describe "DeliverySink" do
    test "records change requests and returns receipts" do
      change_requests = [
        %{
          type: "content.change_request",
          run_id: "run_test123",
          changes: [%{op: :create, path: "test.md", content: "test"}],
          related_plan_slug: "docs/test"
        }
      ]

      {:ok, result} =
        DeliverySink.run(
          %{run_id: "run_test123", change_requests: change_requests},
          %{state: %{}}
        )

      assert result.delivered_count == 1
      [receipt] = result.delivery_receipts
      assert receipt.run_id == "run_test123"
      assert receipt.slug == "docs/test"
      assert receipt.status == :recorded
      assert receipt.pr_url == nil
    end

    test "handles empty change requests" do
      {:ok, result} =
        DeliverySink.run(
          %{run_id: "run_test123", change_requests: []},
          %{state: %{}}
        )

      assert result.delivered_count == 0
      assert result.delivery_receipts == []
    end
  end

  describe "PublishRunReport" do
    test "publishes run completion report" do
      # Subscribe to PubSub to verify broadcast
      Phoenix.PubSub.subscribe(AgentJido.PubSub, "contentops:runs")

      {:ok, result} =
        PublishRunReport.run(
          %{
            run_id: "run_test123",
            mode: :weekly,
            change_request_count: 1,
            delivered_count: 1,
            started_at: DateTime.utc_now()
          },
          %{state: %{}}
        )

      assert result.type == "contentops.run.completed"
      assert result.run_id == "run_test123"
      assert result.mode == :weekly
      assert result.stats.change_requests == 1
      assert result.stats.delivered == 1
      assert result.delivery_mode == :sink

      # Verify PubSub broadcast was sent
      assert_receive {:contentops_run_completed, report}
      assert report.run_id == "run_test123"
    end
  end

  describe "run_report/1" do
    test "extracts run report from productions" do
      productions = [
        %{some: "other data"},
        %{type: "contentops.run.completed", run_id: "run_test123", mode: :weekly}
      ]

      report = OrchestratorAgent.run_report(%{productions: productions})
      assert report.type == "contentops.run.completed"
      assert report.run_id == "run_test123"
    end

    test "returns nil when no report in productions" do
      assert OrchestratorAgent.run_report(%{productions: []}) == nil
    end

    test "returns the latest report from productions" do
      productions = [
        %{type: "contentops.run.completed", run_id: "run_old"},
        %{type: "contentops.run.completed", run_id: "run_new"}
      ]

      report = OrchestratorAgent.run_report(%{productions: productions})
      assert report.run_id == "run_new"
    end
  end

  describe "runtime integration" do
    test "run/1 updates run state fields and increments total_runs" do
      assert :ok = wait_until_ready(200)

      {:ok, before_status} = Jido.AgentServer.status(@server_name)
      before_total_runs = before_status.raw_state[:total_runs] || 0

      result = OrchestratorAgent.run(mode: :weekly, timeout: 30_000)
      assert result.status == :completed

      {:ok, after_status} = Jido.AgentServer.status(@server_name)
      raw_state = after_status.raw_state

      assert raw_state[:total_runs] >= before_total_runs + 1
      assert is_binary(raw_state[:last_run_id])
      assert raw_state[:last_run_mode] == :weekly
      assert %DateTime{} = raw_state[:last_run_at]
    end

    test "overlap guard rejects runs when server is processing" do
      original_state = :sys.get_state(@server_name)

      try do
        :sys.replace_state(@server_name, fn state ->
          put_in(state.agent.state[:__strategy__][:status], :running)
        end)

        assert {:error, :already_running} = OrchestratorAgent.check_ready()

        result = OrchestratorAgent.run(mode: :weekly, timeout: 1_000)
        assert result.status == {:error, :already_running}
        assert result.productions == []
      after
        :sys.replace_state(@server_name, fn _state -> original_state end)
      end
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
end
