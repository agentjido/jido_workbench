defmodule AgentJidoWeb.AdminDashboardLive do
  @moduledoc """
  Admin control-plane landing page for privileged tools.
  """
  use AgentJidoWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto max-w-5xl space-y-8 px-6 py-12">
      <header class="space-y-2">
        <p class="text-xs font-semibold uppercase tracking-[0.2em] text-primary">Admin Control Plane</p>
        <h1 class="text-3xl font-semibold text-foreground">Dashboard</h1>
        <p class="max-w-2xl text-sm text-muted-foreground">
          Launch operational tooling for search, studio workflows, and ContentOps execution.
        </p>
      </header>

      <section class="grid gap-4 md:grid-cols-2">
        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">Arcana dashboard</h2>
          <p class="text-sm text-muted-foreground">
            Inspect retrieval surfaces, collections, and search diagnostics.
          </p>
          <.link href="/arcana" class="text-sm font-semibold text-primary hover:text-primary/80">
            Open Arcana dashboard
          </.link>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">Jido Studio</h2>
          <p class="text-sm text-muted-foreground">
            Observe and operate agent workflows in the Jido Studio environment.
          </p>
          <.link href="/dev/jido" class="text-sm font-semibold text-primary hover:text-primary/80">
            Open Jido Studio
          </.link>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">ContentOps dashboard</h2>
          <p class="text-sm text-muted-foreground">
            Monitor orchestration health, execution pipeline state, and run history.
          </p>
          <.link href="/dev/contentops" class="text-sm font-semibold text-primary hover:text-primary/80">
            Open ContentOps dashboard
          </.link>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">ContentOps GitHub dashboard</h2>
          <p class="text-sm text-muted-foreground">
            Review linked GitHub issues and pull requests for ContentOps operations.
          </p>
          <.link
            href="/dev/contentops/github"
            class="text-sm font-semibold text-primary hover:text-primary/80"
          >
            Open ContentOps GitHub dashboard
          </.link>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6 md:col-span-2">
          <h2 class="text-lg font-semibold text-foreground">Content Generator</h2>
          <p class="text-sm text-muted-foreground">
            Run `content.plan.generate` with admin controls and queue shortcuts.
          </p>
          <.link
            href="/dashboard/content-generator"
            class="text-sm font-semibold text-primary hover:text-primary/80"
          >
            Open Content Generator
          </.link>
        </article>
      </section>
    </div>
    """
  end
end
