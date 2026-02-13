defmodule AgentJido.ContentOps.OrchestratorAgentTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentOps.OrchestratorAgent

  alias AgentJido.ContentOps.Actions.{
    BuildRunContext,
    LoadPolicyBundle,
    SelectWork,
    CollectChangeRequests,
    DeliverySink,
    PublishRunReport
  }

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
    test "declares hourly, nightly, weekly, and monthly schedules" do
      schedules =
        OrchestratorAgent.plugin_schedules()
        |> Enum.filter(fn schedule -> match?({:agent_schedule, _, _}, schedule.job_id) end)

      assert length(schedules) == 4

      assert Enum.any?(schedules, fn s ->
               s.cron_expression == "0 * * * *" and
                 s.signal_type == "contentops.tick" and
                 s.job_id == {:agent_schedule, "contentops_orchestrator", :hourly_tick}
             end)

      assert Enum.any?(schedules, fn s ->
               s.cron_expression == "0 2 * * *" and
                 s.signal_type == "contentops.tick" and
                 s.job_id == {:agent_schedule, "contentops_orchestrator", :nightly_tick}
             end)

      assert Enum.any?(schedules, fn s ->
               s.cron_expression == "0 3 * * 1" and
                 s.signal_type == "contentops.tick" and
                 s.job_id == {:agent_schedule, "contentops_orchestrator", :weekly_tick}
             end)

      assert Enum.any?(schedules, fn s ->
               s.cron_expression == "0 4 1 * *" and
                 s.signal_type == "contentops.tick" and
                 s.job_id == {:agent_schedule, "contentops_orchestrator", :monthly_tick}
             end)
    end
  end

  describe "signal_routes/1" do
    test "routes contentops.tick to BuildRunContext" do
      agent = OrchestratorAgent.new()
      routes = OrchestratorAgent.signal_routes(%{agent: agent})
      assert {"contentops.tick", BuildRunContext} in routes
      assert {"contentops.run.requested", BuildRunContext} in routes
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
  end
end
