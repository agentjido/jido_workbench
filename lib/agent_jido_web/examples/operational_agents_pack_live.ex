defmodule AgentJidoWeb.Examples.OperationalAgentsPackLive do
  @moduledoc """
  Overview/index surface for the operational agents pack.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.OperationalAgentsPack.Catalog

  @impl true
  def mount(_params, _session, socket) do
    selected = Catalog.default_local_entry()

    {:ok,
     socket
     |> assign(:local_entries, Catalog.local_entries())
     |> assign(:upstream_refs, Catalog.upstream_refs())
     |> assign(:selected_entry, selected)
     |> assign(:activity, [
       %{
         label: "Overview",
         detail: "Opened the operational index with #{selected.title} selected as the first deterministic example."
       }
     ])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="operational-agents-pack-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-4">
        <div>
          <div class="text-sm font-semibold text-foreground">Jido.AI Operational Agents Pack</div>
          <div class="text-[11px] text-muted-foreground">
            Operational overview that links to narrow deterministic examples instead of pretending one simulator is a runnable pack
          </div>
        </div>
        <div class="text-[10px] font-semibold uppercase tracking-wider rounded border border-amber-400/30 bg-amber-400/10 text-amber-300 px-2 py-1">
          overview
        </div>
      </div>

      <div class="rounded-md border border-border bg-elevated p-4 text-xs text-muted-foreground space-y-1">
        <div>This page is an index for operational patterns.</div>
        <div>
          Open the linked deterministic examples for runnable proof; use the upstream source links when you want the original Jido.AI ops-agent implementations.
        </div>
      </div>

      <div class="grid gap-3 sm:grid-cols-3">
        <div class="rounded-md border border-border bg-elevated p-3">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Local deterministic examples</div>
          <div id="operational-local-count" class="text-sm font-semibold text-foreground mt-2">
            {length(@local_entries)}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Upstream references</div>
          <div id="operational-upstream-count" class="text-sm font-semibold text-foreground mt-2">
            {length(@upstream_refs)}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Selected route</div>
          <div id="operational-selected-route" class="text-sm font-semibold text-foreground mt-2">
            {@selected_entry.route}
          </div>
        </div>
      </div>

      <div class="space-y-3">
        <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Deterministic local examples</div>
        <div class="grid gap-3 lg:grid-cols-3">
          <%= for entry <- @local_entries do %>
            <button
              id={"operational-entry-#{entry.id}"}
              phx-click="select_entry"
              phx-value-entry={entry.id}
              class={"rounded-md border p-4 text-left transition-colors #{entry_class(@selected_entry.id == entry.id)}"}
            >
              <div class="text-sm font-semibold text-foreground">{entry.title}</div>
              <div class="text-[11px] text-muted-foreground mt-1">{entry.operational_focus}</div>
              <div class="text-[11px] text-muted-foreground mt-3">{entry.why}</div>
            </button>
          <% end %>
        </div>
      </div>

      <div class="grid gap-4 xl:grid-cols-[1fr_0.9fr]">
        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4 space-y-4">
            <div>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Selected deterministic example</div>
              <div id="operational-selected-title" class="text-sm font-semibold text-foreground mt-2">
                {@selected_entry.title}
              </div>
              <div class="text-[11px] text-muted-foreground mt-2">{@selected_entry.description}</div>
            </div>

            <div class="grid gap-3 sm:grid-cols-3">
              <div class="rounded-md border border-border bg-background/70 p-3">
                <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Focus</div>
                <div class="text-[11px] text-foreground mt-2">{@selected_entry.operational_focus}</div>
              </div>
              <div class="rounded-md border border-border bg-background/70 p-3">
                <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Difficulty</div>
                <div class="text-[11px] text-foreground mt-2">{@selected_entry.difficulty}</div>
              </div>
              <div class="rounded-md border border-border bg-background/70 p-3">
                <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Demo mode</div>
                <div class="text-[11px] text-foreground mt-2">{@selected_entry.demo_mode}</div>
              </div>
            </div>

            <div class="rounded-md border border-border bg-background/70 p-3">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Why this belongs in the pack</div>
              <div class="text-[11px] text-foreground mt-2">{@selected_entry.why}</div>
            </div>

            <div class="rounded-md border border-border bg-background/70 p-3">
              <div class="flex items-center justify-between gap-3">
                <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Capabilities</div>
                <.link
                  id="operational-open-selected-example"
                  navigate={@selected_entry.route}
                  class="text-[11px] font-semibold text-primary hover:text-primary/80"
                >
                  Open example
                </.link>
              </div>
              <div class="flex gap-2 flex-wrap mt-3">
                <%= for capability <- @selected_entry.capabilities do %>
                  <span class="text-[10px] px-2 py-1 rounded bg-elevated border border-border text-muted-foreground">
                    {capability}
                  </span>
                <% end %>
              </div>
            </div>

            <div class="rounded-md border border-border bg-background/70 p-3">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Source files</div>
              <div id="operational-selected-source-files" class="mt-3 space-y-2">
                <%= for path <- @selected_entry.source_files do %>
                  <div class="text-[11px] font-mono text-foreground">{path}</div>
                <% end %>
              </div>
            </div>
          </div>
        </div>

        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-3">Upstream operational agent references</div>
            <div class="space-y-3">
              <%= for ref <- @upstream_refs do %>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="flex items-center justify-between gap-3">
                    <div>
                      <div class="text-sm font-semibold text-foreground">{ref.title}</div>
                      <div class="text-[11px] text-muted-foreground mt-1">{ref.description}</div>
                    </div>
                    <a
                      href={ref.href}
                      target="_blank"
                      rel="noopener noreferrer"
                      class="text-[11px] font-semibold text-primary hover:text-primary/80"
                    >
                      Open source
                    </a>
                  </div>
                  <div class="text-[11px] text-muted-foreground mt-3">{ref.focus}</div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Activity</div>
              <div class="text-[10px] text-muted-foreground">{length(@activity)} note(s)</div>
            </div>
            <div id="operational-pack-activity" class="space-y-2 max-h-[18rem] overflow-y-auto">
              <%= for entry <- @activity do %>
                <div class="rounded-md border border-border bg-background/70 px-3 py-2">
                  <div class="text-[11px] font-semibold text-foreground">{entry.label}</div>
                  <div class="text-[11px] text-muted-foreground">{entry.detail}</div>
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
  def handle_event("select_entry", %{"entry" => entry_id}, socket) do
    entry = Catalog.local_entry!(entry_id)

    {:noreply,
     socket
     |> assign(:selected_entry, entry)
     |> update(:activity, fn activity ->
       [%{label: "Selected", detail: "Focused #{entry.title} as the current deterministic operational example."} | activity]
       |> Enum.take(12)
     end)}
  end

  defp entry_class(true), do: "border-primary/40 bg-primary/10 shadow-sm"
  defp entry_class(false), do: "border-border bg-background/70 hover:border-primary/20"
end
