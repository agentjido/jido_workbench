import { useState } from "react";
import { Link } from "react-router-dom";
import { Layout } from "@/components/layout/Layout";
import { cn } from "@/lib/utils";

type Layer = "foundation" | "core" | "ai" | "app";

interface Package {
  name: string;
  desc: string;
  links: { hex: string; docs: string; github: string };
}

const packages: Record<Layer, Package[]> = {
  foundation: [
    {
      name: "llmdb",
      desc: "Model registry and metadata. Token limits, pricing, capabilities for OpenAI, Anthropic, Google, and custom providers.",
      links: { hex: "https://hex.pm/packages/llmdb", docs: "/docs/packages/llmdb", github: "https://github.com/agentjido/llmdb" }
    },
    {
      name: "req_llm",
      desc: "HTTP client for LLM APIs. Built on Req with automatic retries, rate limiting, streaming, and function calling.",
      links: { hex: "https://hex.pm/packages/req_llm", docs: "/docs/packages/req-llm", github: "https://github.com/agentjido/req_llm" }
    }
  ],
  core: [
    {
      name: "jido",
      desc: "BEAM-native bot framework. OTP supervision, isolated processes, message-passing. Run 10k+ agents per node.",
      links: { hex: "https://hex.pm/packages/jido", docs: "/docs/packages/jido", github: "https://github.com/agentjido/jido" }
    },
    {
      name: "jido_action",
      desc: "Schema-based action validation. Required fields, defaults, type constraints. Composable action primitives.",
      links: { hex: "https://hex.pm/packages/jido_action", docs: "/docs/packages/jido-action", github: "https://github.com/agentjido/jido" }
    },
    {
      name: "jido_signal",
      desc: "Pub/sub signaling between agents. Decoupled coordination via BEAM message-passing. No external broker.",
      links: { hex: "https://hex.pm/packages/jido_signal", docs: "/docs/packages/jido-signal", github: "https://github.com/agentjido/jido" }
    }
  ],
  ai: [
    {
      name: "jido_ai",
      desc: "LLM-powered agents with token/cost tracking, tool calling, and streaming. Integrates jido + req_llm + llmdb.",
      links: { hex: "https://hex.pm/packages/jido_ai", docs: "/docs/packages/jido-ai", github: "https://github.com/agentjido/jido_ai" }
    }
  ],
  app: [
    {
      name: "jido_coder",
      desc: "AI coding agent with file operations, git integration, code analysis, and test execution workflows.",
      links: { hex: "https://hex.pm/packages/jido_coder", docs: "/docs/packages/jido-coder", github: "https://github.com/agentjido/jido_coder" }
    }
  ]
};

const useCases = [
  { id: "bots", label: "Autonomous bots (no AI)", install: "jido", why: "Core framework only, minimal deps" },
  { id: "custom-llm", label: "Custom LLM integration", install: "jido + req_llm", why: "Bot framework + LLM client" },
  { id: "ai-agents", label: "AI-powered agents", install: "jido_ai", why: "Integrated Jido + LLM handling" },
  { id: "coding", label: "Code analysis/generation", install: "jido_coder", why: "Specialized for coding workflows" },
  { id: "llm-only", label: "Just LLM API calls", install: "req_llm + llmdb", why: "Foundation layer only, no agents" }
];

const layerConfig: Record<Layer, { color: string; bgClass: string; borderClass: string }> = {
  foundation: { color: "text-accent-cyan", bgClass: "bg-accent-cyan/15", borderClass: "border-t-accent-cyan" },
  core: { color: "text-primary", bgClass: "bg-primary/15", borderClass: "border-t-primary" },
  ai: { color: "text-accent-yellow", bgClass: "bg-accent-yellow/15", borderClass: "border-t-accent-yellow" },
  app: { color: "text-accent-red", bgClass: "bg-accent-red/15", borderClass: "border-t-accent-red" }
};

function LayerBadge({ layer }: { layer: Layer }) {
  const config = layerConfig[layer];
  return (
    <span className={cn(
      "text-[9px] font-bold tracking-wider px-2 py-0.5 rounded uppercase",
      config.color,
      config.bgClass
    )}>
      {layer}
    </span>
  );
}

function PackageCard({ pkg, layer }: { pkg: Package; layer: Layer }) {
  const config = layerConfig[layer];
  return (
    <div className={cn(
      "bg-card border border-border rounded-md p-5",
      "border-t-[3px] transition-all duration-200",
      "hover:border-border-strong hover:-translate-y-0.5 cursor-pointer",
      config.borderClass
    )}>
      <div className="flex justify-between items-start mb-3">
        <span className="text-sm font-bold text-foreground">{pkg.name}</span>
        <LayerBadge layer={layer} />
      </div>
      <p className="text-xs text-muted-foreground leading-relaxed mb-4">{pkg.desc}</p>
      <div className="flex gap-2">
        {Object.entries(pkg.links).map(([label, href]) => (
          <a
            key={label}
            href={href}
            target={href.startsWith("http") ? "_blank" : undefined}
            rel={href.startsWith("http") ? "noopener noreferrer" : undefined}
            className={cn(
              "text-[10px] px-2 py-1 rounded",
              "bg-elevated text-muted-foreground",
              "hover:text-primary transition-colors"
            )}
          >
            {label}
          </a>
        ))}
      </div>
    </div>
  );
}

// Syntax highlighting components
const Keyword = ({ children }: { children: React.ReactNode }) => <span className="syntax-keyword">{children}</span>;
const Str = ({ children }: { children: React.ReactNode }) => <span className="syntax-string">{children}</span>;
const Func = ({ children }: { children: React.ReactNode }) => <span className="syntax-function">{children}</span>;
const Type = ({ children }: { children: React.ReactNode }) => <span className="syntax-type">{children}</span>;
const Comment = ({ children }: { children: React.ReactNode }) => <span className="syntax-comment">{children}</span>;

export default function Ecosystem() {
  const [activeView, setActiveView] = useState<"beam" | "other">("beam");
  const [selectedUseCase, setSelectedUseCase] = useState<string | null>(null);

  return (
    <Layout>
      <div className="max-w-[1000px] mx-auto px-6 py-12">
        {/* Hero Section */}
        <section className="mb-12">
          <div className={cn(
            "inline-block px-4 py-2 rounded mb-5",
            "bg-primary/10 border border-primary/30"
          )}>
            <span className="text-primary text-[11px] font-semibold tracking-widest uppercase">
              PACKAGE ECOSYSTEM
            </span>
          </div>
          
          <h1 className="text-3xl font-bold leading-tight mb-4 tracking-tight">
            Most agent frameworks are monoliths.<br />
            <span className="text-primary">Jido is composable.</span>
          </h1>
          
          <p className="text-sm text-secondary-foreground leading-relaxed max-w-[600px] mb-6">
            Use the full stack or pick the packages you need. Foundation packages for LLM handling,
            core framework for autonomy, and specialized packages for AI and coding workflows.
          </p>

          {/* Quick Stats */}
          <div className="flex gap-6 mb-8">
            {[
              { value: "7", label: "packages" },
              { value: "4", label: "layers" },
              { value: "0", label: "forced deps" }
            ].map((stat, i) => (
              <div key={i} className="flex items-baseline gap-2">
                <span className="text-primary text-2xl font-bold">{stat.value}</span>
                <span className="text-muted-foreground text-xs">{stat.label}</span>
              </div>
            ))}
          </div>
        </section>

        {/* Dependency Graph */}
        <section className="mb-16">
          <div className="flex justify-between items-center mb-5">
            <span className="text-sm font-bold tracking-wider">DEPENDENCY GRAPH</span>
            <span className="text-[11px] text-muted-foreground">packages compose bottom-up</span>
          </div>
          
          <div className="bg-code-bg border border-border rounded-md overflow-hidden">
            <div className="bg-elevated px-5 py-3 border-b border-border flex justify-between items-center">
              <div className="flex gap-2">
                <span className="w-2.5 h-2.5 rounded-full bg-accent-red"></span>
                <span className="w-2.5 h-2.5 rounded-full bg-accent-yellow"></span>
                <span className="w-2.5 h-2.5 rounded-full bg-primary"></span>
              </div>
              <span className="text-[10px] text-muted-foreground">dependency_graph.txt</span>
            </div>
            <div className="p-8 text-[11px] leading-relaxed overflow-x-auto">
              <pre className="m-0 font-mono">
{`                              ┌─────────────────┐
                              │ `}<span className="text-accent-red">jido_coder</span>{`    │  ◀── AI coding workflows
                              │ `}<span className="text-muted-foreground">file ops, git</span>{`  │
                              └────────┬────────┘
                                       │
                              ┌────────▼────────┐
                              │    `}<span className="text-accent-yellow">jido_ai</span>{`     │  ◀── LLM-powered agents
                              │ `}<span className="text-muted-foreground">token tracking</span>{` │
                              └────────┬────────┘
                     ┌─────────────────┼─────────────────┐
                     │                 │                 │
              ┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
              │    `}<span className="text-primary">jido</span>{`    │   │`}<span className="text-primary">jido_action</span>{` │   │`}<span className="text-primary">jido_signal</span>{` │
              │ `}<span className="text-muted-foreground">bot core</span>{`   │   │ `}<span className="text-muted-foreground">validation</span>{` │   │ `}<span className="text-muted-foreground">pub/sub</span>{`    │
              └──────┬──────┘   └─────────────┘   └─────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
 ┌──────▼──────┐          ┌───────▼──────┐
 │  `}<span className="text-accent-cyan">req_llm</span>{`   │          │    `}<span className="text-accent-cyan">llmdb</span>{`    │
 │ `}<span className="text-muted-foreground">HTTP client</span>{`│          │ `}<span className="text-muted-foreground">model registry</span>{`│
 └─────────────┘          └──────────────┘`}
              </pre>
            </div>
          </div>
        </section>

        {/* Why This Architecture */}
        <section className="mb-16">
          <div className="flex justify-between items-center mb-5">
            <span className="text-sm font-bold tracking-wider">WHY THIS ARCHITECTURE?</span>
            <div className="flex gap-1">
              <button
                onClick={() => setActiveView("beam")}
                className={cn(
                  "px-4 py-2 rounded text-[11px] font-semibold transition-colors",
                  activeView === "beam"
                    ? "bg-primary/10 border border-primary text-primary"
                    : "border border-border text-muted-foreground hover:text-foreground"
                )}
              >
                FOR ELIXIR/OTP DEVS
              </button>
              <button
                onClick={() => setActiveView("other")}
                className={cn(
                  "px-4 py-2 rounded text-[11px] font-semibold transition-colors",
                  activeView === "other"
                    ? "bg-accent-cyan/10 border border-accent-cyan text-accent-cyan"
                    : "border border-border text-muted-foreground hover:text-foreground"
                )}
              >
                FROM OTHER ECOSYSTEMS
              </button>
            </div>
          </div>

          <div className="bg-card border border-border rounded-md p-6">
            {activeView === "beam" ? (
              <div className="grid md:grid-cols-2 gap-6">
                <div>
                  <h3 className="text-primary text-[13px] font-bold mb-3">COMPOSES WITH YOUR OTP APP</h3>
                  <ul className="text-secondary-foreground text-xs leading-loose pl-4 space-y-1 list-disc">
                    <li>Jido agents integrate into existing supervision trees</li>
                    <li>Each agent is a BEAM process with its own mailbox</li>
                    <li>Use standard tools: <code className="text-accent-yellow">Observer</code>, <code className="text-accent-yellow">Telemetry</code>, <code className="text-accent-yellow">Logger</code></li>
                    <li>No new runtime concepts—just processes and messages</li>
                  </ul>
                </div>
                <div className="bg-code-bg rounded p-4 text-[11px]">
                  <pre className="m-0">
                    <Comment># Add to your application.ex</Comment>{'\n'}
                    <Keyword>def</Keyword> <Func>start</Func>(_type, _args) <Keyword>do</Keyword>{'\n'}
                    {'  '}children = [{'\n'}
                    {'    '}<Type>MyApp.Repo</Type>,{'\n'}
                    {'    '}<Type>MyAppWeb.Endpoint</Type>,{'\n'}
                    {'    '}<Comment># Add Jido to your tree</Comment>{'\n'}
                    {'    '}{'{'}<Type>Jido.Supervisor</Type>, name: <Type>MyAgents</Type>{'}'}{'\n'}
                    {'  '}]{'\n'}
                    {'  '}<Type>Supervisor</Type>.start_link(children){'\n'}
                    <Keyword>end</Keyword>
                  </pre>
                </div>
              </div>
            ) : (
              <div className="grid md:grid-cols-2 gap-6">
                <div>
                  <h3 className="text-accent-cyan text-[13px] font-bold mb-3">MENTAL MODEL TRANSLATION</h3>
                  <div className="text-xs space-y-2">
                    {[
                      { from: "Thread pools", to: "BEAM processes" },
                      { from: "Shared memory + locks", to: "Isolated state per agent" },
                      { from: "Kafka / Redis queues", to: "Message-passing" },
                      { from: "K8s orchestration", to: "OTP supervision" }
                    ].map((item, i) => (
                      <div key={i} className="grid grid-cols-[1fr_auto_1fr] gap-2 items-center">
                        <span className="text-muted-foreground">{item.from}</span>
                        <span className="text-accent-cyan">→</span>
                        <span className="text-foreground">{item.to}</span>
                      </div>
                    ))}
                  </div>
                </div>
                <div className="bg-code-bg rounded p-4 text-[11px]">
                  <pre className="m-0">
                    <Comment># Python: worker pool + Redis</Comment>{'\n'}
                    <span className="text-muted-foreground">pool = WorkerPool(size=100)</span>{'\n'}
                    <span className="text-muted-foreground">redis.lpush(queue, task)</span>{'\n'}
                    {'\n'}
                    <Comment># Jido: supervised processes</Comment>{'\n'}
                    <Keyword>for</Keyword> i &lt;- <Str>1..100</Str> <Keyword>do</Keyword>{'\n'}
                    {'  '}<Type>Jido</Type>.start_agent(sup, <Type>MyAgent</Type>){'\n'}
                    <Keyword>end</Keyword>{'\n'}
                    <Comment># No external queue needed</Comment>
                  </pre>
                </div>
              </div>
            )}
          </div>
        </section>

        {/* All Packages */}
        <section className="mb-16">
          <div className="flex justify-between items-center mb-6">
            <span className="text-sm font-bold tracking-wider">ALL PACKAGES</span>
            <span className="text-[11px] text-muted-foreground">click any package for details</span>
          </div>

          {/* Application Layer */}
          <div className="mb-6">
            <div className="flex items-center gap-3 mb-3">
              <span className="text-accent-red text-[11px] font-bold">APPLICATION LAYER</span>
              <div className="flex-1 h-px bg-border"></div>
            </div>
            <div className="grid grid-cols-1 gap-3">
              {packages.app.map(pkg => <PackageCard key={pkg.name} pkg={pkg} layer="app" />)}
            </div>
          </div>

          {/* AI Layer */}
          <div className="mb-6">
            <div className="flex items-center gap-3 mb-3">
              <span className="text-accent-yellow text-[11px] font-bold">AI LAYER</span>
              <div className="flex-1 h-px bg-border"></div>
            </div>
            <div className="grid grid-cols-1 gap-3">
              {packages.ai.map(pkg => <PackageCard key={pkg.name} pkg={pkg} layer="ai" />)}
            </div>
          </div>

          {/* Core Layer */}
          <div className="mb-6">
            <div className="flex items-center gap-3 mb-3">
              <span className="text-primary text-[11px] font-bold">CORE LAYER</span>
              <div className="flex-1 h-px bg-border"></div>
            </div>
            <div className="grid md:grid-cols-3 gap-3">
              {packages.core.map(pkg => <PackageCard key={pkg.name} pkg={pkg} layer="core" />)}
            </div>
          </div>

          {/* Foundation Layer */}
          <div>
            <div className="flex items-center gap-3 mb-3">
              <span className="text-accent-cyan text-[11px] font-bold">FOUNDATION LAYER</span>
              <div className="flex-1 h-px bg-border"></div>
            </div>
            <div className="grid md:grid-cols-2 gap-3">
              {packages.foundation.map(pkg => <PackageCard key={pkg.name} pkg={pkg} layer="foundation" />)}
            </div>
          </div>
        </section>

        {/* Decision Tree */}
        <section className="mb-16">
          <div className="mb-5">
            <span className="text-sm font-bold tracking-wider">WHICH PACKAGES DO I NEED?</span>
          </div>

          <div className="bg-card border border-border rounded-md overflow-hidden">
            {/* Header */}
            <div className="grid grid-cols-2 border-b border-border">
              <div className="px-5 py-3 border-r border-border">
                <span className="text-[11px] font-semibold text-muted-foreground">USE CASE</span>
              </div>
              <div className="grid grid-cols-2">
                <div className="px-5 py-3 border-r border-border">
                  <span className="text-[11px] font-semibold text-muted-foreground">INSTALL</span>
                </div>
                <div className="px-5 py-3">
                  <span className="text-[11px] font-semibold text-muted-foreground">WHY</span>
                </div>
              </div>
            </div>

            {/* Rows */}
            {useCases.map((uc, i) => (
              <div
                key={uc.id}
                onClick={() => setSelectedUseCase(selectedUseCase === uc.id ? null : uc.id)}
                className={cn(
                  "grid grid-cols-2 cursor-pointer transition-colors",
                  i < useCases.length - 1 && "border-b border-border",
                  selectedUseCase === uc.id ? "bg-primary/5" : "hover:bg-elevated"
                )}
              >
                <div className="px-5 py-4 border-r border-border">
                  <span className="text-xs text-foreground">{uc.label}</span>
                </div>
                <div className="grid grid-cols-2">
                  <div className="px-5 py-4 border-r border-border">
                    <code className="text-primary text-[11px]">{uc.install}</code>
                  </div>
                  <div className="px-5 py-4">
                    <span className="text-[11px] text-muted-foreground">{uc.why}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Expanded code */}
          {selectedUseCase && (
            <div className="bg-code-bg border border-border border-t-0 rounded-b-md p-5 -mt-px">
              <div className="text-[11px] leading-relaxed">
                {selectedUseCase === "bots" && (
                  <pre className="m-0">
                    <Comment># mix.exs - Autonomous bots, no AI</Comment>{'\n'}
                    <Keyword>def</Keyword> <Func>deps</Func> <Keyword>do</Keyword>{'\n'}
                    {'  '}[{'{'}<Keyword>:jido</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'}]{'\n'}
                    <Keyword>end</Keyword>
                  </pre>
                )}
                {selectedUseCase === "custom-llm" && (
                  <pre className="m-0">
                    <Comment># mix.exs - Bots + your own LLM integration</Comment>{'\n'}
                    <Keyword>def</Keyword> <Func>deps</Func> <Keyword>do</Keyword>{'\n'}
                    {'  '}[{'\n'}
                    {'    '}{'{'}<Keyword>:jido</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'},{'\n'}
                    {'    '}{'{'}<Keyword>:req_llm</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'}{'\n'}
                    {'  '}]{'\n'}
                    <Keyword>end</Keyword>
                  </pre>
                )}
                {selectedUseCase === "ai-agents" && (
                  <pre className="m-0">
                    <Comment># mix.exs - Full AI agent stack</Comment>{'\n'}
                    <Keyword>def</Keyword> <Func>deps</Func> <Keyword>do</Keyword>{'\n'}
                    {'  '}[{'{'}<Keyword>:jido_ai</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'}]  <Comment># includes jido, req_llm, llmdb</Comment>{'\n'}
                    <Keyword>end</Keyword>
                  </pre>
                )}
                {selectedUseCase === "coding" && (
                  <pre className="m-0">
                    <Comment># mix.exs - AI coding agents</Comment>{'\n'}
                    <Keyword>def</Keyword> <Func>deps</Func> <Keyword>do</Keyword>{'\n'}
                    {'  '}[{'{'}<Keyword>:jido_coder</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'}]  <Comment># includes full stack</Comment>{'\n'}
                    <Keyword>end</Keyword>
                  </pre>
                )}
                {selectedUseCase === "llm-only" && (
                  <pre className="m-0">
                    <Comment># mix.exs - Just LLM calls, no agents</Comment>{'\n'}
                    <Keyword>def</Keyword> <Func>deps</Func> <Keyword>do</Keyword>{'\n'}
                    {'  '}[{'\n'}
                    {'    '}{'{'}<Keyword>:req_llm</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'},{'\n'}
                    {'    '}{'{'}<Keyword>:llmdb</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'}{'\n'}
                    {'  '}]{'\n'}
                    <Keyword>end</Keyword>
                  </pre>
                )}
              </div>
            </div>
          )}
        </section>

        {/* Composability Examples */}
        <section className="mb-16">
          <div className="mb-5">
            <span className="text-sm font-bold tracking-wider">COMPOSABILITY IN ACTION</span>
          </div>
          
          <div className="grid md:grid-cols-2 gap-4">
            <div className="bg-card border border-border rounded-md overflow-hidden">
              <div className="bg-elevated px-4 py-3 border-b border-border">
                <span className="text-xs font-semibold">Start with core, add AI later</span>
              </div>
              <div className="p-4 text-[11px]">
                <pre className="m-0 leading-relaxed">
                  <Comment># Phase 1: Just bots</Comment>{'\n'}
                  {'{'}<Keyword>:jido</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'}{'\n'}
                  {'\n'}
                  <Comment># Phase 2: Add LLM capabilities</Comment>{'\n'}
                  {'{'}<Keyword>:jido</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'},{'\n'}
                  {'{'}<Keyword>:req_llm</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'}{'\n'}
                  {'\n'}
                  <Comment># Phase 3: Use integrated layer</Comment>{'\n'}
                  {'{'}<Keyword>:jido_ai</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'}
                </pre>
              </div>
            </div>

            <div className="bg-card border border-border rounded-md overflow-hidden">
              <div className="bg-elevated px-4 py-3 border-b border-border">
                <span className="text-xs font-semibold">Foundation layer standalone</span>
              </div>
              <div className="p-4 text-[11px]">
                <pre className="m-0 leading-relaxed">
                  <Comment># Just LLM handling (no bots)</Comment>{'\n'}
                  {'{'}<Keyword>:req_llm</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'},{'\n'}
                  {'{'}<Keyword>:llmdb</Keyword>, <Str>"~&gt; 0.1.0"</Str>{'}'}{'\n'}
                  {'\n'}
                  <Comment># Use in any GenServer, Phoenix, etc.</Comment>{'\n'}
                  <Type>ReqLLM</Type>.chat(<Keyword>:openai</Keyword>, <Str>"gpt-4"</Str>,{'\n'}
                  {'  '}messages: [%{'{'}role: <Str>"user"</Str>, ...{'}'}]{'\n'}
                  )
                </pre>
              </div>
            </div>
          </div>
        </section>

        {/* When NOT to use */}
        <section className="mb-16">
          <div className={cn(
            "rounded-md p-6",
            "bg-accent-red/5 border border-accent-red/20"
          )}>
            <div className="flex items-center gap-2 mb-4">
              <span className="text-accent-red text-lg">⚠</span>
              <span className="text-accent-red text-[13px] font-bold">WHEN NOT TO USE THE FULL STACK</span>
            </div>
            <div className="grid md:grid-cols-2 gap-4 mb-4">
              {[
                { condition: "Don't need agents?", action: "Just use req_llm + llmdb" },
                { condition: "Don't need LLMs?", action: "Just use jido" },
                { condition: "Need custom LLM client?", action: "Use jido + your client" },
                { condition: "Not building coding agents?", action: "Use jido_ai, skip jido_coder" }
              ].map((item, i) => (
                <div key={i} className="flex items-baseline gap-2 text-xs">
                  <span className="text-muted-foreground">{item.condition}</span>
                  <span className="text-accent-cyan">→</span>
                  <span className="text-foreground">{item.action}</span>
                </div>
              ))}
            </div>
            <p className="text-xs text-secondary-foreground">
              The ecosystem is composable by design—use what you need, skip what you don't.
            </p>
          </div>
        </section>

        {/* Quick Reference */}
        <section className="mb-16">
          <div className="mb-5">
            <span className="text-sm font-bold tracking-wider">QUICK REFERENCE</span>
          </div>
          
          <div className="bg-card border border-border rounded-md overflow-hidden">
            <table className="w-full text-xs border-collapse">
              <thead>
                <tr className="bg-elevated">
                  <th className="p-4 text-left font-semibold text-muted-foreground border-b border-border">Package</th>
                  <th className="p-4 text-left font-semibold text-muted-foreground border-b border-border">Primary Use</th>
                  <th className="p-4 text-center font-semibold text-muted-foreground border-b border-border">Hex</th>
                  <th className="p-4 text-center font-semibold text-muted-foreground border-b border-border">Docs</th>
                  <th className="p-4 text-center font-semibold text-muted-foreground border-b border-border">GitHub</th>
                </tr>
              </thead>
              <tbody>
                {[
                  { name: "llmdb", use: "Model registry", layer: "foundation" as Layer },
                  { name: "req_llm", use: "LLM API client", layer: "foundation" as Layer },
                  { name: "jido", use: "Bot framework", layer: "core" as Layer },
                  { name: "jido_action", use: "Action primitives", layer: "core" as Layer },
                  { name: "jido_signal", use: "Event/signal handling", layer: "core" as Layer },
                  { name: "jido_ai", use: "AI-powered agents", layer: "ai" as Layer },
                  { name: "jido_coder", use: "Coding agents", layer: "app" as Layer }
                ].map((pkg, i) => (
                  <tr key={pkg.name} className={cn(
                    "border-b border-border",
                    i % 2 === 1 && "bg-elevated"
                  )}>
                    <td className="p-4">
                      <div className="flex items-center gap-2">
                        <code className="font-semibold">{pkg.name}</code>
                        <LayerBadge layer={pkg.layer} />
                      </div>
                    </td>
                    <td className="p-4 text-muted-foreground">{pkg.use}</td>
                    <td className="p-4 text-center">
                      <a href="#" className="text-primary hover:underline">↗</a>
                    </td>
                    <td className="p-4 text-center">
                      <a href="#" className="text-primary hover:underline">↗</a>
                    </td>
                    <td className="p-4 text-center">
                      <a href="#" className="text-primary hover:underline">↗</a>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>

        {/* Production Notes */}
        <section className="mb-16">
          <div className="mb-5">
            <span className="text-sm font-bold tracking-wider">PRODUCTION NOTES</span>
          </div>
          
          <div className="grid md:grid-cols-3 gap-4">
            {[
              {
                title: "Supervision Strategy",
                items: [
                  "All packages work under OTP supervision",
                  "Each agent is a supervised process",
                  "Package composition doesn't change patterns"
                ]
              },
              {
                title: "Failure Isolation",
                items: [
                  "ReqLLM failures isolated to calling agent",
                  "LLMDB is stateless, no crash risk",
                  "Supervisors handle crashes regardless of LLM use"
                ]
              },
              {
                title: "Observability",
                items: [
                  "All packages emit telemetry events",
                  "Standard Elixir tooling works",
                  "JidoAI adds LLM-specific metrics"
                ]
              }
            ].map((section, i) => (
              <div key={i} className="bg-card border border-border rounded-md p-5">
                <h4 className="text-primary text-[11px] font-bold tracking-wider mb-3 uppercase">
                  {section.title}
                </h4>
                <ul className="text-[11px] text-secondary-foreground leading-relaxed pl-4 space-y-1 list-disc">
                  {section.items.map((item, j) => (
                    <li key={j}>{item}</li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </section>

        {/* CTA Section */}
        <section className={cn(
          "text-center p-12 rounded-lg mb-16",
          "bg-primary/5 border border-primary/20"
        )}>
          <h2 className="text-2xl font-bold mb-3">Ready to build?</h2>
          <p className="text-sm text-secondary-foreground mb-6">
            Start with the getting started guide or explore production examples.
          </p>
          <div className="flex gap-3 justify-center">
            <Link
              to="/docs/installation"
              className={cn(
                "px-7 py-3 rounded text-[13px] font-bold",
                "bg-primary text-background",
                "hover:opacity-90 transition-opacity"
              )}
            >
              GET STARTED →
            </Link>
            <Link
              to="/examples"
              className={cn(
                "px-7 py-3 rounded text-[13px] font-medium",
                "border border-accent-cyan text-accent-cyan",
                "hover:bg-accent-cyan/10 transition-colors"
              )}
            >
              VIEW EXAMPLES
            </Link>
          </div>
        </section>
      </div>
    </Layout>
  );
}
