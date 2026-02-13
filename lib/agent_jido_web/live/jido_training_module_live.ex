defmodule AgentJidoWeb.JidoTrainingModuleLive do
  @moduledoc """
  Training module detail page.
  """
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  alias AgentJido.Training

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"slug" => slug}, _uri, socket) do
    module = Training.get_module!(slug)
    {previous_module, next_module} = Training.neighbors(module)

    {:noreply,
     socket
     |> assign(:module, module)
     |> assign(:previous_module, previous_module)
     |> assign(:next_module, next_module)
     |> assign(:page_title, module.title)
     |> assign(:og_image, "https://agentjido.xyz/og/training.png")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/training">
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <div class="mb-8">
          <.link
            navigate="/training"
            class="text-xs text-muted-foreground hover:text-primary transition-colors"
          >
            ← back to training
          </.link>
        </div>

        <section class="mb-10">
          <div class="flex flex-wrap items-center gap-3 mb-3">
            <span class="text-[10px] px-2 py-1 rounded bg-primary/10 border border-primary/30 text-primary font-semibold uppercase tracking-wider">
              {track_label(@module.track)}
            </span>
            <span class={"text-[10px] px-2 py-1 rounded font-semibold uppercase tracking-wider #{difficulty_class(@module.difficulty)}"}>
              {@module.difficulty}
            </span>
            <span class="text-[10px] px-2 py-1 rounded bg-elevated border border-border text-muted-foreground">
              {@module.duration_minutes} min
            </span>
          </div>

          <h1 class="text-3xl font-bold tracking-tight mb-3">{@module.title}</h1>
          <p class="text-sm text-secondary-foreground leading-relaxed max-w-[820px]">
            {@module.description}
          </p>

          <div :if={@module.learning_outcomes != []} class="mt-5">
            <h2 class="text-xs font-bold tracking-wider mb-2">LEARNING OUTCOMES</h2>
            <ul class="space-y-1">
              <%= for outcome <- @module.learning_outcomes do %>
                <li class="text-xs text-muted-foreground">• {outcome}</li>
              <% end %>
            </ul>
          </div>
        </section>

        <section class="mb-12">
          <article class="prose prose-invert max-w-none text-sm leading-relaxed">
            {Phoenix.HTML.raw(@module.body)}
          </article>
        </section>

        <section class="grid md:grid-cols-2 gap-4">
          <.link
            :if={@previous_module}
            navigate={~p"/training/#{@previous_module.slug}"}
            class="feature-card block"
          >
            <div class="text-[10px] text-muted-foreground uppercase mb-1">Previous Module</div>
            <div class="text-sm font-semibold text-foreground">{@previous_module.title}</div>
          </.link>

          <.link
            :if={@next_module}
            navigate={~p"/training/#{@next_module.slug}"}
            class="feature-card block md:text-right"
          >
            <div class="text-[10px] text-muted-foreground uppercase mb-1">Next Module</div>
            <div class="text-sm font-semibold text-foreground">{@next_module.title}</div>
          </.link>
        </section>
      </div>
    </.marketing_layout>
    """
  end

  defp track_label(:foundations), do: "Foundations"
  defp track_label(:coordination), do: "Agent Coordination"
  defp track_label(:integration), do: "App Integration"
  defp track_label(:operations), do: "Production Operations"
  defp track_label(track), do: track |> to_string() |> Phoenix.Naming.humanize()

  defp difficulty_class(:beginner),
    do: "bg-green-500/10 border border-green-500/30 text-green-400"

  defp difficulty_class(:intermediate),
    do: "bg-amber-500/10 border border-amber-500/30 text-amber-400"

  defp difficulty_class(:advanced),
    do: "bg-red-500/10 border border-red-500/30 text-red-400"

  defp difficulty_class(_), do: "bg-elevated border border-border text-muted-foreground"
end
