defmodule AgentJidoWeb.JidoHomeLive do
  use AgentJidoWeb, :live_view

  alias AgentJido.LandingContent

  import AgentJidoWeb.Jido.MarketingLayouts
  import AgentJidoWeb.Jido.MarketingCards

  @home_ecosystem_rows [
    %{layer: :app, ids: ~w(jido_studio jido_messaging)},
    %{layer: :ai, ids: ~w(jido_ai jido_behaviortree)},
    %{layer: :core, ids: ~w(jido jido_action jido_signal)},
    %{layer: :foundation, ids: ~w(req_llm llm_db)}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "A Runtime for Reliable Multi-Agent Systems",
       meta_description:
         "Jido is a runtime for reliable, multi-agent systems, built on Elixir/OTP for fault isolation, concurrency, and production uptime.",
       install_tab: "full",
       ecosystem_rows: build_home_ecosystem_rows()
     )}
  end

  @impl true
  def handle_event("select_install_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, install_tab: tab)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/">
      <div class="container max-w-[1000px] mx-auto px-6">
        <.hero_section />
        <.pillars_section />
        <.ecosystem_section ecosystem_rows={@ecosystem_rows} />
        <.install_section install_tab={@install_tab} />
        <.why_elixir_otp_section />
        <.quick_start_code />
        <.cta_section />
      </div>
    </.marketing_layout>
    """
  end

  defp hero_section(assigns) do
    ~H"""
    <section class="text-center mb-16 animate-fade-in">
      <div class="inline-block bg-primary/10 border border-primary/30 px-4 py-2 rounded mb-6">
        <span class="text-primary text-[11px] font-semibold tracking-widest">
          RELIABLE MULTI-AGENT RUNTIME
        </span>
      </div>

      <h1 class="text-4xl sm:text-[42px] font-bold leading-tight mb-5 tracking-tight">
        A runtime for reliable, <br />
        <span class="text-primary">multi-agent systems.</span>
      </h1>

      <p class="text-secondary-foreground text-[15px] leading-relaxed mb-8 max-w-xl mx-auto">
        Design, coordinate, and operate agent workflows that stay stable in production
        — built on Elixir/OTP for fault isolation, concurrency, and uptime.
      </p>

      <div class="flex gap-3 justify-center mb-12">
        <.link
          navigate="/docs/getting-started"
          class="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-5 rounded transition-colors"
        >
          GET BUILDING →
        </.link>
        <.link
          navigate="/features"
          class="border-2 border-accent-yellow text-accent-yellow hover:bg-accent-yellow/10 text-[13px] font-semibold px-6 py-5 rounded transition-colors"
        >
          EXPLORE FEATURES
        </.link>
      </div>
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
        color_class: "text-accent-green",
        link: "/features/reliability-by-architecture"
      },
      %{
        icon: "⧉",
        title: "Coordination you can reason about",
        desc:
          "Multi-agent behavior is explicit and testable. Actions define capabilities, Signals handle communication, and Directives model orchestration — not role-play in a single prompt.",
        color_class: "text-accent-yellow",
        link: "/features/multi-agent-coordination"
      },
      %{
        icon: "⬡",
        title: "Production operations built in",
        desc:
          "Telemetry, debugging workflows, and operational controls are first-class. Observe agent behavior, trace workflows across processes, and run with confidence under real load.",
        color_class: "text-accent-cyan",
        link: "/features/operations-observability"
      },
      %{
        icon: "▣",
        title: "Composable, incremental adoption",
        desc:
          "Adopt only what you need now, expand safely later. Start with the core runtime, add AI capabilities, layer on tooling — each package composes without lock-in.",
        color_class: "text-accent-red",
        link: "/features/incremental-adoption"
      }
    ]

    assigns = assign(assigns, :pillars, pillars)

    ~H"""
    <section id="pillars" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="text-center mb-10">
        <h2 class="text-2xl font-bold tracking-tight mb-3">Why Jido</h2>
        <p class="text-muted-foreground text-sm">
          Prototyping is common. Reliable operation is rare. Jido is built for operation.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <%= for pillar <- @pillars do %>
          <.link navigate={pillar.link} class="feature-card text-left group hover:-translate-y-0.5 transition-transform duration-200">
            <div class={"text-2xl mb-3 #{pillar.color_class}"}>{pillar.icon}</div>
            <div class="font-bold text-sm mb-2 group-hover:text-primary transition-colors">
              {pillar.title}
            </div>
            <p class="text-muted-foreground text-[13px] leading-relaxed">{pillar.desc}</p>
          </.link>
        <% end %>
      </div>
    </section>
    """
  end

  defp ecosystem_section(assigns) do
    ~H"""
    <section id="ecosystem" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="flex justify-between items-center mb-6">
        <div>
          <h2 class="text-xl font-bold tracking-tight inline">Ecosystem</h2>
          <span class="text-muted-foreground text-sm ml-4">4 layers · composable by design</span>
        </div>
        <.link navigate="/ecosystem" class="text-primary text-sm hover:underline">
          see the ecosystem →
        </.link>
      </div>

      <%= for row <- @ecosystem_rows do %>
        <div class={row_grid_class(row.packages)}>
          <%= for pkg <- row.packages do %>
            <.package_card
              name={pkg.name}
              desc={pkg.desc}
              layer={row.layer}
              path={pkg.path}
              links={%{}}
            />
          <% end %>
        </div>
      <% end %>
    </section>
    """
  end

  defp build_home_ecosystem_rows do
    package_by_id =
      LandingContent.packages()
      |> Map.new(&{&1.id, &1})

    @home_ecosystem_rows
    |> Enum.map(fn row ->
      packages =
        row.ids
        |> Enum.map(&Map.get(package_by_id, &1))
        |> Enum.reject(&is_nil/1)

      %{layer: row.layer, packages: packages}
    end)
    |> Enum.reject(&(&1.packages == []))
  end

  defp row_grid_class(packages) do
    case length(packages) do
      1 -> "grid grid-cols-1 gap-3 mb-3"
      2 -> "grid grid-cols-1 md:grid-cols-2 gap-3 mb-3"
      _ -> "grid grid-cols-1 md:grid-cols-3 gap-3 mb-3"
    end
  end

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
        <p class="text-muted-foreground text-sm">
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
          <span class="text-muted-foreground text-xs">mix.exs</span>
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
      |> Enum.map(fn {name, version, _note} -> "    {#{name}, #{version}}" end)
      |> Enum.join(",\n")

    "def deps do\n  [\n#{deps_str}\n  ]\nend"
  end

  defp render_deps_code(config) do
    deps_lines =
      config.deps
      |> Enum.with_index()
      |> Enum.map(fn {{name, version, note}, idx} ->
        comma = if idx < length(config.deps) - 1, do: ",", else: ""
        note_html = if note != "", do: ~s( <span class="syntax-comment">#{note}</span>), else: ""

        ~s(    &lbrace;<span class="syntax-keyword">#{name}</span>, <span class="syntax-string">#{version}</span>&rbrace;#{comma}#{note_html})
      end)
      |> Enum.join("\n")

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
        color_class: "text-accent-green"
      },
      %{
        icon: "⟳",
        title: "OTP supervision",
        desc: "Supervisors restart crashed agents in milliseconds with clean state. Failure containment and recovery are built into the runtime.",
        color_class: "text-accent-yellow"
      },
      %{
        icon: "⚡",
        title: "Fault-tolerant concurrency",
        desc: "The BEAM's preemptive scheduler handles thousands of long-lived agent processes with true parallelism on multi-core hardware.",
        color_class: "text-accent-cyan"
      }
    ]

    assigns = assign(assigns, :features, features)

    ~H"""
    <section id="why-elixir-otp" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="text-center mb-10">
        <h2 class="text-2xl font-bold tracking-tight mb-3">Why Elixir/OTP</h2>
        <p class="text-muted-foreground text-sm">
          The runtime model that makes reliability claims credible.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <%= for feature <- @features do %>
          <div class="feature-card text-center">
            <div class={"text-2xl mb-4 #{feature.color_class}"}>{feature.icon}</div>
            <div class="font-bold text-sm mb-2">{feature.title}</div>
            <p class="text-muted-foreground text-[13px] leading-relaxed">{feature.desc}</p>
          </div>
        <% end %>
      </div>

      <div class="text-center mt-6">
        <.link
          navigate="/features/beam-for-ai-builders"
          class="text-primary text-sm hover:underline"
        >
          Why Elixir/OTP for agent workloads →
        </.link>
      </div>
    </section>
    """
  end

  # credo:disable-for-next-line Credo.Check.Readability.MaxLineLength
  @quick_start_html "<span class=\"syntax-keyword\">defmodule</span> <span class=\"syntax-type\">MyApp.WeatherAgent</span> <span class=\"syntax-keyword\">do</span>\n  <span class=\"syntax-keyword\">use</span> <span class=\"syntax-type\">Jido.AI.Agent</span>,\n    name: <span class=\"syntax-string\">\"weather_agent\"</span>,\n    description: <span class=\"syntax-string\">\"Weather Q&amp;A agent\"</span>,\n    tools: &lbrack;<span class=\"syntax-type\">Jido.Tools.Weather.Forecast</span>,\n           <span class=\"syntax-type\">Jido.Tools.Weather.CurrentConditions</span>&rbrack;,\n    system_prompt: <span class=\"syntax-string\">\"You are a weather planning assistant.\"</span>\n<span class=\"syntax-keyword\">end</span>\n\n<span class=\"syntax-comment\"># Start a supervised agent — isolated process, automatic restarts</span>\n&lbrace;<span class=\"syntax-atom\">:ok</span>, pid&rbrace; = <span class=\"syntax-type\">Jido.AgentServer</span>.start(agent: <span class=\"syntax-type\">MyApp.WeatherAgent</span>)\n\n<span class=\"syntax-comment\"># Async: send query, get a request handle back</span>\n&lbrace;<span class=\"syntax-atom\">:ok</span>, request&rbrace; = <span class=\"syntax-type\">MyApp.WeatherAgent</span>.ask(pid, <span class=\"syntax-string\">\"What's the weather in Tokyo?\"</span>)\n&lbrace;<span class=\"syntax-atom\">:ok</span>, answer&rbrace; = <span class=\"syntax-type\">MyApp.WeatherAgent</span>.await(request)\n\n<span class=\"syntax-comment\"># Or sync for simple cases</span>\n&lbrace;<span class=\"syntax-atom\">:ok</span>, answer&rbrace; = <span class=\"syntax-type\">MyApp.WeatherAgent</span>.ask_sync(pid, <span class=\"syntax-string\">\"Should I bring an umbrella?\"</span>)"

  defp quick_start_code(assigns) do
    assigns = assign(assigns, :code_html, Phoenix.HTML.raw(@quick_start_html))

    ~H"""
    <section id="quick-start" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="flex justify-between items-center mb-5">
        <h2 class="text-xl font-bold tracking-tight">Quick start</h2>
        <.link navigate="/docs/getting-started" class="text-primary text-sm hover:underline">
          full getting started guide →
        </.link>
      </div>

      <div class="code-block overflow-hidden">
        <div class="code-header">
          <span class="text-muted-foreground text-xs">lib/my_app/weather_agent.ex</span>
          <div class="flex gap-3">
            <.link
              navigate="/training/agent-fundamentals"
              class="text-primary text-[10px] hover:underline"
            >
              TRAINING
            </.link>
            <.link
              navigate="/docs"
              class="text-muted-foreground text-[10px] hover:text-foreground"
            >
              DOCS
            </.link>
          </div>
        </div>
        <div class="p-6 overflow-x-auto">
          <pre class="text-xs leading-relaxed"><code><%= @code_html %></code></pre>
        </div>
      </div>
    </section>
    """
  end

  defp cta_section(assigns) do
    ~H"""
    <section id="cta" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="cta-glow rounded-lg p-12 text-center">
        <h2 class="text-2xl font-bold mb-3">Build your first agent</h2>
        <p class="text-secondary-foreground text-sm mb-6 max-w-md mx-auto">
          Go from zero to a supervised, fault-tolerant agent workflow.
          Start with the getting started guide or explore the training modules.
        </p>
        <div class="flex gap-3 justify-center">
          <.link
            navigate="/docs/getting-started"
            class="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-5 rounded transition-colors"
          >
            GET BUILDING →
          </.link>
          <.link
            navigate="/training"
            class="border border-accent-cyan text-accent-cyan hover:bg-accent-cyan/10 text-[13px] font-medium px-7 py-5 rounded transition-colors"
          >
            START TRAINING
          </.link>
        </div>
      </div>
    </section>
    """
  end
end
