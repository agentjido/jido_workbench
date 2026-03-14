defmodule AgentJidoWeb.Examples.ActionsRuntimeDemoLive do
  @moduledoc """
  Interactive demo for deterministic `Jido.Exec.run/3` action runtime walkthroughs.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.ActionsRuntimeDemo

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:families, ActionsRuntimeDemo.families())
     |> assign(:family_results, %{})
     |> assign(:selected_family, nil)
     |> assign(:log_entries, [])
     |> assign(:last_error, nil)}
  end

  @impl true
  def render(assigns) do
    selected_result = Map.get(assigns.family_results, assigns.selected_family)
    assigns = assign(assigns, :selected_result, selected_result)

    ~H"""
    <div id="actions-runtime-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-4">
        <div>
          <div class="text-sm font-semibold text-foreground">Jido.AI Actions Runtime Demos</div>
          <div class="text-[11px] text-muted-foreground">
            Real `Jido.Exec.run/3` calls with deterministic local fixtures and in-process stores
          </div>
        </div>
        <div class="text-[10px] font-mono text-muted-foreground bg-elevated px-2 py-1 rounded border border-border">
          {map_size(@family_results)} / {length(@families)} families completed
        </div>
      </div>

      <div :if={@last_error} class="rounded-md border border-red-400/30 bg-red-400/10 px-3 py-2 text-xs text-red-300">
        {@last_error}
      </div>

      <div class="grid gap-3 md:grid-cols-2 xl:grid-cols-3">
        <%= for family <- @families do %>
          <button
            id={"actions-runtime-#{family.id}-btn"}
            phx-click="run_family"
            phx-value-family={family.id}
            class="rounded-md border border-border bg-elevated p-4 text-left hover:border-primary/40 transition-colors"
          >
            <div class="flex items-center justify-between gap-3">
              <div class="text-xs font-semibold text-foreground">{family.title}</div>
              <div
                :if={Map.has_key?(@family_results, family.id)}
                class="text-[10px] uppercase tracking-wider text-emerald-300"
              >
                complete
              </div>
            </div>
            <div class="mt-2 text-[11px] text-muted-foreground leading-relaxed">{family.description}</div>
          </button>
        <% end %>
      </div>

      <div class="flex gap-3 flex-wrap">
        <button
          id="actions-runtime-run-all-btn"
          phx-click="run_all"
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold"
        >
          Run All Families
        </button>
        <button
          id="actions-runtime-reset-btn"
          phx-click="reset_demo"
          class="px-3 py-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground hover:border-primary/40 transition-colors text-xs"
        >
          Reset
        </button>
      </div>

      <div class="grid gap-4 xl:grid-cols-[0.85fr_1.15fr]">
        <div class="rounded-md border border-border bg-elevated p-4">
          <div class="flex items-center justify-between mb-2">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Execution Log</div>
            <div class="text-[10px] text-muted-foreground">{length(@log_entries)} entries</div>
          </div>
          <div :if={@log_entries == []} class="text-xs text-muted-foreground">
            Run one family or the full suite to inspect the deterministic runtime calls.
          </div>
          <div :if={@log_entries != []} class="space-y-2 max-h-[32rem] overflow-y-auto">
            <%= for entry <- @log_entries do %>
              <div class="rounded-md border border-border bg-background/70 px-3 py-2">
                <div class="text-[11px] font-semibold text-foreground">{entry.title}</div>
                <div class="text-[11px] text-muted-foreground">{entry.detail}</div>
              </div>
            <% end %>
          </div>
        </div>

        <div class="rounded-md border border-border bg-elevated p-4">
          <div class="flex items-center justify-between mb-2">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Latest Result</div>
            <div :if={@selected_result} class="text-[10px] text-muted-foreground">{@selected_result.title}</div>
          </div>

          <div :if={is_nil(@selected_result)} class="text-xs text-muted-foreground">
            Select a family to inspect the exact `Jido.Exec.run/3` calls and results.
          </div>

          <div :if={@selected_result} class="space-y-4">
            <div>
              <div class="text-sm font-semibold text-foreground">{@selected_result.title}</div>
              <div class="text-xs text-muted-foreground mt-1">{@selected_result.summary}</div>
            </div>

            <div class="space-y-3">
              <%= for call <- @selected_result.calls do %>
                <div class="rounded-md border border-border bg-background/80 p-3 space-y-2">
                  <div class="flex items-center justify-between gap-3">
                    <div class="text-xs font-semibold text-foreground">{call.label}</div>
                    <div class="text-[10px] uppercase tracking-wider text-muted-foreground">
                      {if call.status == :ok, do: "ok", else: "error"}
                    </div>
                  </div>
                  <div class="text-[11px] text-muted-foreground font-mono break-all">{call.module}</div>
                  <div class="grid gap-2 lg:grid-cols-2">
                    <div>
                      <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-1">Params</div>
                      <pre class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= inspect(call.params, pretty: true, width: 70) %></pre>
                    </div>
                    <div>
                      <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-1">Result</div>
                      <pre class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= inspect(call.result, pretty: true, width: 70) %></pre>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("run_family", %{"family" => family}, socket) do
    run = ActionsRuntimeDemo.run_family(family)

    {:noreply,
     socket
     |> assign(:selected_family, family)
     |> assign(:family_results, Map.put(socket.assigns.family_results, family, run))
     |> assign(:last_error, nil)
     |> prepend_log(run)}
  rescue
    error ->
      {:noreply, assign(socket, :last_error, Exception.message(error))}
  end

  def handle_event("run_all", _params, socket) do
    results = ActionsRuntimeDemo.run_all()
    family_results = Map.new(results, &{&1.id, &1})
    selected_family = results |> List.last() |> Map.fetch!(:id)

    socket =
      Enum.reduce(results, socket, fn run, acc -> prepend_log(acc, run) end)

    {:noreply,
     socket
     |> assign(:family_results, Map.merge(socket.assigns.family_results, family_results))
     |> assign(:selected_family, selected_family)
     |> assign(:last_error, nil)}
  rescue
    error ->
      {:noreply, assign(socket, :last_error, Exception.message(error))}
  end

  def handle_event("reset_demo", _params, socket) do
    {:noreply,
     socket
     |> assign(:family_results, %{})
     |> assign(:selected_family, nil)
     |> assign(:log_entries, [])
     |> assign(:last_error, nil)}
  end

  defp prepend_log(socket, run) do
    entry = %{
      title: run.title,
      detail: "#{length(run.calls)} calls completed through Jido.Exec.run/3."
    }

    assign(socket, :log_entries, [entry | socket.assigns.log_entries] |> Enum.take(40))
  end
end
