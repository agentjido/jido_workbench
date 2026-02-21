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
       page_title: "Jido Features",
       meta_description:
         "Explore runtime capabilities, orchestration strategies, and ecosystem packages for building reliable multi-agent systems with Jido.",
       stack_layers: stack_layers(),
       pillars: pillars(),
       categories: categories(),
       audience_paths: audience_paths(),
       proof_paths: proof_paths(),
       adoption_lanes: adoption_lanes()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/features">
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <section class="text-center mb-16 animate-fade-in">
          <div class="inline-block px-4 py-2 rounded mb-5 bg-primary/10 border border-primary/30">
            <span class="text-primary text-[11px] font-semibold tracking-widest uppercase">
              RUNTIME-FIRST CAPABILITIES
            </span>
          </div>
          <h1 class="text-4xl font-bold mb-4 tracking-tight">
            Capabilities for <span class="text-primary">reliable multi-agent systems</span>
          </h1>
          <p class="text-lg text-muted-foreground max-w-3xl mx-auto mb-8">
            Jido is a runtime for reliable, multi-agent systems. Use it without any LLM layer, or add LLM capabilities when they fit your workload.
          </p>

          <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 max-w-3xl mx-auto">
            <div class="feature-card text-center py-4">
              <div class="text-lg font-bold text-primary">8</div>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">feature categories</div>
            </div>
            <div class="feature-card text-center py-4">
              <div class="text-lg font-bold text-accent-cyan">7</div>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">deep-dive pages</div>
            </div>
            <div class="feature-card text-center py-4">
              <div class="text-lg font-bold text-accent-yellow">optional</div>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">LLM layer</div>
            </div>
          </div>
        </section>

        <section id="features-operating-model" class="mb-16 opacity-0" phx-hook="ScrollReveal">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Operating model</span>
            <span class="text-[11px] text-muted-foreground">runtime core + optional intelligence add-ons</span>
          </div>

          <div class="grid lg:grid-cols-3 gap-4">
            <article class="feature-card lg:col-span-2">
              <h2 class="text-lg font-bold mb-4">How capabilities stack</h2>
              <div class="space-y-3">
                <%= for layer <- @stack_layers do %>
                  <div class="rounded border border-border bg-surface/50 p-4">
                    <div class="flex items-center justify-between gap-3 mb-2">
                      <span class={"text-[11px] font-bold uppercase tracking-wider #{layer.accent_class}"}>
                        {layer.label}
                      </span>
                      <span class="text-[11px] text-muted-foreground">{layer.fit}</span>
                    </div>
                    <p class="text-xs text-muted-foreground leading-relaxed mb-3">{layer.summary}</p>
                    <div class="flex flex-wrap gap-2">
                      <%= for pkg <- layer.packages do %>
                        <.package_chip package={pkg} />
                      <% end %>
                    </div>
                  </div>
                <% end %>
              </div>
            </article>

            <article class="feature-card">
              <h2 class="text-lg font-bold mb-3">Design stance</h2>
              <ul class="space-y-2 text-xs text-muted-foreground leading-relaxed">
                <li>Runtime reliability is the default posture.</li>
                <li>Coordination is explicit with Actions, Signals, and Directives.</li>
                <li>LLM integration is optional and composable.</li>
                <li>Adopt one workflow first, then expand package scope.</li>
              </ul>
              <div class="mt-6 space-y-2">
                <.link navigate="/features/beam-for-ai-builders" class="block text-xs text-primary hover:underline">
                  Why Elixir/OTP for AI workloads ->
                </.link>
                <.link navigate="/features/jido-vs-framework-first-stacks" class="block text-xs text-primary hover:underline">
                  Runtime-first vs framework-first ->
                </.link>
              </div>
            </article>
          </div>
        </section>

        <section id="features-pillars" class="mb-16 opacity-0" phx-hook="ScrollReveal">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Core pillars</span>
            <span class="text-[11px] text-muted-foreground">architecture, coordination, operations, adoption</span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for pillar <- @pillars do %>
              <.pillar_card pillar={pillar} />
            <% end %>
          </div>
        </section>

        <section id="features-category-explorer" class="mb-16 opacity-0" phx-hook="ScrollReveal">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Category explorer</span>
            <span class="text-[11px] text-muted-foreground">concrete capabilities + package proof</span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for category <- @categories do %>
              <.category_card category={category} />
            <% end %>
          </div>
        </section>

        <section id="features-audience-paths" class="mb-16 opacity-0" phx-hook="ScrollReveal">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Audience quick paths</span>
            <span class="text-[11px] text-muted-foreground">start where your team has risk right now</span>
          </div>
          <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
            <%= for audience <- @audience_paths do %>
              <.audience_card audience={audience} />
            <% end %>
          </div>
        </section>

        <section id="features-proof-panel" class="mb-16 opacity-0" phx-hook="ScrollReveal">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Proof jump panel</span>
            <span class="text-[11px] text-muted-foreground">example + docs + ecosystem in one hop</span>
          </div>
          <div class="grid md:grid-cols-2 gap-4">
            <%= for proof <- @proof_paths do %>
              <.proof_card proof={proof} />
            <% end %>
          </div>
        </section>

        <section id="features-maturity-guidance" class="mb-16 opacity-0" phx-hook="ScrollReveal">
          <div class="flex justify-between items-center mb-6">
            <span class="text-sm font-bold tracking-wider uppercase">Adoption guidance by maturity</span>
            <span class="text-[11px] text-muted-foreground">status labels: Stable / Beta / Experimental</span>
          </div>
          <div class="grid md:grid-cols-3 gap-4">
            <%= for lane <- @adoption_lanes do %>
              <.lane_card lane={lane} />
            <% end %>
          </div>
        </section>

        <section id="features-cta" class="opacity-0" phx-hook="ScrollReveal">
          <div class="cta-glow rounded-lg p-12 text-center">
            <h2 class="text-2xl font-bold mb-3">Move from feature evaluation to implementation</h2>
            <p class="text-secondary-foreground text-sm mb-6 max-w-2xl mx-auto">
              Start with one production-relevant workflow, keep the package set minimal, and expand only after reliability and operations checks are green.
            </p>
            <div class="flex flex-wrap justify-center gap-3">
              <.link
                navigate="/docs/getting-started"
                class="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-3 rounded transition-colors"
              >
                GET BUILDING ->
              </.link>
              <.link
                navigate="/ecosystem/package-matrix"
                class="border border-accent-cyan text-accent-cyan hover:bg-accent-cyan/10 text-[13px] font-medium px-7 py-3 rounded transition-colors"
              >
                VIEW PACKAGE MATRIX
              </.link>
            </div>
          </div>
        </section>
      </div>
    </.marketing_layout>
    """
  end

  attr :pillar, :map, required: true

  defp pillar_card(assigns) do
    ~H"""
    <.link navigate={@pillar.href} class="feature-card group block h-full hover:-translate-y-0.5 transition-transform duration-200">
      <div class="flex items-start justify-between gap-3 mb-3">
        <span class={"text-2xl #{@pillar.accent_class}"}>{@pillar.icon}</span>
        <span class="text-[10px] px-2 py-1 rounded border border-border bg-surface text-muted-foreground uppercase tracking-wider">
          {@pillar.badge}
        </span>
      </div>
      <h3 class="font-bold text-[15px] mb-2 group-hover:text-primary transition-colors">{@pillar.title}</h3>
      <p class="text-muted-foreground text-xs leading-relaxed">{@pillar.description}</p>
    </.link>
    """
  end

  attr :category, :map, required: true

  defp category_card(assigns) do
    ~H"""
    <article class="feature-card h-full">
      <div class="flex items-start justify-between gap-3 mb-3">
        <.link navigate={@category.deep_dive} class="font-bold text-[15px] hover:text-primary transition-colors">
          {@category.title}
        </.link>
        <span class="text-[10px] px-2 py-1 rounded border border-border bg-surface text-muted-foreground uppercase tracking-wider">
          {@category.badge}
        </span>
      </div>

      <p class="text-muted-foreground text-xs leading-relaxed mb-4">{@category.summary}</p>

      <ul class="space-y-1.5 text-xs text-secondary-foreground mb-4">
        <%= for capability <- @category.capabilities do %>
          <li>• {capability}</li>
        <% end %>
      </ul>

      <div class="flex flex-wrap gap-2 mb-4">
        <%= for package <- @category.packages do %>
          <.package_chip package={package} />
        <% end %>
      </div>

      <div class="text-[11px] text-muted-foreground">
        <span class="font-semibold text-foreground">Best for:</span> {@category.audience}
      </div>
      <.link navigate={@category.deep_dive} class="inline-block mt-3 text-xs text-primary hover:underline">
        open deep dive ->
      </.link>
    </article>
    """
  end

  attr :audience, :map, required: true

  defp audience_card(assigns) do
    ~H"""
    <article class="feature-card h-full">
      <h3 class="font-bold text-[15px] mb-2">{@audience.title}</h3>
      <p class="text-muted-foreground text-xs leading-relaxed mb-4">{@audience.question}</p>
      <div class="space-y-2 text-xs">
        <.link navigate={@audience.start.href} class="block text-primary hover:underline">
          start: {@audience.start.label}
        </.link>
        <.link navigate={@audience.proof.href} class="block text-primary hover:underline">
          proof: {@audience.proof.label}
        </.link>
        <.link navigate={@audience.docs.href} class="block text-primary hover:underline">
          docs: {@audience.docs.label}
        </.link>
      </div>
    </article>
    """
  end

  attr :proof, :map, required: true

  defp proof_card(assigns) do
    ~H"""
    <article class="feature-card h-full">
      <h3 class="font-bold text-[15px] mb-2">{@proof.title}</h3>
      <p class="text-muted-foreground text-xs leading-relaxed mb-4">{@proof.goal}</p>
      <div class="space-y-2 text-xs">
        <.link navigate={@proof.example.href} class="block text-primary hover:underline">
          example: {@proof.example.label}
        </.link>
        <.link navigate={@proof.docs.href} class="block text-primary hover:underline">
          docs: {@proof.docs.label}
        </.link>
        <.link navigate={@proof.package.href} class="block text-primary hover:underline">
          ecosystem: {@proof.package.label}
        </.link>
      </div>
    </article>
    """
  end

  attr :lane, :map, required: true

  defp lane_card(assigns) do
    ~H"""
    <article class="feature-card h-full">
      <h3 class="font-bold text-[15px] mb-1">{@lane.title}</h3>
      <p class="text-muted-foreground text-xs leading-relaxed mb-4">{@lane.summary}</p>

      <div class="space-y-2 mb-4">
        <%= for package <- @lane.packages do %>
          <div class="flex items-center justify-between gap-2 rounded border border-border bg-surface/50 px-2.5 py-2">
            <.link navigate={"/ecosystem/#{package.id}"} class="text-xs font-semibold hover:text-primary transition-colors">
              {package.label}
            </.link>
            <span class={status_badge_class(package.status)}>{status_label(package.status)}</span>
          </div>
        <% end %>
      </div>

      <p class="text-[11px] text-muted-foreground leading-relaxed">{@lane.note}</p>
    </article>
    """
  end

  attr :package, :map, required: true

  defp package_chip(assigns) do
    ~H"""
    <.link
      navigate={"/ecosystem/#{@package.id}"}
      class="text-[10px] px-2 py-1 rounded border border-border bg-elevated text-foreground hover:border-primary/40 transition-colors"
    >
      {@package.label} · {status_label(@package.status)}
    </.link>
    """
  end

  defp status_badge_class(:stable),
    do: "text-[10px] px-2 py-1 rounded border border-green-500/30 bg-green-500/10 text-green-400"

  defp status_badge_class(:beta),
    do: "text-[10px] px-2 py-1 rounded border border-accent-yellow/40 bg-accent-yellow/10 text-accent-yellow"

  defp status_badge_class(:experimental),
    do: "text-[10px] px-2 py-1 rounded border border-accent-red/40 bg-accent-red/10 text-accent-red"

  defp status_badge_class(_),
    do: "text-[10px] px-2 py-1 rounded border border-border bg-elevated text-muted-foreground"

  defp status_label(:stable), do: "Stable"
  defp status_label(:beta), do: "Beta"
  defp status_label(:experimental), do: "Experimental"
  defp status_label(:planned), do: "Planned"
  defp status_label(_), do: "Unknown"

  defp stack_layers do
    [
      %{
        label: "Runtime core",
        fit: "required",
        accent_class: "text-primary",
        summary: "The runtime surface for deterministic Agent behavior, typed Actions, and Signal-based coordination.",
        packages: [
          %{id: "jido", label: "jido", status: :beta},
          %{id: "jido_action", label: "jido_action", status: :beta},
          %{id: "jido_signal", label: "jido_signal", status: :beta}
        ]
      },
      %{
        label: "Strategy layer",
        fit: "optional",
        accent_class: "text-accent-cyan",
        summary: "Swap orchestration strategies based on workload shape: FSM, behavior tree, or durable DAG workflows.",
        packages: [
          %{id: "jido_runic", label: "jido_runic", status: :experimental},
          %{id: "jido_behaviortree", label: "jido_behaviortree", status: :experimental}
        ]
      },
      %{
        label: "Intelligence layer",
        fit: "optional",
        accent_class: "text-accent-yellow",
        summary: "Add LLM and reasoning capabilities when needed. Keep runtime architecture unchanged.",
        packages: [
          %{id: "jido_ai", label: "jido_ai", status: :beta},
          %{id: "req_llm", label: "req_llm", status: :stable},
          %{id: "llm_db", label: "llm_db", status: :stable}
        ]
      },
      %{
        label: "Integration and operations",
        fit: "optional",
        accent_class: "text-accent-red",
        summary: "Bridge existing systems and observability stacks without rewriting the runtime model.",
        packages: [
          %{id: "ash_jido", label: "ash_jido", status: :experimental},
          %{id: "jido_messaging", label: "jido_messaging", status: :experimental},
          %{id: "jido_otel", label: "jido_otel", status: :experimental}
        ]
      }
    ]
  end

  defp pillars do
    [
      %{
        icon: "◉",
        badge: "pillar 1",
        title: "Reliability by architecture",
        description: "Run Agents under OTP supervision and isolate failures to process boundaries, not shared app state.",
        href: "/features/reliability-by-architecture",
        accent_class: "text-primary"
      },
      %{
        icon: "⧉",
        badge: "pillar 2",
        title: "Coordination you can reason about",
        description: "Represent inter-agent behavior with typed Actions, named Signals, and inspectable Directives.",
        href: "/features/multi-agent-coordination",
        accent_class: "text-accent-yellow"
      },
      %{
        icon: "⬡",
        badge: "pillar 3",
        title: "Operations and observability",
        description: "Instrument runtime behavior with telemetry, traces, and playbook-friendly operational boundaries.",
        href: "/features/operations-observability",
        accent_class: "text-accent-cyan"
      },
      %{
        icon: "▣",
        badge: "pillar 4",
        title: "Composable incremental adoption",
        description: "Start with one supervised workflow, then add packages and integrations as requirements harden.",
        href: "/features/incremental-adoption",
        accent_class: "text-accent-red"
      }
    ]
  end

  defp categories do
    [
      %{
        title: "Runtime reliability and lifecycle control",
        badge: "runtime",
        summary: "Agent execution is managed as a runtime concern, with explicit lifecycle and restart semantics.",
        capabilities: [
          "Supervise Agents with Jido.AgentServer",
          "Contain failures to process-level boundaries",
          "Recover predictable workflows through OTP restarts"
        ],
        packages: [
          %{id: "jido", label: "jido", status: :beta},
          %{id: "jido_otel", label: "jido_otel", status: :experimental}
        ],
        audience: "Elixir platform engineers, SRE/platform teams",
        deep_dive: "/features/reliability-by-architecture"
      },
      %{
        title: "Deterministic state transitions and typed capabilities",
        badge: "actions",
        summary: "Keep decision logic deterministic and separately testable from process runtime.",
        capabilities: [
          "Use cmd/2 for explicit state transitions",
          "Validate Action input and output contracts",
          "Emit typed Directives for side effects"
        ],
        packages: [
          %{id: "jido", label: "jido", status: :beta},
          %{id: "jido_action", label: "jido_action", status: :beta}
        ],
        audience: "AI product engineers, Elixir teams",
        deep_dive: "/features/reliability-by-architecture"
      },
      %{
        title: "Signal routing and multi-agent coordination",
        badge: "coordination",
        summary: "Model coordination as explicit contracts instead of hidden callback choreography.",
        capabilities: [
          "Route named Signals to typed Actions",
          "Track message flow with CloudEvents-compatible envelopes",
          "Test route + directive behavior in focused unit paths"
        ],
        packages: [
          %{id: "jido_signal", label: "jido_signal", status: :beta},
          %{id: "jido_action", label: "jido_action", status: :beta}
        ],
        audience: "AI product engineers, staff architects",
        deep_dive: "/features/multi-agent-coordination"
      },
      %{
        title: "Strategy-based orchestration",
        badge: "strategy",
        summary: "Choose orchestration strategies for workload shape without replacing the core runtime model.",
        capabilities: [
          "Run direct and FSM strategies for deterministic flows",
          "Use behavior trees for policy-heavy decision loops",
          "Use DAG workflows for dependency-aware execution"
        ],
        packages: [
          %{id: "jido", label: "jido", status: :beta},
          %{id: "jido_behaviortree", label: "jido_behaviortree", status: :experimental},
          %{id: "jido_runic", label: "jido_runic", status: :experimental}
        ],
        audience: "advanced builders, architecture leads",
        deep_dive: "/features/multi-agent-coordination"
      },
      %{
        title: "Tool execution and safe automation",
        badge: "tools",
        summary: "Represent tool use as typed Action boundaries so operational controls are inspectable.",
        capabilities: [
          "Use Action contracts for tool I/O and validation",
          "Attach retries and timeout controls at execution boundaries",
          "Run browser and integration tools through the same runtime model"
        ],
        packages: [
          %{id: "jido_action", label: "jido_action", status: :beta},
          %{id: "jido_browser", label: "jido_browser", status: :experimental},
          %{id: "jido_ai", label: "jido_ai", status: :beta}
        ],
        audience: "AI product teams, security-conscious teams",
        deep_dive: "/features/multi-agent-coordination"
      },
      %{
        title: "LLM-optional intelligence layer",
        badge: "intelligence",
        summary: "Add LLM features when needed, but keep the runtime valuable for non-LLM workflows.",
        capabilities: [
          "Keep core runtime independent of model providers",
          "Add ask/await and reasoning strategies through add-on packages",
          "Swap models through stable provider abstractions"
        ],
        packages: [
          %{id: "jido_ai", label: "jido_ai", status: :beta},
          %{id: "req_llm", label: "req_llm", status: :stable},
          %{id: "llm_db", label: "llm_db", status: :stable}
        ],
        audience: "AI engineers, mixed-stack evaluators",
        deep_dive: "/features/beam-for-ai-builders"
      },
      %{
        title: "Operations and observability",
        badge: "operations",
        summary: "Operate agents with telemetry and trace boundaries that map to incident workflows.",
        capabilities: [
          "Expose runtime health and queue pressure through telemetry",
          "Trace cross-agent workflows with consistent identifiers",
          "Run readiness and incident playbooks against known runtime signals"
        ],
        packages: [
          %{id: "jido", label: "jido", status: :beta},
          %{id: "jido_otel", label: "jido_otel", status: :experimental},
          %{id: "jido_messaging", label: "jido_messaging", status: :experimental}
        ],
        audience: "SRE/platform engineers, technical leads",
        deep_dive: "/features/operations-observability"
      },
      %{
        title: "Integration and incremental adoption",
        badge: "adoption",
        summary: "Use bounded pilots and clear interfaces to adopt Jido without a platform rewrite.",
        capabilities: [
          "Start with one Agent in existing supervision trees",
          "Bridge existing data resources and messaging systems",
          "Grow package footprint based on measured outcomes"
        ],
        packages: [
          %{id: "ash_jido", label: "ash_jido", status: :experimental},
          %{id: "jido_messaging", label: "jido_messaging", status: :experimental},
          %{id: "jido_studio", label: "jido_studio", status: :beta}
        ],
        audience: "polyglot evaluators, staff architects, engineering managers",
        deep_dive: "/features/incremental-adoption"
      }
    ]
  end

  defp audience_paths do
    [
      %{
        title: "Elixir platform engineer",
        question: "How does this map to OTP patterns we already trust?",
        start: %{label: "Reliability by architecture", href: "/features/reliability-by-architecture"},
        proof: %{label: "Counter Agent example", href: "/examples/counter-agent"},
        docs: %{label: "Architecture reference", href: "/docs/reference/architecture"}
      },
      %{
        title: "AI product engineer",
        question: "How do we ship tool-using workflows without brittle behavior?",
        start: %{label: "Multi-agent coordination", href: "/features/multi-agent-coordination"},
        proof: %{label: "Demand Tracker example", href: "/examples/demand-tracker-agent"},
        docs: %{label: "Guides", href: "/docs/guides"}
      },
      %{
        title: "Staff architect / tech lead",
        question: "Can we adopt this incrementally with governance and rollback paths?",
        start: %{label: "Incremental adoption", href: "/features/incremental-adoption"},
        proof: %{label: "Reference architectures", href: "/build/reference-architectures"},
        docs: %{label: "Security and governance", href: "/docs/operations/security-and-governance"}
      },
      %{
        title: "Python or TypeScript evaluator",
        question: "Why this runtime without committing to a full Elixir rewrite?",
        start: %{label: "BEAM for AI builders", href: "/features/beam-for-ai-builders"},
        proof: %{label: "Mixed-stack integration", href: "/build/mixed-stack-integration"},
        docs: %{label: "Core concepts", href: "/docs/concepts"}
      },
      %{
        title: "Platform / SRE engineer",
        question: "Can we observe failures and enforce readiness criteria?",
        start: %{label: "Operations and observability", href: "/features/operations-observability"},
        proof: %{label: "Telemetry SLO sentinel", href: "/examples/telemetry-slo-budget-sentinel"},
        docs: %{label: "Production readiness checklist", href: "/docs/operations/production-readiness-checklist"}
      },
      %{
        title: "Engineering manager / CTO",
        question: "What does phased adoption look like in 30/60/90-day terms?",
        start: %{label: "Executive brief", href: "/features/executive-brief"},
        proof: %{label: "Package matrix", href: "/ecosystem/package-matrix"},
        docs: %{label: "Quickstarts by persona", href: "/build/quickstarts-by-persona"}
      }
    ]
  end

  defp proof_paths do
    [
      %{
        title: "Non-LLM runtime proof",
        goal: "Validate that Jido is useful without any model integration.",
        example: %{label: "Counter Agent", href: "/examples/counter-agent"},
        docs: %{label: "Agent fundamentals", href: "/training/agent-fundamentals"},
        package: %{label: "jido", href: "/ecosystem/jido"}
      },
      %{
        title: "Coordination proof",
        goal: "Verify explicit route-to-action contracts in multi-agent workflows.",
        example: %{label: "Demand Tracker Agent", href: "/examples/demand-tracker-agent"},
        docs: %{label: "Signals routing training", href: "/training/signals-routing"},
        package: %{label: "jido_signal", href: "/ecosystem/jido_signal"}
      },
      %{
        title: "Operations proof",
        goal: "Check readiness and incident response behavior before rollout.",
        example: %{label: "Telemetry SLO budget sentinel", href: "/examples/telemetry-slo-budget-sentinel"},
        docs: %{label: "Incident playbooks", href: "/docs/operations/incident-playbooks"},
        package: %{label: "jido_otel", href: "/ecosystem/jido_otel"}
      },
      %{
        title: "LLM add-on proof",
        goal: "Add model-powered behavior without rewriting runtime boundaries.",
        example: %{label: "Document-grounded policy Q&A", href: "/examples/document-grounded-policy-qna-agent"},
        docs: %{label: "Tool response cookbook", href: "/docs/guides/cookbook/tool-response"},
        package: %{label: "jido_ai", href: "/ecosystem/jido_ai"}
      }
    ]
  end

  defp adoption_lanes do
    [
      %{
        title: "Start here",
        summary: "Build first production candidate with core runtime capabilities.",
        packages: [
          %{id: "jido", label: "jido", status: :beta},
          %{id: "jido_action", label: "jido_action", status: :beta},
          %{id: "jido_signal", label: "jido_signal", status: :beta}
        ],
        note: "Use one supervised workflow and explicit action/signal tests before adding cross-system complexity."
      },
      %{
        title: "Expand next",
        summary: "Add intelligence and integrations once runtime behavior is stable.",
        packages: [
          %{id: "req_llm", label: "req_llm", status: :stable},
          %{id: "llm_db", label: "llm_db", status: :stable},
          %{id: "jido_ai", label: "jido_ai", status: :beta}
        ],
        note: "Treat LLM features as incremental add-ons so model/provider changes do not force runtime redesign."
      },
      %{
        title: "Evaluate with guardrails",
        summary: "Explore experimental strategy and integration packages with bounded pilots.",
        packages: [
          %{id: "jido_runic", label: "jido_runic", status: :experimental},
          %{id: "jido_behaviortree", label: "jido_behaviortree", status: :experimental},
          %{id: "ash_jido", label: "ash_jido", status: :experimental}
        ],
        note: "Use workload-specific acceptance criteria and explicit rollback plans before expanding to production scope."
      }
    ]
  end
end
