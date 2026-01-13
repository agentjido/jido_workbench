import { Layout } from "@/components/layout/Layout";
import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";
import { ExternalLink, ArrowRight, Flame, Layers, Zap, Database, Shield, Code } from "lucide-react";

const ashFeatures = [
  {
    icon: Flame,
    title: "Declarative Resources",
    description: "Ash's resource-oriented design aligns perfectly with Jido's action-based agents. Define what, not how."
  },
  {
    icon: Layers,
    title: "Extension System",
    description: "ash_jido integrates as a native Ash extension, bringing autonomous agent capabilities to your resources."
  },
  {
    icon: Database,
    title: "Data Layer Integration",
    description: "Seamlessly connect Jido agents to Ash data layers—Postgres, SQLite, or custom sources."
  },
  {
    icon: Shield,
    title: "Policy-Driven Agents",
    description: "Leverage Ash's powerful policy system to control what your agents can and cannot do."
  },
  {
    icon: Zap,
    title: "Reactor Workflows",
    description: "Combine Ash Reactor's orchestration with Jido's autonomous decision-making for complex workflows."
  },
  {
    icon: Code,
    title: "Code Generation",
    description: "ash_jido provides generators to scaffold agent-ready resources in seconds."
  }
];

const integrationExamples = [
  {
    title: "Define an Agent Resource",
    code: `defmodule MyApp.SupportAgent do
  use Ash.Resource,
    extensions: [AshJido.Agent]

  agent do
    actions [:respond, :escalate, :summarize]
    model :gpt_4
    
    policy :can_escalate, authorize: :admin_only
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string
    attribute :context, :map
  end
end`
  },
  {
    title: "Execute Agent Actions",
    code: `# Run an agent action through Ash
MyApp.SupportAgent
|> Ash.Query.filter(name == "tier-1-support")
|> Ash.read_one!()
|> AshJido.run_action(:respond,
    input: "Customer asking about refund policy",
    context: %{customer_tier: "premium"}
  )`
  }
];

export default function Partners() {
  return (
    <Layout>
      <div className="container">
        {/* Hero Section */}
        <section className="py-16">
          <div className="inline-block bg-primary/10 border border-primary/30 px-4 py-2 rounded mb-6">
            <span className="text-primary text-[11px] font-semibold tracking-wider">
              PARTNERS & INTEGRATIONS
            </span>
          </div>
          
          <h1 className="text-3xl md:text-4xl font-bold leading-tight mb-4">
            Building the future of<br />
            <span className="text-primary">Elixir AI infrastructure</span>
          </h1>
          
          <p className="text-secondary-foreground text-sm md:text-base leading-relaxed max-w-2xl mb-8">
            Jido is designed to integrate seamlessly with the Elixir ecosystem. 
            Our flagship partnership with the Ash Framework brings autonomous agents 
            to declarative, resource-oriented applications.
          </p>
        </section>

        {/* Ash Framework Featured Partner */}
        <section className="mb-16">
          <div className="bg-card border border-border rounded-lg overflow-hidden">
            {/* Partner Header */}
            <div className="bg-elevated border-b border-border px-6 py-4 flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-lg bg-gradient-to-br from-orange-500 to-red-600 flex items-center justify-center">
                  <Flame className="w-6 h-6 text-white" />
                </div>
                <div>
                  <h2 className="text-lg font-bold">Ash Framework</h2>
                  <p className="text-muted-foreground text-xs">Featured Partner</p>
                </div>
              </div>
              <div className="flex gap-2">
                <a 
                  href="https://ash-hq.org/" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="text-xs text-secondary-foreground hover:text-primary transition-colors flex items-center gap-1"
                >
                  ash-hq.org <ExternalLink className="w-3 h-3" />
                </a>
                <span className="text-muted-foreground">•</span>
                <a 
                  href="https://github.com/agentjido/ash_jido" 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="text-xs text-secondary-foreground hover:text-primary transition-colors flex items-center gap-1"
                >
                  ash_jido <ExternalLink className="w-3 h-3" />
                </a>
              </div>
            </div>

            {/* Partner Content */}
            <div className="p-6 md:p-8">
              <div className="grid md:grid-cols-2 gap-8 mb-8">
                <div>
                  <h3 className="text-accent-yellow text-sm font-bold mb-4 tracking-wide">
                    WHY ASH + JIDO?
                  </h3>
                  <p className="text-secondary-foreground text-sm leading-relaxed mb-4">
                    Ash Framework is the most powerful declarative application framework for Elixir. 
                    Its resource-oriented architecture, policy system, and extension model make it 
                    the perfect foundation for building AI-powered applications.
                  </p>
                  <p className="text-secondary-foreground text-sm leading-relaxed mb-6">
                    The <code className="text-primary bg-primary/10 px-1.5 py-0.5 rounded text-xs">ash_jido</code> extension 
                    brings Jido's autonomous agent capabilities directly into your Ash resources—with 
                    full policy integration, data layer access, and Reactor workflow support.
                  </p>
                  
                  <div className="flex gap-3">
                    <Button 
                      asChild 
                      className="bg-primary text-primary-foreground hover:bg-primary/90 text-xs font-bold"
                    >
                      <a 
                        href="https://github.com/agentjido/ash_jido" 
                        target="_blank" 
                        rel="noopener noreferrer"
                      >
                        Get ash_jido <ArrowRight className="w-3 h-3 ml-1" />
                      </a>
                    </Button>
                    <Button 
                      asChild 
                      variant="outline" 
                      className="text-xs border-accent-cyan text-accent-cyan hover:bg-accent-cyan/10"
                    >
                      <a 
                        href="https://ash-hq.org/" 
                        target="_blank" 
                        rel="noopener noreferrer"
                      >
                        Learn Ash Framework
                      </a>
                    </Button>
                  </div>
                </div>

                <div className="bg-code-bg border border-border rounded-md overflow-hidden">
                  <div className="bg-elevated px-4 py-2 border-b border-border flex items-center justify-between">
                    <span className="text-muted-foreground text-[10px]">mix.exs</span>
                    <div className="flex gap-1.5">
                      <span className="w-2.5 h-2.5 rounded-full bg-accent-red/60"></span>
                      <span className="w-2.5 h-2.5 rounded-full bg-accent-yellow/60"></span>
                      <span className="w-2.5 h-2.5 rounded-full bg-primary/60"></span>
                    </div>
                  </div>
                  <pre className="p-4 text-[11px] leading-relaxed overflow-x-auto">
                    <code>
                      <span className="syntax-comment"># Add to your dependencies</span>{"\n"}
                      <span className="syntax-keyword">def</span> <span className="syntax-function">deps</span> <span className="syntax-keyword">do</span>{"\n"}
                      {"  "}[{"\n"}
                      {"    "}{`{`}<span className="syntax-atom">:ash</span>, <span className="syntax-string">"~&gt; 3.0"</span>{`}`},{"\n"}
                      {"    "}{`{`}<span className="syntax-atom">:ash_jido</span>, <span className="syntax-string">"~&gt; 0.1.0"</span>{`}`},{"\n"}
                      {"    "}{`{`}<span className="syntax-atom">:jido_ai</span>, <span className="syntax-string">"~&gt; 0.1.0"</span>{`}`}{"\n"}
                      {"  "}]{"\n"}
                      <span className="syntax-keyword">end</span>
                    </code>
                  </pre>
                </div>
              </div>

              {/* Features Grid */}
              <h3 className="text-primary text-sm font-bold mb-4 tracking-wide">
                INTEGRATION HIGHLIGHTS
              </h3>
              <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {ashFeatures.map((feature, idx) => (
                  <div 
                    key={idx} 
                    className="bg-surface border border-border rounded-md p-4 hover:border-border-strong transition-colors"
                  >
                    <feature.icon className="w-5 h-5 text-accent-yellow mb-3" />
                    <h4 className="text-sm font-semibold mb-1">{feature.title}</h4>
                    <p className="text-muted-foreground text-xs leading-relaxed">
                      {feature.description}
                    </p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </section>

        {/* Code Examples */}
        <section className="mb-16">
          <div className="flex items-center gap-3 mb-6">
            <span className="text-foreground text-sm font-bold tracking-wide">CODE EXAMPLES</span>
            <div className="flex-1 h-px bg-border"></div>
          </div>

          <div className="grid md:grid-cols-2 gap-6">
            {integrationExamples.map((example, idx) => (
              <div 
                key={idx} 
                className="bg-code-bg border border-border rounded-md overflow-hidden"
              >
                <div className="bg-elevated px-4 py-2.5 border-b border-border">
                  <span className="text-foreground text-xs font-semibold">{example.title}</span>
                </div>
                <pre className="p-4 text-[11px] leading-relaxed overflow-x-auto">
                  <code className="text-secondary-foreground">{example.code}</code>
                </pre>
              </div>
            ))}
          </div>
        </section>

        {/* Other Partners */}
        <section className="mb-16">
          <div className="flex items-center gap-3 mb-6">
            <span className="text-foreground text-sm font-bold tracking-wide">ECOSYSTEM INTEGRATIONS</span>
            <div className="flex-1 h-px bg-border"></div>
          </div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {[
              { name: "Phoenix", status: "Compatible", desc: "Works seamlessly in Phoenix applications" },
              { name: "LiveView", status: "Compatible", desc: "Real-time agent UIs with LiveView" },
              { name: "Oban", status: "Planned", desc: "Background job integration for agent tasks" },
              { name: "Broadway", status: "Planned", desc: "Data pipeline processing with agents" },
              { name: "Commanded", status: "Exploring", desc: "Event sourcing with autonomous agents" },
              { name: "Nx/Bumblebee", status: "Exploring", desc: "Local ML model execution" }
            ].map((partner, idx) => (
              <div 
                key={idx} 
                className="bg-card border border-border rounded-md p-4 hover:border-border-strong transition-colors"
              >
                <div className="flex items-center justify-between mb-2">
                  <h4 className="text-sm font-semibold">{partner.name}</h4>
                  <span className={`text-[9px] font-bold tracking-wider px-2 py-0.5 rounded ${
                    partner.status === "Compatible" 
                      ? "text-primary bg-primary/15" 
                      : partner.status === "Planned"
                      ? "text-accent-yellow bg-accent-yellow/15"
                      : "text-muted-foreground bg-muted"
                  }`}>
                    {partner.status.toUpperCase()}
                  </span>
                </div>
                <p className="text-muted-foreground text-xs">{partner.desc}</p>
              </div>
            ))}
          </div>
        </section>

        {/* CTA */}
        <section className="cta-glow rounded-lg p-8 md:p-12 text-center mb-16">
          <h2 className="text-2xl font-bold mb-3">Interested in partnering?</h2>
          <p className="text-secondary-foreground text-sm mb-6 max-w-lg mx-auto">
            We're building the AI infrastructure layer for Elixir. 
            If you maintain an Elixir library and want to explore integration, let's talk.
          </p>
          <div className="flex gap-3 justify-center">
            <Button asChild className="bg-primary text-primary-foreground hover:bg-primary/90 text-xs font-bold">
              <a href="https://github.com/agentjido" target="_blank" rel="noopener noreferrer">
                GitHub Discussions <ArrowRight className="w-3 h-3 ml-1" />
              </a>
            </Button>
            <Button asChild variant="outline" className="text-xs">
              <Link to="/docs">Read the Docs</Link>
            </Button>
          </div>
        </section>
      </div>
    </Layout>
  );
}
