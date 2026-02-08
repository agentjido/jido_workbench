defmodule AgentJidoWeb.JidoBenchmarksLive do
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/benchmarks">
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <%!-- Hero --%>
        <section class="text-center mb-16">
          <h1 class="text-4xl font-bold mb-6">
            Benchmarks & <span class="gradient-text">Proof</span>
          </h1>
          <p class="text-lg text-muted-foreground max-w-3xl mx-auto">
            Claims about concurrency and resilience are cheap; these are the numbers Jido actually hits on real hardware.
          </p>
        </section>

        <%!-- Summary Metrics --%>
        <section class="mb-16">
          <div class="bg-card border border-primary/30 rounded-lg p-8">
            <div class="grid sm:grid-cols-3 gap-8 text-center">
              <div>
                <div class="text-3xl mb-3">🖥️</div>
                <div class="text-3xl font-bold font-mono text-primary">10,000</div>
                <div class="text-sm text-muted-foreground">agents on 2-core, 4GB VM</div>
              </div>
              <div>
                <div class="text-3xl mb-3">⚡</div>
                <div class="text-3xl font-bold font-mono text-accent-cyan">&lt; 1ms</div>
                <div class="text-sm text-muted-foreground">median message latency</div>
              </div>
              <div>
                <div class="text-3xl mb-3">💾</div>
                <div class="text-3xl font-bold font-mono text-primary">~20KB</div>
                <div class="text-sm text-muted-foreground">memory per idle agent</div>
              </div>
            </div>
          </div>
        </section>

        <%!-- Single-Node Benchmarks --%>
        <section class="mb-16">
          <h2 class="text-2xl font-bold mb-6">Single-Node Benchmarks</h2>
          <div class="bg-card border border-border rounded-lg overflow-hidden">
            <table class="w-full text-sm">
              <thead>
                <tr class="border-b border-border bg-elevated">
                  <th class="text-left p-4 font-medium text-muted-foreground">Agents</th>
                  <th class="text-left p-4 font-medium text-muted-foreground">Memory</th>
                  <th class="text-left p-4 font-medium text-muted-foreground">CPU</th>
                  <th class="text-left p-4 font-medium text-muted-foreground hidden sm:table-cell">Environment</th>
                </tr>
              </thead>
              <tbody>
                <tr class="border-b border-border">
                  <td class="p-4 font-mono text-primary">1,000</td>
                  <td class="p-4 font-mono text-accent-cyan">40MB</td>
                  <td class="p-4 font-mono">5%</td>
                  <td class="p-4 text-muted-foreground hidden sm:table-cell">2-core, 4GB</td>
                </tr>
                <tr class="border-b border-border bg-elevated/50">
                  <td class="p-4 font-mono text-primary">5,000</td>
                  <td class="p-4 font-mono text-accent-cyan">180MB</td>
                  <td class="p-4 font-mono">12%</td>
                  <td class="p-4 text-muted-foreground hidden sm:table-cell">2-core, 4GB</td>
                </tr>
                <tr class="border-b border-border last:border-b-0">
                  <td class="p-4 font-mono text-primary">10,000</td>
                  <td class="p-4 font-mono text-accent-cyan">350MB</td>
                  <td class="p-4 font-mono">22%</td>
                  <td class="p-4 text-muted-foreground hidden sm:table-cell">4-core, 8GB</td>
                </tr>
              </tbody>
            </table>
          </div>
          <p class="text-sm text-muted-foreground mt-4">
            <strong>Test scenario:</strong> Agent behavior is a simple state machine with periodic work.
            Measurement via <code class="text-accent-cyan">:observer</code> and telemetry aggregation over 10-minute sustained load.
          </p>
        </section>

        <%!-- Multi-Node Scenarios --%>
        <section class="mb-16">
          <h2 class="text-2xl font-bold mb-6">Multi-Node Scenarios</h2>
          <div class="grid sm:grid-cols-3 gap-4">
            <div class="feature-card text-center">
              <div class="text-2xl font-bold font-mono text-primary mb-2">&lt; 2s</div>
              <div class="text-sm text-muted-foreground">Failover time when node dies</div>
            </div>
            <div class="feature-card text-center">
              <div class="text-2xl font-bold font-mono text-accent-yellow mb-2">33%</div>
              <div class="text-sm text-muted-foreground">Throughput impact during outage (1 of 3 nodes)</div>
            </div>
            <div class="feature-card text-center">
              <div class="text-2xl font-bold font-mono text-accent-cyan mb-2">&lt; 5s</div>
              <div class="text-sm text-muted-foreground">Agent redistribution time</div>
            </div>
          </div>
        </section>

        <%!-- Failure Experiments --%>
        <section class="mb-16">
          <h2 class="text-2xl font-bold mb-6">Failure Behavior Experiments</h2>
          <div class="grid md:grid-cols-2 gap-6">
            <div class="feature-card">
              <h3 class="font-semibold mb-2">Random agent crashes</h3>
              <p class="text-sm text-muted-foreground mb-3">Crash 10% of agents randomly per second</p>
              <div class="space-y-2 text-sm">
                <p>
                  <span class="text-primary">Result:</span>
                  <span class="text-muted-foreground ml-1">Supervisor restarts isolated to crashed agents</span>
                </p>
                <p>
                  <span class="text-accent-cyan">Impact:</span>
                  <span class="text-muted-foreground ml-1">No cascade failures, 99.9% uptime for healthy agents</span>
                </p>
              </div>
            </div>
            <div class="feature-card">
              <h3 class="font-semibold mb-2">Thundering herd</h3>
              <p class="text-sm text-muted-foreground mb-3">5,000 agents all request external API simultaneously</p>
              <div class="space-y-2 text-sm">
                <p>
                  <span class="text-primary">Result:</span>
                  <span class="text-muted-foreground ml-1">Back-pressure via mailbox monitoring</span>
                </p>
                <p>
                  <span class="text-accent-cyan">Impact:</span>
                  <span class="text-muted-foreground ml-1">Graceful degradation, no OOM</span>
                </p>
              </div>
            </div>
          </div>
        </section>

        <%!-- Reproduce Benchmarks --%>
        <section class="mb-16">
          <h2 class="text-2xl font-bold mb-6">Reproduce the Benchmarks</h2>
          <div class="code-block overflow-hidden">
            <div class="code-header">
              <span class="text-muted-foreground text-xs">bash</span>
              <button
                phx-hook="CopyCode"
                id="copy-benchmark-code"
                class="bg-surface border border-border text-secondary-foreground px-3 py-1 rounded text-[10px] hover:text-foreground transition-colors"
              >
                COPY
              </button>
            </div>
            <div class="p-5">
              <pre class="text-[13px] leading-relaxed"><span class="syntax-function">git</span> clone https://github.com/agentjido/benchmarks
              <span class="syntax-function">cd</span> benchmarks
              <span class="syntax-function">mix</span> deps.get
              <span class="syntax-function">mix</span> run bench/single_node.exs</pre>
            </div>
          </div>
          <p class="text-sm text-muted-foreground mt-4 italic">
            We expect developers to rerun and verify these numbers on their own hardware.
          </p>
        </section>

        <%!-- Video CTAs --%>
        <section class="text-center mb-16">
          <h2 class="text-2xl font-bold mb-6">See it in Action</h2>
          <div class="flex flex-wrap justify-center gap-4">
            <a
              href="#"
              class="border border-border text-foreground hover:border-border-strong px-6 py-3 rounded text-sm transition-colors flex items-center gap-2"
            >
              ▶ 10,000 agents with Observer
            </a>
            <a
              href="#"
              class="border border-border text-foreground hover:border-border-strong px-6 py-3 rounded text-sm transition-colors flex items-center gap-2"
            >
              ▶ Node failover in real-time
            </a>
            <a
              href="https://github.com/agentjido/benchmarks"
              target="_blank"
              rel="noopener noreferrer"
              class="border border-border text-foreground hover:border-border-strong px-6 py-3 rounded text-sm transition-colors flex items-center gap-2"
            >
              📁 Benchmark repo
            </a>
          </div>
        </section>
      </div>
    </.marketing_layout>
    """
  end
end
