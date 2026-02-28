defmodule AgentJidoWeb.Examples.SimulatedShowcaseLive do
  @moduledoc """
  Deterministic showcase demos used for AI/browser examples.

  These demos intentionally avoid external network calls and LLM providers.
  Every step is simulated fixture data so users get a smooth interactive flow
  without setup friction or API keys.
  """
  use AgentJidoWeb, :live_view

  @step_delay_ms 550

  @impl true
  def mount(_params, session, socket) do
    slug = Map.get(session, "example_slug", "")
    scenario = scenario_for(slug)

    {:ok,
     socket
     |> assign(:slug, slug)
     |> assign(:scenario, scenario)
     |> assign(:running, false)
     |> assign(:step_index, 0)
     |> assign(:timeline, [])
     |> assign(:result, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={"simulated-showcase-demo-#{@slug}"} class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-3">
        <div>
          <div class="text-sm font-semibold text-foreground">{@scenario.title}</div>
          <div class="text-[11px] text-muted-foreground">Engine: deterministic fixture runner</div>
        </div>
        <div class="text-[10px] px-2 py-1 rounded border border-accent-cyan/30 bg-accent-cyan/10 text-accent-cyan font-semibold uppercase tracking-wider">
          simulated
        </div>
      </div>

      <div class="rounded-md border border-border bg-elevated p-4 text-xs text-muted-foreground space-y-1">
        <div>No live model calls. No browser automation. No external APIs.</div>
        <div>Each run replays a deterministic execution trace for UX demonstration.</div>
      </div>

      <div class="flex items-center gap-3 flex-wrap">
        <button
          phx-click="run_demo"
          disabled={@running}
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {if @running, do: "Running…", else: "Run simulated flow"}
        </button>
        <button
          phx-click="reset_demo"
          class="px-3 py-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground hover:border-primary/40 transition-colors text-xs"
        >
          Reset
        </button>
      </div>

      <div class="rounded-md border border-border bg-elevated p-3">
        <div class="flex items-center justify-between mb-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Execution Progress</div>
          <div class="text-[10px] text-muted-foreground">{progress_pct(@step_index, @scenario.steps)}%</div>
        </div>
        <div class="h-2 rounded-full bg-background border border-border overflow-hidden">
          <div
            class="h-full bg-primary transition-all duration-300 ease-out"
            style={"width: #{progress_pct(@step_index, @scenario.steps)}%"}
          />
        </div>
      </div>

      <div class="border-t border-border pt-4">
        <div class="flex items-center justify-between mb-2">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Trace</div>
          <div class="text-[10px] text-muted-foreground">{length(@timeline)} step(s)</div>
        </div>

        <div :if={@timeline == []} class="text-xs text-muted-foreground">
          Start a run to see the deterministic trace.
        </div>

        <div :if={@timeline != []} class="space-y-2 max-h-64 overflow-y-auto">
          <%= for entry <- @timeline do %>
            <div class="rounded-md border border-border bg-elevated/60 px-3 py-2">
              <div class="text-[11px] font-semibold text-foreground">{entry.label}</div>
              <div class="text-[11px] text-muted-foreground">{entry.detail}</div>
            </div>
          <% end %>
        </div>
      </div>

      <div :if={@result} class="rounded-md border border-emerald-400/30 bg-emerald-400/10 p-4">
        <div class="text-[10px] uppercase tracking-wider text-emerald-300 mb-2">Simulated Result</div>
        <pre class="text-[12px] text-emerald-100/90 whitespace-pre-wrap"><%= @result %></pre>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("run_demo", _params, socket) do
    if socket.assigns.running do
      {:noreply, socket}
    else
      Process.send_after(self(), :advance_step, @step_delay_ms)

      {:noreply,
       socket
       |> assign(:running, true)
       |> assign(:step_index, 0)
       |> assign(:timeline, [])
       |> assign(:result, nil)}
    end
  end

  def handle_event("reset_demo", _params, socket) do
    {:noreply,
     socket
     |> assign(:running, false)
     |> assign(:step_index, 0)
     |> assign(:timeline, [])
     |> assign(:result, nil)}
  end

  @impl true
  def handle_info(:advance_step, socket) do
    scenario = socket.assigns.scenario
    next_index = socket.assigns.step_index + 1
    next_step = Enum.at(scenario.steps, socket.assigns.step_index)

    cond do
      next_step == nil ->
        {:noreply,
         socket
         |> assign(:running, false)
         |> assign(:result, scenario.result)}

      true ->
        updated_socket =
          socket
          |> assign(:step_index, next_index)
          |> assign(:timeline, socket.assigns.timeline ++ [next_step])

        if next_index < length(scenario.steps) do
          Process.send_after(self(), :advance_step, @step_delay_ms)
          {:noreply, updated_socket}
        else
          Process.send_after(self(), :advance_step, @step_delay_ms)
          {:noreply, updated_socket}
        end
    end
  end

  defp progress_pct(step_index, steps) when is_list(steps) and length(steps) > 0 do
    pct = step_index / length(steps) * 100
    pct |> min(100.0) |> Float.round(0) |> trunc()
  end

  defp progress_pct(_step_index, _steps), do: 0

  defp scenario_for("browser-agent") do
    %{
      title: "Browser Agent",
      steps: [
        %{label: "Open URL", detail: "Navigate to pricing page (fixture: /pages/pricing.html)"},
        %{label: "Extract table", detail: "Detected 3 pricing tiers with feature matrix"},
        %{label: "Fill form", detail: "Simulated contact form submit for enterprise lead"}
      ],
      result: """
      {
        "pages_visited": 1,
        "plans_found": ["starter", "growth", "enterprise"],
        "lead_capture": "queued"
      }
      """
    }
  end

  defp scenario_for("deep-research") do
    %{
      title: "Deep Research",
      steps: [
        %{label: "Collect sources", detail: "Loaded 5 deterministic source snippets"},
        %{label: "Synthesize findings", detail: "Clustered claims into consensus and risk buckets"},
        %{label: "Draft memo", detail: "Generated summary and open questions"}
      ],
      result: """
      Summary:
      - Adoption is accelerating in ops and support workflows.
      - Main risk remains evaluation quality under ambiguous inputs.
      - Recommendation: pilot with bounded, high-observability tasks first.
      """
    }
  end

  defp scenario_for("coding-assistant") do
    %{
      title: "Coding Assistant",
      steps: [
        %{label: "Read files", detail: "Indexed 4 fixture files in lib/ and test/"},
        %{label: "Detect issue", detail: "Found one nil-handling edge case in parser"},
        %{label: "Propose patch", detail: "Built patch suggestion with unit test update"}
      ],
      result: """
      Patch plan:
      1. Guard nil input before trim/1.
      2. Add parser unit test for nil payload.
      3. Run mix test for parser suite.
      """
    }
  end

  defp scenario_for("incident-triage") do
    %{
      title: "Incident Triage",
      steps: [
        %{label: "Ingest alerts", detail: "Loaded 12 fixture alerts from logs + paging"},
        %{label: "Cluster incidents", detail: "Grouped alerts into 2 active incidents"},
        %{label: "Recommend action", detail: "Escalated API latency issue to SRE owner"}
      ],
      result: """
      Incident: api-latency-degradation
      Severity: SEV-2
      Owner: sre-oncall
      Suggested next step: rollback deploy #742
      """
    }
  end

  defp scenario_for("text-to-sql-analytics") do
    %{
      title: "Text-to-SQL Analytics",
      steps: [
        %{label: "Interpret question", detail: "Mapped request to monthly revenue trend"},
        %{label: "Compile SQL", detail: "Generated parameterized query from fixture schema"},
        %{label: "Render chart data", detail: "Returned 12 monthly points for visualization"}
      ],
      result: """
      SQL:
      SELECT month, SUM(revenue) AS total_revenue
      FROM analytics.monthly_revenue
      WHERE year = 2025
      GROUP BY month
      ORDER BY month;
      """
    }
  end

  defp scenario_for("workflow-coordinator") do
    %{
      title: "Workflow Coordinator",
      steps: [
        %{label: "Plan graph", detail: "Built 4-node workflow with retry boundaries"},
        %{label: "Dispatch workers", detail: "Started classifier, enricher, and notifier stages"},
        %{label: "Recover fault", detail: "Injected node failure and replayed from checkpoint"}
      ],
      result: """
      Workflow status:
      - completed_nodes: 4/4
      - retries: 1
      - checkpoint_recovery: true
      """
    }
  end

  defp scenario_for(_slug) do
    %{
      title: "Simulated Example",
      steps: [
        %{label: "Load fixtures", detail: "Prepared deterministic demo inputs"},
        %{label: "Execute flow", detail: "Ran scenario with no external calls"},
        %{label: "Publish output", detail: "Returned stable simulated result"}
      ],
      result: "Demo completed in deterministic simulation mode."
    }
  end
end
