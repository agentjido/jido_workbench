defmodule AgentJidoWeb.JidoHomeLive do
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts
  import AgentJidoWeb.Jido.MarketingCards

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, install_tab: "full", og_image: "https://agentjido.xyz/og/home.png")}
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
        <.metrics_strip />
        <.package_ecosystem />
        <.dependency_flow />
        <.install_section install_tab={@install_tab} />
        <.why_beam_section />
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
          BEAM-NATIVE AGENT ECOSYSTEM
        </span>
      </div>

      <h1 class="text-4xl sm:text-[42px] font-bold leading-tight mb-5 tracking-tight">
        From <span class="text-accent-cyan">LLM calls</span> to <br />
        <span class="text-primary">autonomous agents</span>
      </h1>

      <p class="text-secondary-foreground text-[15px] leading-relaxed mb-8 max-w-lg mx-auto">
        7 composable packages. One unified stack. <br /> Run 10,000+ agents on a single BEAM node.
      </p>

      <div class="flex gap-3 justify-center mb-12">
        <.link
          navigate="/ecosystem"
          class="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-5 rounded transition-colors"
        >
          EXPLORE ECOSYSTEM →
        </.link>
        <.link
          navigate="/benchmarks"
          class="border-2 border-accent-yellow text-accent-yellow hover:bg-accent-yellow/10 text-[13px] font-semibold px-6 py-5 rounded transition-colors"
        >
          VIEW BENCHMARKS
        </.link>
      </div>
    </section>
    """
  end

  defp metrics_strip(assigns) do
    ~H"""
    <section class="mb-16 animate-fade-in">
      <div class="grid grid-cols-4 gap-px bg-border rounded-md overflow-hidden max-w-[700px] mx-auto">
        <.metric_card value="10,000+" label="agents/node" color_class="text-accent-green" />
        <.metric_card value="~200MB" label="RAM @ 5k agents" color_class="text-accent-yellow" />
        <.metric_card value="<1ms" label="message latency" color_class="text-accent-cyan" />
        <.metric_card value="7" label="packages" color_class="text-accent-red" />
      </div>
    </section>
    """
  end

  defp package_ecosystem(assigns) do
    ~H"""
    <section id="package-ecosystem" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="flex justify-between items-center mb-6">
        <div>
          <span class="font-bold text-sm tracking-wider">PACKAGE ECOSYSTEM</span>
          <span class="text-muted-foreground text-xs ml-4">4 layers • composable by design</span>
        </div>
        <.link navigate="/ecosystem" class="text-primary text-xs hover:underline">
          view all →
        </.link>
      </div>
      
    <!-- Row 1: App + AI -->
      <div class="grid grid-cols-1 md:grid-cols-[1fr_2fr] gap-3 mb-3">
        <.package_card
          name="jido_coder"
          desc="AI coding agent with file operations, git integration, and test execution"
          layer={:app}
          links={%{}}
        />
        <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
          <.package_card
            name="jido_ai"
            desc="LLM-powered agents with token/cost tracking, tool calling, and streaming. Combines jido + req_llm + llmdb."
            layer={:ai}
            links={%{}}
          />
          <.package_card
            name="jido_behaviortree"
            desc="Behavior tree execution for complex agent decision-making. Composable nodes, conditions, and actions."
            layer={:ai}
            links={%{}}
          />
        </div>
      </div>
      
    <!-- Row 2: Core -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
        <.package_card
          name="jido"
          desc="BEAM-native bot framework. OTP supervision, isolated processes, 10k+ agents per node."
          layer={:core}
          links={%{}}
        />
        <.package_card
          name="jido_action"
          desc="Schema-based action validation. Required fields, defaults, type constraints."
          layer={:core}
          links={%{}}
        />
        <.package_card
          name="jido_signal"
          desc="Pub/sub signaling between agents. Decoupled coordination via message-passing."
          layer={:core}
          links={%{}}
        />
      </div>
      
    <!-- Row 3: Foundation -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
        <.package_card
          name="req_llm"
          desc="HTTP client for LLM APIs. Built on Req with retries, rate limiting, and streaming support."
          layer={:foundation}
          links={%{}}
        />
        <.package_card
          name="llmdb"
          desc="Model registry and metadata. Token limits, pricing, capabilities for all major providers."
          layer={:foundation}
          links={%{}}
        />
      </div>
    </section>
    """
  end

  defp dependency_flow(assigns) do
    ~H"""
    <section id="dependency-flow" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="code-block overflow-hidden">
        <div class="code-header">
          <span class="text-muted-foreground text-xs">
            <span class="text-accent-yellow">#</span> dependency flow
          </span>
          <span class="text-muted-foreground text-[10px]">packages compose bottom-up</span>
        </div>
        <div class="p-6 overflow-x-auto">
          <pre class="text-[11px] leading-relaxed whitespace-pre"><div>                                    ┌─────────────┐</div><div>                                    │ <span class="text-accent-red">jido_coder</span>  │  ← AI coding workflows</div><div>                                    └──────┬──────┘</div><div>                                           │</div><div>                                    ┌──────┴──────┐</div><div>                                    │   <span class="text-accent-yellow">jido_ai</span>   │  ← LLM-powered agents</div><div>                                    └──────┬──────┘</div><div>                           ┌───────────────┼───────────────┐</div><div>                           │               │               │</div><div>                    ┌──────┴──────┐ ┌──────┴──────┐ ┌──────┴──────┐</div><div>                    │    <span class="text-accent-green">jido</span>     │ │ <span class="text-accent-green">jido_action</span> │ │ <span class="text-accent-green">jido_signal</span> │</div><div>                    └──────┬──────┘ └─────────────┘ └─────────────┘</div><div>                           │</div><div>              ┌────────────┴────────────┐</div><div>              │                         │</div><div>       ┌──────┴──────┐          ┌───────┴───────┐</div><div>       │   <span class="text-accent-cyan">req_llm</span>   │          │     <span class="text-accent-cyan">llmdb</span>     │</div><div>       └─────────────┘          └───────────────┘</div></pre>
        </div>
      </div>
    </section>
    """
  end

  defp install_section(assigns) do
    install_configs = %{
      "full" => %{
        comment: "# Full stack: AI coding agents",
        deps: [{":jido_coder", ~s("~> 0.1.0"), ""}],
        note: "# includes jido_ai, jido, req_llm, llmdb"
      },
      "bots" => %{
        comment: "# Bots only: no LLM dependencies",
        deps: [{":jido", ~s("~> 0.1.0"), ""}],
        note: "# pure bot framework, OTP supervision"
      },
      "custom" => %{
        comment: "# Custom: mix and match",
        deps: [
          {":jido", ~s("~> 0.1.0"), "# bot framework"},
          {":jido_action", ~s("~> 0.1.0"), "# validation"},
          {":req_llm", ~s("~> 0.1.0"), "# LLM client"}
        ],
        note: ""
      }
    }

    assigns = assign(assigns, :config, Map.get(install_configs, assigns.install_tab))

    ~H"""
    <section id="install-section" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="mb-5">
        <span class="font-bold text-sm tracking-wider">CHOOSE YOUR STACK</span>
      </div>

      <div class="flex gap-1 mb-4">
        <button
          phx-click="select_install_tab"
          phx-value-tab="full"
          class={"px-5 py-2.5 rounded text-[11px] font-semibold transition-colors border #{if @install_tab == "full", do: "border-primary bg-primary/10 text-primary", else: "border-border text-secondary-foreground hover:text-foreground"}"}
        >
          FULL AI STACK
        </button>
        <button
          phx-click="select_install_tab"
          phx-value-tab="bots"
          class={"px-5 py-2.5 rounded text-[11px] font-semibold transition-colors border #{if @install_tab == "bots", do: "border-primary bg-primary/10 text-primary", else: "border-border text-secondary-foreground hover:text-foreground"}"}
        >
          BOTS ONLY
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

  defp why_beam_section(assigns) do
    features = [
      %{
        icon: "◉",
        title: "Isolated Processes",
        desc: "Each agent runs in its own BEAM process with isolated state. No shared memory, no locks.",
        color_class: "text-accent-green"
      },
      %{
        icon: "⟳",
        title: "OTP Supervision",
        desc: "When agents crash, supervisors restart them in milliseconds. No external orchestrator needed.",
        color_class: "text-accent-yellow"
      },
      %{
        icon: "⚡",
        title: "Native Concurrency",
        desc: "Preemptive scheduler handles 10k+ agents per node. True parallelism on multi-core.",
        color_class: "text-accent-cyan"
      }
    ]

    assigns = assign(assigns, :features, features)

    ~H"""
    <section id="why-beam" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="text-center mb-8">
        <span class="font-bold text-sm tracking-wider">WHY BEAM-NATIVE?</span>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <%= for feature <- @features do %>
          <div class="feature-card text-center">
            <div class={"text-2xl mb-4 #{feature.color_class}"}>{feature.icon}</div>
            <div class="font-bold text-[13px] mb-2">{feature.title}</div>
            <p class="text-muted-foreground text-xs leading-relaxed">{feature.desc}</p>
          </div>
        <% end %>
      </div>
    </section>
    """
  end

  defp quick_start_code(assigns) do
    code = """
    defmodule ResearchAgent do
      use JidoAI.Agent

      def init(args) do
        {:ok, %{
          model: {:openai, "gpt-4"},
          budget: 10_000,
          topic: args[:topic]
        }}
      end

      def handle_action(:research, state) do
        case JidoAI.chat(state, prompt) do
          {:ok, response, new_state} ->
            {:ok, %{new_state | findings: response}}
          {:error, :budget_exceeded} ->
            {:error, :out_of_tokens}
        end
      end
    end

    # Start 1,000 supervised research agents
    for topic <- topics do
      JidoAI.start_agent(ResearchAgent, topic: topic)
    end
    """

    assigns = assign(assigns, :code, code)

    ~H"""
    <section id="quick-start" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="flex justify-between items-center mb-5">
        <span class="font-bold text-sm tracking-wider">QUICK START</span>
        <span class="text-muted-foreground text-[11px]">run in less than 2 minutes</span>
      </div>

      <div class="code-block overflow-hidden">
        <div class="code-header">
          <span class="text-muted-foreground text-xs">lib/my_app/research_agent.ex</span>
          <div class="flex gap-3">
            <span class="text-primary text-[10px] cursor-pointer hover:underline">LIVEBOOK</span>
            <span class="text-muted-foreground text-[10px] cursor-pointer hover:text-foreground">GITHUB</span>
          </div>
        </div>
        <div class="p-6 overflow-x-auto">
          <pre class="text-xs leading-relaxed"><%= for line <- String.split(@code, "\n") do %><%= highlight_elixir_line(line) %><% end %></pre>
        </div>
      </div>
    </section>
    """
  end

  defp highlight_elixir_line(line) do
    cond do
      String.trim(line) |> String.starts_with?("#") ->
        Phoenix.HTML.raw(~s(<div class="syntax-comment">#{escape_html(line)}</div>))

      true ->
        {main_part, comment_part} =
          case String.split(line, " #", parts: 2) do
            [main] -> {main, ""}
            [main, comment] -> {main, " #" <> comment}
          end

        highlighted =
          main_part
          |> String.replace(~r/\b(defmodule|def|do|end|use|case|for)\b/, fn match ->
            ~s(<span class="syntax-keyword">#{match}</span>)
          end)
          |> String.replace(~r/"[^"]*"/, fn match ->
            ~s(<span class="syntax-string">#{escape_html(match)}</span>)
          end)
          |> String.replace(~r/:[a-z_]+/, fn match ->
            ~s(<span class="syntax-atom">#{match}</span>)
          end)
          |> String.replace(~r/\b[A-Z][A-Za-z.]+/, fn match ->
            ~s(<span class="syntax-type">#{match}</span>)
          end)
          |> String.replace(~r/\b\d+[_\d]*\b/, fn match ->
            ~s(<span class="syntax-string">#{match}</span>)
          end)

        comment_html =
          if comment_part != "",
            do: ~s(<span class="syntax-comment">#{escape_html(comment_part)}</span>),
            else: ""

        Phoenix.HTML.raw("<div>#{highlighted}#{comment_html}</div>")
    end
  end

  defp escape_html(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end

  defp cta_section(assigns) do
    ~H"""
    <section id="cta" class="mb-16 opacity-0" phx-hook="ScrollReveal">
      <div class="cta-glow rounded-lg p-12 text-center">
        <h2 class="text-2xl font-bold mb-3">Ready to build?</h2>
        <p class="text-secondary-foreground text-sm mb-6">
          Start with the getting started guide or explore production examples.
        </p>
        <div class="flex gap-3 justify-center">
          <.link
            navigate="/getting-started"
            class="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-5 rounded transition-colors"
          >
            $ mix jido.new my_app
          </.link>
          <.link
            navigate="/docs"
            class="border border-accent-cyan text-accent-cyan hover:bg-accent-cyan/10 text-[13px] font-medium px-7 py-5 rounded transition-colors"
          >
            READ THE DOCS
          </.link>
        </div>
      </div>
    </section>
    """
  end
end
