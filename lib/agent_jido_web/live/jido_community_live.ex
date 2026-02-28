defmodule AgentJidoWeb.JidoCommunityLive do
  @moduledoc """
  Community hub landing page for onboarding, adoption, and contribution.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.Pages

  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    hub_page = Pages.get_page_by_path("/community")

    {:ok,
     assign(socket,
       page_title: "Jido Community",
       meta_description: hub_page_description(hub_page),
       pathways: community_pathways(),
       engagement_channels: engagement_channels(),
       contribution_steps: contribution_steps()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout
      current_path="/community"
      current_scope={@current_scope}
      analytics_identity={@analytics_identity}
    >
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <section class="text-center mb-16 animate-fade-in">
          <div class="inline-block px-4 py-2 rounded mb-5 bg-primary/10 border border-primary/30">
            <span class="text-primary text-[11px] font-semibold tracking-widest uppercase">
              COMMUNITY HUB
            </span>
          </div>

          <h1 class="text-4xl font-bold mb-4 tracking-tight">
            Build with others, then <span class="text-primary">ship with proof</span>
          </h1>
          <p class="copy-measure-wide mx-auto mb-8 text-lg text-muted-foreground">
            Use this section to align learning, rollout patterns, and case narratives so your team can move from experiments to repeatable delivery.
          </p>

          <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 max-w-3xl mx-auto">
            <div class="feature-card text-center py-4">
              <div class="text-lg font-bold text-primary">{length(@pathways)}</div>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">guided pathways</div>
            </div>
            <div class="feature-card text-center py-4">
              <div class="text-lg font-bold text-accent-cyan">{length(@engagement_channels)}</div>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">engagement channels</div>
            </div>
            <div class="feature-card text-center py-4">
              <div class="text-lg font-bold text-accent-yellow">{length(@contribution_steps)}</div>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">contribution steps</div>
            </div>
          </div>
        </section>

        <section id="community-start-here" class="mb-16 opacity-0" phx-hook="ScrollReveal">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Start here</span>
            <span class="text-[11px] text-muted-foreground">learn -> adopt -> document</span>
          </div>
          <div class="grid md:grid-cols-3 gap-4">
            <%= for pathway <- @pathways do %>
              <.link navigate={pathway.href} class="feature-card group block h-full">
                <div class="flex items-start justify-between gap-3 mb-3">
                  <span class={"text-[10px] px-2 py-1 rounded font-semibold uppercase tracking-wider #{pathway.badge_class}"}>
                    {pathway.badge}
                  </span>
                  <span class="text-[10px] px-2 py-1 rounded border border-border bg-surface text-muted-foreground uppercase tracking-wider">
                    {pathway.read_time}
                  </span>
                </div>
                <h2 class="font-bold text-[15px] mb-2 group-hover:text-primary transition-colors">
                  {pathway.title}
                </h2>
                <p class="text-muted-foreground text-xs leading-relaxed mb-4">{pathway.description}</p>
                <div class="text-[11px] text-secondary-foreground">{pathway.focus}</div>
              </.link>
            <% end %>
          </div>
        </section>

        <section id="community-engage" class="mb-16 opacity-0" phx-hook="ScrollReveal">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Engage</span>
            <span class="text-[11px] text-muted-foreground">choose the right channel for intent</span>
          </div>
          <div class="grid md:grid-cols-3 gap-4">
            <%= for channel <- @engagement_channels do %>
              <article class="feature-card h-full">
                <h2 class="font-bold text-[15px] mb-2">{channel.title}</h2>
                <p class="text-muted-foreground text-xs leading-relaxed mb-4">{channel.description}</p>
                <a
                  :if={channel.external?}
                  href={channel.href}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="inline-block text-xs font-semibold text-primary hover:opacity-80 transition-opacity"
                >
                  {channel.cta} ->
                </a>
                <.link
                  :if={not channel.external?}
                  navigate={channel.href}
                  class="inline-block text-xs font-semibold text-primary hover:opacity-80 transition-opacity"
                >
                  {channel.cta} ->
                </.link>
              </article>
            <% end %>
          </div>
        </section>

        <section id="community-contribute" class="mb-16 opacity-0" phx-hook="ScrollReveal">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Contribute</span>
            <span class="text-[11px] text-muted-foreground">ship bounded changes with evidence</span>
          </div>
          <div class="grid md:grid-cols-3 gap-4">
            <%= for step <- @contribution_steps do %>
              <article class="feature-card h-full">
                <div class="text-[10px] px-2 py-1 rounded w-fit mb-3 bg-primary/10 border border-primary/30 text-primary font-semibold uppercase tracking-wider">
                  Step {step.number}
                </div>
                <h2 class="font-bold text-[15px] mb-2">{step.title}</h2>
                <p class="text-muted-foreground text-xs leading-relaxed">{step.description}</p>
              </article>
            <% end %>
          </div>
        </section>

        <section id="community-cta" class="opacity-0" phx-hook="ScrollReveal">
          <div class="cta-glow rounded-lg p-12 text-center">
            <h2 class="text-2xl font-bold mb-3">Start one path this week</h2>
            <p class="copy-measure mx-auto mb-6 text-sm text-secondary-foreground">
              Pick a role path, complete one proof checkpoint, then capture rollout decisions in an adoption playbook.
            </p>
            <div class="flex flex-wrap justify-center gap-3">
              <.link
                navigate="/community/learning-paths"
                class="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-3 rounded transition-colors"
              >
                OPEN LEARNING PATHS ->
              </.link>
              <.link
                navigate="/community/adoption-playbooks"
                class="border border-accent-cyan text-accent-cyan hover:bg-accent-cyan/10 text-[13px] font-medium px-7 py-3 rounded transition-colors"
              >
                OPEN ADOPTION PLAYBOOKS
              </.link>
            </div>
          </div>
        </section>
      </div>
    </.marketing_layout>
    """
  end

  defp hub_page_description(%{description: description}) when is_binary(description) do
    description
  end

  defp hub_page_description(_hub_page) do
    "Community hub for Jido users: learning paths, adoption playbooks, and case studies."
  end

  defp community_pathways do
    Pages.pages_by_category(:community)
    |> Enum.reject(&(&1.path == "/community"))
    |> Enum.sort_by(&{&1.order, &1.path})
    |> Enum.map(fn page ->
      metadata = pathway_metadata(page.id)

      %{
        title: page.title,
        description: page.description,
        href: page.path,
        read_time: "#{page.reading_time_minutes} min",
        badge: metadata.badge,
        badge_class: metadata.badge_class,
        focus: metadata.focus
      }
    end)
  end

  defp pathway_metadata("learning-paths") do
    %{
      badge: "learn",
      badge_class: "bg-accent-cyan/10 border border-accent-cyan/30 text-accent-cyan",
      focus: "Focus: role-based onboarding and checkpoints."
    }
  end

  defp pathway_metadata("adoption-playbooks") do
    %{
      badge: "adopt",
      badge_class: "bg-accent-yellow/10 border border-accent-yellow/30 text-accent-yellow",
      focus: "Focus: bounded rollout, evidence, and review gates."
    }
  end

  defp pathway_metadata("case-studies") do
    %{
      badge: "prove",
      badge_class: "bg-accent-green/10 border border-accent-green/30 text-accent-green",
      focus: "Focus: technical narrative with explicit permission scope."
    }
  end

  defp pathway_metadata(_id) do
    %{
      badge: "path",
      badge_class: "bg-primary/10 border border-primary/30 text-primary",
      focus: "Focus: practical implementation guidance."
    }
  end

  defp engagement_channels do
    [
      %{
        title: "Ask implementation questions",
        description: "Use Discord for architecture feedback, debugging help, and implementation discussion with maintainers and builders.",
        cta: "Join Discord",
        href: "/discord",
        external?: false
      },
      %{
        title: "Report product or docs issues",
        description: "Open focused issues when you find bugs, stale references, or unclear guidance so fixes can be tracked and shipped.",
        cta: "Open GitHub Issues",
        href: "https://github.com/agentjido/agentjido_xyz/issues",
        external?: true
      },
      %{
        title: "Choose package boundaries",
        description: "Use the package matrix to align runtime scope, support tier, and dependency choices before expanding adoption.",
        cta: "View Package Matrix",
        href: "/ecosystem/matrix",
        external?: false
      }
    ]
  end

  defp contribution_steps do
    [
      %{
        number: 1,
        title: "Choose one bounded workflow",
        description: "Start with one path and one proof checkpoint so scope and ownership stay explicit."
      },
      %{
        number: 2,
        title: "Capture evidence and decisions",
        description: "Record runtime behavior, non-goals, and rollback posture in an adoption playbook before expanding rollout."
      },
      %{
        number: 3,
        title: "Contribute improvements upstream",
        description: "When your pattern is stable, publish a case narrative and open docs or code updates via CONTRIBUTING.md."
      }
    ]
  end
end
