defmodule AgentJidoWeb.ChatOpsLive do
  @moduledoc """
  Admin ChatOps console shell.
  """
  use AgentJidoWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto max-w-6xl space-y-8 px-6 py-12">
      <header class="space-y-2">
        <p class="text-xs font-semibold uppercase tracking-[0.2em] text-primary">Admin Control Plane</p>
        <h1 class="text-3xl font-semibold text-foreground">ChatOps Console</h1>
        <p class="max-w-3xl text-sm text-muted-foreground">
          Operational shell for monitoring room state, chat activity, and execution safeguards.
        </p>
      </header>

      <section class="grid gap-4 lg:grid-cols-2">
        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">Room List</h2>
          <p class="text-sm text-muted-foreground">
            Placeholder for room inventory and channel bindings.
          </p>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">Messages</h2>
          <p class="text-sm text-muted-foreground">
            Placeholder for recent message timeline entries.
          </p>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">Action/Run Timeline</h2>
          <p class="text-sm text-muted-foreground">
            Placeholder for action and run events emitted by ChatOps workflows.
          </p>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">Guardrails</h2>
          <p class="text-sm text-muted-foreground">
            Placeholder for authorization and mutation safety indicators.
          </p>
        </article>
      </section>
    </div>
    """
  end
end
