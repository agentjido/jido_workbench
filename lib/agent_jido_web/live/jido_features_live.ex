defmodule AgentJidoWeb.JidoFeaturesLive do
  @moduledoc """
  Features landing page for the Jido platform.
  """
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       og_image: "https://agentjido.xyz/og/features.png",
       core_features: core_features(),
       integration_features: integration_features(),
       production_features: production_features()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/features">
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <section class="text-center mb-16">
          <div class="inline-block px-4 py-2 rounded mb-5 bg-primary/10 border border-primary/30">
            <span class="text-primary text-[11px] font-semibold tracking-widest uppercase">
              PLATFORM FEATURES
            </span>
          </div>
          <h1 class="text-4xl font-bold mb-4">
            Ship BEAM-native agents with <span class="text-primary">production confidence</span>
          </h1>
          <p class="text-lg text-muted-foreground max-w-3xl mx-auto">
            Jido gives Elixir teams a complete path from typed agent logic to live UI integration and production-grade operations.
          </p>
        </section>

        <section class="mb-16">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Core Runtime</span>
            <span class="text-[10px] px-2 py-1 rounded bg-accent-cyan/10 border border-accent-cyan/30 text-accent-cyan font-semibold">
              foundation
            </span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for feature <- @core_features do %>
              <.feature_card feature={feature} />
            <% end %>
          </div>
        </section>

        <section class="mb-16">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Developer Integration</span>
            <span class="text-[10px] px-2 py-1 rounded bg-accent-yellow/10 border border-accent-yellow/30 text-accent-yellow font-semibold">
              build faster
            </span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for feature <- @integration_features do %>
              <.feature_card feature={feature} />
            <% end %>
          </div>
        </section>

        <section class="mb-16">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Production Readiness</span>
            <span class="text-[10px] px-2 py-1 rounded bg-green-500/10 border border-green-500/30 text-green-400 font-semibold">
              operate safely
            </span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for feature <- @production_features do %>
              <.feature_card feature={feature} />
            <% end %>
          </div>
        </section>

        <section>
          <div class="cta-glow rounded-lg p-12 text-center">
            <h2 class="text-2xl font-bold mb-3">Turn features into skills</h2>
            <p class="text-secondary-foreground text-sm mb-6">
              Follow the module sequence to learn each feature hands-on with runnable exercises.
            </p>
            <.link
              navigate="/training"
              class="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-3 rounded transition-colors inline-block"
            >
              START TRAINING →
            </.link>
          </div>
        </section>
      </div>
    </.marketing_layout>
    """
  end

  attr :feature, :map, required: true

  defp feature_card(assigns) do
    ~H"""
    <article class="feature-card">
      <div class="flex items-center justify-between mb-3">
        <span class="text-xl">{@feature.icon}</span>
        <span class="text-[10px] px-2 py-1 rounded bg-elevated border border-border text-muted-foreground uppercase tracking-wider">
          {@feature.category}
        </span>
      </div>
      <h3 class="font-bold text-[15px] mb-2">{@feature.title}</h3>
      <p class="text-muted-foreground text-xs leading-relaxed">{@feature.description}</p>
    </article>
    """
  end

  defp core_features do
    [
      %{
        icon: "◉",
        category: "runtime",
        title: "BEAM-Native Agent Model",
        description: "Agents are modeled as typed state transitions with isolation boundaries that align with OTP process semantics."
      },
      %{
        icon: "⟡",
        category: "validation",
        title: "Schema-Validated Actions",
        description: "Action contracts enforce required fields, types, and defaults before state changes are applied."
      },
      %{
        icon: "⫸",
        category: "signals",
        title: "Signal Routing and Coordination",
        description: "Route domain events to behavior modules without tightly coupling producers and consumers."
      },
      %{
        icon: "⌚",
        category: "directives",
        title: "Directives and Scheduling",
        description: "Request emit/schedule side effects declaratively, including recurring time-based behavior."
      }
    ]
  end

  defp integration_features do
    [
      %{
        icon: "◎",
        category: "liveview",
        title: "LiveView Integration Patterns",
        description: "Bind LiveView events directly to agent commands while rendering from immutable, deterministic state."
      },
      %{
        icon: "◇",
        category: "ecosystem",
        title: "Composable Ecosystem",
        description: "Mix jido, jido_action, jido_signal, jido_ai, and req_llm to match your architecture and rollout pace."
      }
    ]
  end

  defp production_features do
    [
      %{
        icon: "⚙",
        category: "ops",
        title: "Supervision and Fault Isolation",
        description: "Use OTP supervision to recover fast, constrain blast radius, and keep healthy flows online during failures."
      },
      %{
        icon: "📈",
        category: "telemetry",
        title: "Telemetry for Production Visibility",
        description: "Instrument command latency, queue pressure, and failures with stable signals for alerting and SLO tracking."
      }
    ]
  end
end
