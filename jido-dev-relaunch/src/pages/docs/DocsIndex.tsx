import { DocsLayout } from "@/components/docs/DocsLayout";
import { NumberedCard } from "@/components/docs/cards/NumberedCard";
import { IconCard } from "@/components/docs/cards/IconCard";
import { QuickstartCard } from "@/components/docs/cards/QuickstartCard";
import { DocsCodeExample, Keyword, Str, Func, Type, Comment } from "@/components/docs/DocsCodeExample";
import { cn } from "@/lib/utils";

const tableOfContents = [
  { id: "get-started", title: "Get Started", level: 2 },
  { id: "package-ecosystem", title: "Package Ecosystem", level: 2 },
  { id: "quickstarts", title: "Quickstarts", level: 2 },
  { id: "explore-docs", title: "Explore the Docs", level: 2 },
  { id: "quick-example", title: "Quick Example", level: 2 },
  { id: "community", title: "Join the Community", level: 2 },
];

export default function DocsIndex() {
  return (
    <DocsLayout 
      tableOfContents={tableOfContents}
      githubPath="docs/introduction.md"
      livebookUrl="https://livebook.dev/run?url=https://github.com/agentjido/jido/blob/main/notebooks/intro.livemd"
      next={{ title: "Installation", href: "/docs/installation" }}
      hideBreadcrumb
    >
      {/* Breadcrumb */}
      <nav className="text-xs text-muted-foreground mb-6 flex items-center gap-2">
        <span>Docs</span>
        <span className="opacity-50">/</span>
        <span>Getting Started</span>
        <span className="opacity-50">/</span>
        <span className="text-primary font-medium">Introduction</span>
      </nav>

      {/* Hero Section */}
      <section className="mb-12">
        <h1 className="text-3xl font-bold mb-4 tracking-tight">
          Jido Documentation
        </h1>
        
        <p className="text-[15px] text-secondary-foreground leading-relaxed mb-6 max-w-[640px]">
          Jido is a BEAM-native ecosystem for building production-grade autonomous agents. 
          Run <span className="text-primary">10,000+ supervised agents</span> on a single node 
          with OTP supervision, isolated processes, and native concurrency.
        </p>

        {/* Quick Install CTA */}
        <div className={cn(
          "rounded-md p-5 mb-8",
          "bg-primary/[0.08] border border-primary/20"
        )}>
          <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div>
              <div className="text-xs font-semibold text-primary mb-1">
                ✨ Get started in one command
              </div>
              <div className="text-[13px] text-secondary-foreground">
                Add Jido to your existing Elixir app or create a new project
              </div>
            </div>
            <div className={cn(
              "px-4 py-2.5 rounded",
              "bg-code-bg border border-border",
              "font-mono text-[13px]"
            )}>
              <span className="text-muted-foreground">$ </span>
              <span className="text-accent-cyan">mix</span>
              <span className="text-foreground"> deps.get jido</span>
            </div>
          </div>
        </div>
      </section>

      {/* Get Started Section */}
      <section id="get-started" className="mb-12">
        <h2 className="text-lg font-bold mb-5 flex items-center gap-2">
          <span className="text-primary">#</span> Get Started
        </h2>
        
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <NumberedCard 
            number="1"
            title="Learn the Basics"
            description="Install Jido, create your first agent, and understand OTP supervision patterns."
            href="/docs/installation"
          />
          <NumberedCard 
            number="2"
            title="Choose Your Stack"
            description="Pick the packages you need: core bots, AI agents, or the full coding agent stack."
            href="/ecosystem"
          />
          <NumberedCard 
            number="3"
            title="Build Agent Workflows"
            description="Learn actions, signals, and inter-agent communication patterns."
            href="/docs/quickstart"
          />
          <NumberedCard 
            number="4"
            title="Deploy to Production"
            description="Scaling, observability, failure handling, and production checklist."
            href="/docs/production-checklist"
          />
        </div>
      </section>

      {/* Package Ecosystem */}
      <section id="package-ecosystem" className="mb-12">
        <h2 className="text-lg font-bold mb-5 flex items-center gap-2">
          <span className="text-accent-yellow">#</span> Package Ecosystem
        </h2>
        
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <IconCard 
            icon="◈"
            title="jido"
            description="BEAM-native bot framework with OTP supervision. Run thousands of agents per node."
            color="green"
            href="/docs/packages/jido"
          />
          <IconCard 
            icon="⚡"
            title="jido_ai"
            description="LLM-powered agents with token budgets, tool calling, and streaming support."
            color="yellow"
            href="/docs/packages/jido-ai"
          />
          <IconCard 
            icon="⟳"
            title="req_llm"
            description="HTTP client for LLM APIs. Retries, rate limiting, and multi-provider support."
            color="cyan"
            href="/docs/packages/req-llm"
          />
          <IconCard 
            icon="⚙"
            title="jido_coder"
            description="AI coding agent with file operations, git integration, and test execution."
            color="red"
            href="/docs/packages/jido-coder"
          />
        </div>
      </section>

      {/* Quickstarts */}
      <section id="quickstarts" className="mb-12">
        <div className="flex items-center justify-between mb-5">
          <h2 className="text-lg font-bold flex items-center gap-2">
            <span className="text-accent-cyan">#</span> Quickstarts
          </h2>
          <span className="text-[11px] text-muted-foreground">by use case</span>
        </div>
        
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
          <QuickstartCard 
            icon="🤖"
            title="Chat Bot"
            description="Simple conversational agent"
            color="green"
            href="/examples"
          />
          <QuickstartCard 
            icon="🔬"
            title="Research Agent"
            description="Multi-step LLM workflows"
            color="yellow"
            href="/examples"
          />
          <QuickstartCard 
            icon="💻"
            title="Code Assistant"
            description="File analysis & generation"
            color="red"
            href="/examples"
          />
          <QuickstartCard 
            icon="📊"
            title="Data Pipeline"
            description="Streaming log processor"
            color="cyan"
            href="/examples"
          />
          <QuickstartCard 
            icon="🔄"
            title="Workflow Engine"
            description="Long-lived orchestrator"
            color="yellow"
            href="/examples"
          />
          <QuickstartCard 
            icon="🌐"
            title="Multi-Node"
            description="Distributed agent cluster"
            color="green"
            href="/examples"
          />
        </div>
      </section>

      {/* Explore the Docs */}
      <section id="explore-docs" className="mb-12">
        <h2 className="text-lg font-bold mb-5 flex items-center gap-2">
          <span className="text-accent-red">#</span> Explore the Docs
        </h2>
        
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
          <IconCard 
            icon="⚙"
            title="Agents"
            description="Define agents, manage state, handle lifecycle and supervision."
            color="green"
            href="/docs/agents/defining"
          />
          <IconCard 
            icon="⟡"
            title="Actions"
            description="Schema-based validation, composable operations, constraints."
            color="yellow"
            href="/docs/actions/schemas"
          />
          <IconCard 
            icon="⫸"
            title="Signals"
            description="Pub/sub patterns for decoupled inter-agent communication."
            color="cyan"
            href="/docs/signals/pubsub"
          />
          <IconCard 
            icon="◇"
            title="LLM Integration"
            description="Configure providers, manage tokens, handle streaming."
            color="red"
            href="/docs/ai/llm-config"
          />
          <IconCard 
            icon="◎"
            title="Observability"
            description="Telemetry, metrics, tracing, and debugging agents."
            color="green"
            href="/docs/production/observability"
          />
          <IconCard 
            icon="⊕"
            title="Benchmarks"
            description="Performance numbers, scaling limits, and proof."
            color="yellow"
            href="/benchmarks"
          />
        </div>
      </section>

      {/* Quick Example */}
      <section id="quick-example" className="mb-12">
        <h2 className="text-lg font-bold mb-5 flex items-center gap-2">
          <span className="text-primary">#</span> Quick Example
        </h2>
        
        <DocsCodeExample filename="lib/my_app/weather_agent.ex">
          <pre className="m-0">
            <Keyword>defmodule</Keyword> <Type>WeatherAgent</Type> <Keyword>do</Keyword>{'\n'}
            {'  '}<Keyword>use</Keyword> Jido.Agent{'\n'}
            {'\n'}
            {'  '}<Keyword>def</Keyword> <Func>init</Func>(args) <Keyword>do</Keyword>{'\n'}
            {'    '}{'{'}:<Keyword>ok</Keyword>, %{'{'}location: args[:<Keyword>location</Keyword>], temp: <Keyword>nil</Keyword>{'}'}{'}'}
{'\n'}
            {'  '}<Keyword>end</Keyword>{'\n'}
            {'\n'}
            {'  '}<Keyword>def</Keyword> <Func>handle_action</Func>(:<Keyword>check</Keyword>, state) <Keyword>do</Keyword>{'\n'}
            {'    '}temp = WeatherAPI.get_temp(state.location){'\n'}
            {'    '}{'{'}:<Keyword>ok</Keyword>, %{'{'}state | temp: temp{'}'}{'}'}
{'\n'}
            {'  '}<Keyword>end</Keyword>{'\n'}
            <Keyword>end</Keyword>{'\n'}
            {'\n'}
            <Comment># Start 5,000 supervised agents in a single node</Comment>{'\n'}
            {'{'}:<Keyword>ok</Keyword>, sup{'}'} = Jido.Supervisor.start_link(){'\n'}
            {'\n'}
            <Keyword>for</Keyword> city &lt;- cities <Keyword>do</Keyword>{'\n'}
            {'  '}Jido.start_agent(sup, <Type>WeatherAgent</Type>, location: city){'\n'}
            <Keyword>end</Keyword>
          </pre>
        </DocsCodeExample>

        {/* Metrics */}
        <div className={cn(
          "grid grid-cols-3 gap-px mt-4",
          "bg-border rounded-md overflow-hidden"
        )}>
          {[
            { value: "5,000", label: "agents started", color: "text-primary" },
            { value: "~100MB", label: "memory usage", color: "text-accent-yellow" },
            { value: "<50ms", label: "startup time", color: "text-accent-cyan" },
          ].map((metric, i) => (
            <div key={i} className="bg-card p-4 text-center">
              <div className={cn("text-lg font-bold", metric.color)}>
                {metric.value}
              </div>
              <div className="text-[10px] text-muted-foreground uppercase tracking-wider mt-1">
                {metric.label}
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Community Section */}
      <section id="community" className="mb-12">
        <h2 className="text-lg font-bold mb-5 flex items-center gap-2">
          <span className="text-accent-cyan">#</span> Join the Community
        </h2>
        
        <div className={cn(
          "rounded-md p-6",
          "bg-accent-cyan/[0.08] border border-accent-cyan/20",
          "flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4"
        )}>
          <div>
            <div className="text-sm font-semibold text-foreground mb-1">
              Questions? Need help debugging production issues?
            </div>
            <div className="text-[13px] text-secondary-foreground">
              Reach out on ElixirForum, GitHub Discussions, or Discord.
            </div>
          </div>
          <div className="flex gap-3">
            <a
              href="https://discord.gg/agentjido"
              target="_blank"
              rel="noopener noreferrer"
              className={cn(
                "px-5 py-2.5 rounded text-xs font-semibold",
                "bg-accent-cyan text-background",
                "hover:opacity-90 transition-opacity"
              )}
            >
              Join Discord
            </a>
            <a
              href="https://github.com/agentjido/jido/issues"
              target="_blank"
              rel="noopener noreferrer"
              className={cn(
                "px-5 py-2.5 rounded text-xs font-medium",
                "border border-accent-cyan text-accent-cyan",
                "hover:bg-accent-cyan/10 transition-colors"
              )}
            >
              GitHub Issues
            </a>
          </div>
        </div>
      </section>
    </DocsLayout>
  );
}
