defmodule AgentJidoWeb.JidoHomeLive do
  use AgentJidoWeb, :live_view

  alias AgentJido.LandingContent

  import AgentJidoWeb.Jido.HomeSections
  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "A Runtime for Reliable Multi-Agent Systems",
       meta_description:
         "Jido is a runtime for reliable, multi-agent systems, built on Elixir/OTP for fault isolation, concurrency, and production uptime.",
       install_tab: "full",
       ecosystem_overview: LandingContent.home_ecosystem_overview()
     )}
  end

  @impl true
  def handle_event("select_install_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, install_tab: tab)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout
      current_path="/"
      layout_class="home-layout"
      current_scope={@current_scope}
      analytics_identity={@analytics_identity}
    >
      <div id="home-page" class="container max-w-[1000px] mx-auto px-6">
        <.hero_section />
        <.pillars_section />
        <.ecosystem_section ecosystem_overview={@ecosystem_overview} />
        <.install_section install_tab={@install_tab} />
        <.quick_start_code />
        <.why_elixir_otp_section />
        <.build_first_agent_cta />
      </div>
    </.marketing_layout>
    """
  end

  defp hero_section(assigns) do
    ~H"""
    <section class="text-center mb-16 animate-fade-in">
      <div class="inline-block bg-primary/10 border border-primary/30 px-4 py-2 rounded mb-6">
        <span class="home-eyebrow-label text-[11px] font-semibold tracking-widest">
          RELIABLE MULTI-AGENT RUNTIME
        </span>
      </div>

      <h1 class="text-4xl sm:text-[42px] font-bold leading-tight mb-5 tracking-tight">
        A runtime for reliable, <br />
        <span class="text-primary">multi-agent systems.</span>
      </h1>

      <p class="text-secondary-foreground text-[15px] leading-relaxed mb-6 max-w-lg mx-auto">
        Build supervised agents that crash and recover automatically.
      </p>

      <div class="flex items-center gap-4 justify-center mb-12">
        <.link
          navigate="/getting-started"
          class="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-5 rounded transition-colors"
        >
          GET BUILDING →
        </.link>
        <.link
          navigate="/features"
          class="home-subtle-link text-[13px] font-semibold transition-colors"
        >
          EXPLORE FEATURES →
        </.link>
      </div>

      <p class="home-muted-copy text-[11px] leading-relaxed max-w-xl mx-auto -mt-6">
        New to Elixir?
        <.link navigate="/getting-started" class="text-primary hover:underline font-semibold ml-1">
          Start here.
        </.link>
        <span class="mx-2">•</span>
        Already an Elixir expert?
        <a href="#quick-start" class="text-primary hover:underline font-semibold ml-1">
          Jump to quick start.
        </a>
      </p>
    </section>
    """
  end

  defp pillars_section(assigns) do
    pillars = [
      %{
        icon: "◉",
        title: "Reliability by architecture",
        desc:
          "Each agent runs in its own BEAM process with isolated state. When agents crash, OTP supervisors restart them in milliseconds — no external orchestrator needed.",
        icon_color_class: "text-accent-green",
        chip_class: "home-pillar-chip home-pillar-chip-green",
        link_class: "home-pillar-link home-pillar-link-green",
        link: "/features/reliability-by-architecture"
      },
      %{
        icon: "⧉",
        title: "Coordination you can reason about",
        desc:
          "Multi-agent behavior is explicit and testable. Actions define capabilities, Signals handle communication, and Directives model orchestration — not role-play in a single prompt.",
        icon_color_class: "text-accent-cyan",
        chip_class: "home-pillar-chip home-pillar-chip-cyan",
        link_class: "home-pillar-link home-pillar-link-cyan",
        link: "/features/multi-agent-coordination"
      },
      %{
        icon: "⬡",
        title: "Production operations built in",
        desc:
          "Telemetry, debugging workflows, and operational controls are first-class. Observe agent behavior, trace workflows across processes, and run with confidence under real load.",
        icon_color_class: "text-accent-yellow",
        chip_class: "home-pillar-chip home-pillar-chip-yellow",
        link_class: "home-pillar-link home-pillar-link-yellow",
        link: "/features/operations-observability"
      },
      %{
        icon: "▣",
        title: "Composable, incremental adoption",
        desc:
          "Adopt only what you need now, expand safely later. Start with the core runtime, add AI capabilities, layer on tooling — each package composes without lock-in.",
        icon_color_class: "text-accent-red",
        chip_class: "home-pillar-chip home-pillar-chip-red",
        link_class: "home-pillar-link home-pillar-link-red",
        link: "/features/incremental-adoption"
      }
    ]

    assigns = assign(assigns, :pillars, pillars)

    ~H"""
    <section id="pillars" class="home-pillars-section mb-20 opacity-0" phx-hook="ScrollReveal">
      <div class="text-center mb-16">
        <h2 class="text-3xl font-bold tracking-tight mb-4">Why Jido</h2>
        <p class="home-muted-copy text-sm leading-relaxed max-w-lg mx-auto">
          Prototyping is common. Reliable operation is rare. <br /> Jido is built for operation.
        </p>
      </div>

      <div class="home-pillars-grid">
        <%= for pillar <- @pillars do %>
          <.link navigate={pillar.link} class="home-pillar-card group">
            <div class={pillar.chip_class}>
              <span class={"text-2xl leading-none #{pillar.icon_color_class}"}>{pillar.icon}</span>
            </div>
            <h3 class="text-lg sm:text-xl font-bold mb-3 leading-tight group-hover:text-primary transition-colors duration-200">
              {pillar.title}
            </h3>
            <p class="home-muted-copy text-[15px] leading-relaxed max-w-md mx-auto mb-4">{pillar.desc}</p>
            <span class={pillar.link_class}>Learn more →</span>
          </.link>
        <% end %>
      </div>
    </section>
    """
  end

  defp ecosystem_section(assigns) do
    layer_rows =
      assigns.ecosystem_overview.rows
      |> Enum.filter(&(&1.id in [:app, :ai, :foundation]))

    core_package =
      assigns.ecosystem_overview.rows
      |> Enum.find(&(&1.id == :core))
      |> case do
        nil -> nil
        row -> List.first(row.packages)
      end

    assigns =
      assigns
      |> assign(:ecosystem_layer_rows, layer_rows)
      |> assign(:ecosystem_core_package, core_package)

    ~H"""
    <section id="ecosystem" class="home-ecosystem-section mb-16 opacity-0" phx-hook="ScrollReveal">
      <div id="home-ecosystem-section">
        <div class="home-ecosystem-header">
          <div>
            <h2 class="text-2xl font-bold tracking-tight">Ecosystem</h2>
            <p class="home-ecosystem-summary">composable by design · ground up</p>
          </div>

          <.link navigate="/ecosystem" class="home-ecosystem-explore-link">
            Explore the full ecosystem →
          </.link>
        </div>

        <div class="home-ecosystem-rows">
          <%= for row <- @ecosystem_layer_rows do %>
            <article id={"home-ecosystem-row-#{row.id}"} class={"home-ecosystem-row home-ecosystem-row-#{row.id}"}>
              <div class="home-ecosystem-row-header">
                <h3 class="home-ecosystem-row-title">{row.label}</h3>
                <span class={"home-ecosystem-count-badge home-ecosystem-count-badge-#{row.id}"}>
                  {package_count_label(row.package_count)}
                </span>
                <div class="home-ecosystem-chips">
                  <span :for={chip <- row.chips} class={"home-ecosystem-chip home-ecosystem-chip-#{row.id}"}>
                    {chip}
                  </span>
                </div>
              </div>

              <p class="home-ecosystem-packages">
                <%= for {pkg, idx} <- Enum.with_index(row.packages) do %>
                  <span :if={idx > 0} class="home-ecosystem-separator" aria-hidden="true">·</span>
                  <.link
                    id={"home-ecosystem-package-#{pkg.id}"}
                    navigate={pkg.path}
                    class="home-ecosystem-package-link"
                  >
                    {pkg.name}
                  </.link>
                <% end %>
              </p>
            </article>
          <% end %>

          <div :if={@ecosystem_core_package} class="home-ecosystem-connector" aria-hidden="true">
            <div class="home-ecosystem-connector-line"></div>
            <span class="home-ecosystem-connector-arrow">↓</span>
          </div>

          <article :if={@ecosystem_core_package} id="home-ecosystem-core-anchor" class="home-ecosystem-core-row">
            <.link
              id={"home-ecosystem-package-#{@ecosystem_core_package.id}"}
              navigate={@ecosystem_core_package.path}
              class="home-ecosystem-core-hit"
            >
              <div class="home-ecosystem-core-header">
                <span class="home-ecosystem-core-link">{@ecosystem_core_package.name}</span>
                <p class="home-ecosystem-core-copy">
                  <span class="home-ecosystem-core-kanji">自動</span>
                  <span>Autonomous agent framework</span>
                </p>
              </div>
            </.link>
          </article>
        </div>
      </div>
    </section>
    """
  end

  defp package_count_label(1), do: "1 pkg"
  defp package_count_label(count), do: "#{count} pkgs"

  defp install_section(assigns) do
    install_configs = %{
      "full" => %{
        comment: "# Full stack: LLM-powered agents",
        deps: [{":jido_ai", ~s("~> 0.1.0"), ""}],
        note: "# includes jido, req_llm, llm_db"
      },
      "core" => %{
        comment: "# Core only: runtime without LLM dependencies",
        deps: [{":jido", ~s("~> 0.1.0"), ""}],
        note: "# agent runtime, supervision, orchestration"
      },
      "custom" => %{
        comment: "# Custom: adopt what you need",
        deps: [
          {":jido", ~s("~> 0.1.0"), "# runtime"},
          {":jido_action", ~s("~> 0.1.0"), "# typed actions"},
          {":jido_signal", ~s("~> 0.1.0"), "# signal routing"},
          {":req_llm", ~s("~> 0.1.0"), "# LLM client"}
        ],
        note: ""
      }
    }

    assigns = assign(assigns, :config, Map.get(install_configs, assigns.install_tab))

    ~H"""
    <section id="install-section" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="mb-5">
        <h2 class="text-xl font-bold tracking-tight mb-2">Choose your stack</h2>
        <p class="home-muted-copy text-sm">
          Adopt only what you need now, expand safely later.
        </p>
      </div>

      <div class="flex gap-1 mb-4">
        <button
          phx-click="select_install_tab"
          phx-value-tab="full"
          class={"px-5 py-2.5 rounded text-[11px] font-semibold transition-colors border #{if @install_tab == "full", do: "border-primary bg-primary/10 text-primary", else: "border-border text-secondary-foreground hover:text-foreground"}"}
        >
          AI AGENTS
        </button>
        <button
          phx-click="select_install_tab"
          phx-value-tab="core"
          class={"px-5 py-2.5 rounded text-[11px] font-semibold transition-colors border #{if @install_tab == "core", do: "border-primary bg-primary/10 text-primary", else: "border-border text-secondary-foreground hover:text-foreground"}"}
        >
          CORE RUNTIME
        </button>
        <button
          phx-click="select_install_tab"
          phx-value-tab="custom"
          class={"px-5 py-2.5 rounded text-[11px] font-semibold transition-colors border #{if @install_tab == "custom", do: "border-primary bg-primary/10 text-primary", else: "border-border text-secondary-foreground hover:text-foreground"}"}
        >
          CUSTOM
        </button>
      </div>

      <div class="code-block overflow-hidden">
        <div class="code-header">
          <span class="home-muted-copy text-xs">mix.exs</span>
          <button
            data-copy-button
            data-content={generate_deps_code(@config)}
            class="bg-surface border border-border text-secondary-foreground px-3 py-1 rounded text-[10px] hover:text-foreground transition-colors"
          >
            COPY
          </button>
        </div>
        <div class="p-5">
          <pre class="text-[13px] leading-relaxed"><%= render_deps_code(@config) %></pre>
        </div>
      </div>
    </section>
    """
  end

  defp generate_deps_code(config) do
    deps_str =
      config.deps
      |> Enum.map_join(",\n", fn {name, version, _note} -> "    {#{name}, #{version}}" end)

    "def deps do\n  [\n#{deps_str}\n  ]\nend"
  end

  defp render_deps_code(config) do
    last_index = length(config.deps) - 1

    deps_lines =
      config.deps
      |> Enum.with_index()
      |> Enum.map_join("\n", fn {{name, version, note}, idx} ->
        comma = if idx < last_index, do: ",", else: ""
        note_html = if note != "", do: ~s( <span class="syntax-comment">#{note}</span>), else: ""

        ~s(    &lbrace;<span class="syntax-keyword">#{name}</span>, <span class="syntax-string">#{version}</span>&rbrace;#{comma}#{note_html})
      end)

    note_line =
      if config.note != "" and Enum.all?(config.deps, fn {_, _, n} -> n == "" end) do
        ~s(\n    <span class="syntax-comment">#{config.note}</span>)
      else
        ""
      end

    html = """
    <span class="syntax-comment">#{config.comment}</span>
    <span class="syntax-keyword">def</span> <span class="syntax-function">deps</span> <span class="syntax-keyword">do</span>
      &lbrack;
    #{deps_lines}#{note_line}
      &rbrack;
    <span class="syntax-keyword">end</span>
    """

    Phoenix.HTML.raw(html)
  end

  defp why_elixir_otp_section(assigns) do
    features = [
      %{
        icon: "◉",
        title: "Process isolation",
        desc: "Each agent runs in its own BEAM process with isolated state and memory. One agent failing never corrupts another.",
        tone: :green
      },
      %{
        icon: "⟳",
        title: "OTP supervision",
        desc: "Supervisors restart crashed agents in milliseconds with clean state. Failure containment and recovery are built into the runtime.",
        tone: :yellow
      },
      %{
        icon: "⚡",
        title: "Fault-tolerant concurrency",
        desc: "The BEAM's preemptive scheduler handles thousands of long-lived agent processes with true parallelism on multi-core hardware.",
        tone: :cyan
      }
    ]

    assigns = assign(assigns, :features, features)

    ~H"""
    <section id="why-elixir-otp" class="home-why-otp-section mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="home-why-otp-header">
        <h2 class="text-2xl font-bold tracking-tight mb-3">Why Elixir/OTP</h2>
        <p class="home-muted-copy text-sm max-w-md mx-auto leading-relaxed">
          The runtime model that makes reliability claims credible.
        </p>
      </div>

      <div class="home-why-otp-cards">
        <article :for={feature <- @features} class="home-why-otp-card">
          <div class={"home-why-otp-icon home-why-otp-icon-#{feature.tone}"}>{feature.icon}</div>
          <div>
            <h3 class="home-why-otp-title">{feature.title}</h3>
            <p class="home-why-otp-desc">{feature.desc}</p>
          </div>
        </article>
      </div>

      <div class="home-why-otp-links">
        <.link
          navigate="/features/beam-native-agent-model"
          class="home-why-otp-link-primary"
        >
          The BEAM-native agent model →
        </.link>
        <.link
          navigate="/features/beam-for-ai-builders"
          class="home-why-otp-link-secondary"
        >
          Why Elixir/OTP for agent workloads →
        </.link>
      </div>
    </section>
    """
  end

  @quick_start_define_html ~S"""
  <span class="syntax-keyword">defmodule</span> <span class="syntax-type">MyApp.WeatherAgent</span> <span class="syntax-keyword">do</span>
    <span class="syntax-keyword">use</span> <span class="syntax-type">Jido.AI.Agent</span>,
      name: <span class="syntax-string">"weather_agent"</span>,
      description: <span class="syntax-string">"Weather Q&amp;A agent"</span>,
      tools: &lbrack;<span class="syntax-type">Jido.Tools.Weather.Forecast</span>,
             <span class="syntax-type">Jido.Tools.Weather.CurrentConditions</span>&rbrack;,
      system_prompt: <span class="syntax-string">"You are a weather planning assistant."</span>
  <span class="syntax-keyword">end</span>
  """

  @quick_start_terminal_lines [
    %{type: :comment, text: "# Start a supervised agent"},
    %{type: :input, text: "{:ok, pid} = Jido.AgentServer.start(agent: MyApp.WeatherAgent)"},
    %{type: :output, text: "{:ok, #PID<0.452.0>}"},
    %{type: :spacer, text: nil},
    %{type: :comment, text: "# Async ask"},
    %{type: :input, text: "MyApp.WeatherAgent.ask(pid, \"Weather in Tokyo?\")"},
    %{type: :output, text: "{:ok, \"Currently 18 C, partly cloudy. Rain expected tonight.\"}"},
    %{type: :spacer, text: nil},
    %{type: :comment, text: "# Sync shorthand"},
    %{type: :input, text: "MyApp.WeatherAgent.ask_sync(pid, \"Umbrella?\")"},
    %{type: :output, text: "{:ok, \"Yes - 80% chance of rain after 6pm.\"}"}
  ]

  defp quick_start_code(assigns) do
    assigns =
      assigns
      |> assign(:define_code_html, Phoenix.HTML.raw(String.trim(@quick_start_define_html)))
      |> assign(:terminal_lines, @quick_start_terminal_lines)

    ~H"""
    <section id="quick-start" class="home-quickstart-section mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="home-quickstart-header">
        <div>
          <h2 class="text-2xl font-bold tracking-tight mb-2">Quick start</h2>
          <p class="home-quickstart-summary">
            Define an agent, start it supervised, ask it questions.
          </p>
        </div>
        <.link navigate="/docs/getting-started" class="home-quickstart-guide-link">
          full getting started guide →
        </.link>
      </div>

      <div class="code-block overflow-hidden home-quickstart-shell">
        <div class="code-header">
          <span class="home-muted-copy text-xs">lib/my_app/weather_agent.ex</span>
          <.link navigate="/docs/getting-started" class="home-quickstart-header-link">
            View full example →
          </.link>
        </div>
        <div class="home-quickstart-pane">
          <pre class="home-quickstart-code"><code><%= @define_code_html %></code></pre>
        </div>

        <div class="code-header mt-1">
          <span class="home-muted-copy text-xs">iex -S mix</span>
          <div class="flex items-center gap-3">
            <.link navigate="/training/agent-fundamentals" class="home-quickstart-header-link">
              TRAINING
            </.link>
            <.link navigate="/docs" class="home-subtle-link text-[10px]">
              DOCS
            </.link>
          </div>
        </div>
        <div class="home-quickstart-terminal">
          <div class="home-quickstart-terminal-content">
            <%= for line <- @terminal_lines do %>
              <%= case line.type do %>
                <% :spacer -> %>
                  <div class="home-quickstart-spacer" aria-hidden="true"></div>
                <% :comment -> %>
                  <div class="syntax-comment">{line.text}</div>
                <% :output -> %>
                  <div class="home-quickstart-output">{line.text}</div>
                <% :input -> %>
                  <div>
                    <span class="home-quickstart-prompt">iex&gt; </span>
                    <span class="home-quickstart-input">{line.text}</span>
                  </div>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>
    </section>
    """
  end
end
