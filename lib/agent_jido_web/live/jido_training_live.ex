defmodule AgentJidoWeb.JidoTrainingLive do
  @moduledoc """
  Training index page backed by markdown modules in `priv/training/`.
  """
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  alias AgentJido.Training

  @track_order [:foundations, :coordination, :integration, :operations]

  @impl true
  def mount(_params, _session, socket) do
    modules = Training.all_modules()

    {:ok,
     assign(socket,
       og_image: "https://agentjido.xyz/og/training.png",
       modules: modules,
       track_groups: build_track_groups(modules)
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/training">
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <section class="text-center mb-16">
          <div class="inline-block px-4 py-2 rounded mb-5 bg-primary/10 border border-primary/30">
            <span class="text-primary text-[11px] font-semibold tracking-widest uppercase">
              TRAINING TRACK
            </span>
          </div>
          <h1 class="text-4xl font-bold mb-4">
            Practical Jido training for <span class="text-primary">Elixir engineers</span>
          </h1>
          <p class="text-lg text-muted-foreground max-w-3xl mx-auto">
            Move from fundamentals to production patterns through hands-on modules, each with a concrete exercise and validation checklist.
          </p>
        </section>

        <%= for {track, modules} <- @track_groups do %>
          <section class="mb-16">
            <div class="flex justify-between items-center mb-6">
              <span class="text-sm font-bold tracking-wider uppercase">{track_label(track)}</span>
              <span class="text-[10px] px-2 py-1 rounded bg-accent-cyan/10 border border-accent-cyan/30 text-accent-cyan font-semibold">
                {length(modules)} module{if length(modules) == 1, do: "", else: "s"}
              </span>
            </div>

            <div class="grid md:grid-cols-2 gap-4">
              <%= for module <- modules do %>
                <.training_card module={module} />
              <% end %>
            </div>
          </section>
        <% end %>
      </div>
    </.marketing_layout>
    """
  end

  attr :module, :map, required: true

  defp training_card(assigns) do
    ~H"""
    <.link navigate={~p"/training/#{@module.slug}"} class="feature-card group block">
      <div class="flex justify-between items-start mb-3 gap-2">
        <span class={"text-[10px] px-2 py-0.5 rounded font-semibold uppercase #{difficulty_badge(@module.difficulty)}"}>
          {@module.difficulty}
        </span>
        <span class="text-[10px] px-2 py-0.5 rounded bg-elevated text-muted-foreground">
          {@module.duration_minutes} min
        </span>
      </div>

      <h3 class="font-bold text-[15px] mb-2 group-hover:text-primary transition-colors">
        {@module.title}
      </h3>
      <p class="text-muted-foreground text-xs leading-relaxed mb-4">{@module.description}</p>

      <div class="flex gap-2 flex-wrap mb-4">
        <span class="text-[10px] px-2 py-0.5 rounded bg-primary/10 text-primary">
          {length(@module.prerequisites)} prerequisite{if length(@module.prerequisites) == 1, do: "", else: "s"}
        </span>
        <%= for tag <- @module.tags do %>
          <span class="text-[10px] px-2 py-0.5 rounded bg-elevated text-muted-foreground">
            {tag}
          </span>
        <% end %>
      </div>

      <span class="text-xs font-semibold text-primary">OPEN MODULE →</span>
    </.link>
    """
  end

  defp build_track_groups(modules) do
    grouped = Enum.group_by(modules, & &1.track)

    @track_order
    |> Enum.map(fn track -> {track, Map.get(grouped, track, [])} end)
    |> Enum.reject(fn {_track, track_modules} -> track_modules == [] end)
  end

  defp track_label(:foundations), do: "Foundations"
  defp track_label(:coordination), do: "Agent Coordination"
  defp track_label(:integration), do: "App Integration"
  defp track_label(:operations), do: "Production Operations"
  defp track_label(track), do: track |> to_string() |> Phoenix.Naming.humanize()

  defp difficulty_badge(:beginner), do: "bg-green-500/10 text-green-400"
  defp difficulty_badge(:intermediate), do: "bg-amber-500/10 text-amber-400"
  defp difficulty_badge(:advanced), do: "bg-red-500/10 text-red-400"
  defp difficulty_badge(_), do: "bg-elevated text-muted-foreground"
end
