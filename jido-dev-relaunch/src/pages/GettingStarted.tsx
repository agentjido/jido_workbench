import { motion } from "framer-motion";
import { Layout } from "@/components/layout/Layout";
import { CodeBlock } from "@/components/ui/code-block";
import { ExternalLink, ArrowRight, Terminal, Eye, Rocket } from "lucide-react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";

const step1Code = `# mix.exs
def deps do
  [
    {:jido, "~> 0.1.0"}  # Check Hex for latest version
  ]
end`;

const step2Code = `defmodule MyFirstAgent do
  use Jido.Agent

  def init(_args) do
    {:ok, %{counter: 0}}
  end

  def handle_action(:increment, state) do
    new_state = %{state | counter: state.counter + 1}
    {:ok, new_state}
  end
end`;

const step3Code = `# Start a supervisor
{:ok, sup} = DynamicSupervisor.start_link(
  strategy: :one_for_one,
  name: MyAgentSupervisor
)

# Start 1,000 agents
for i <- 1..1_000 do
  spec = {MyFirstAgent, id: i}
  DynamicSupervisor.start_child(sup, spec)
end`;

const step4Code = `# Start Observer
:observer.start()

# Inspect a specific agent process
pid = Process.whereis(MyFirstAgent)
:sys.get_state(pid)`;

const steps = [
  {
    number: 1,
    title: "Install the Hex Package",
    icon: Terminal,
    code: step1Code,
    note: "Use the version from Hex; main on GitHub may be ahead.",
  },
  {
    number: 2,
    title: "Define Your First Agent",
    icon: Rocket,
    code: step2Code,
    note: "If this function raises, the agent process crashes. The supervisor handles restart.",
  },
  {
    number: 3,
    title: "Supervise Many Agents",
    icon: Rocket,
    code: step3Code,
    note: "This example starts 1,000 agents; adjust N to see CPU and memory impact.",
  },
  {
    number: 4,
    title: "Observe Your Agents",
    icon: Eye,
    code: step4Code,
    note: "Standard Elixir tooling works out of the box.",
  },
];

export default function GettingStarted() {
  return (
    <Layout>
      <section className="py-20 lg:py-32">
        <div className="container max-w-4xl">
          {/* Hero */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="text-center mb-16"
          >
            <h1 className="text-4xl sm:text-5xl font-bold mb-6">
              Getting <span className="gradient-text">Started</span>
            </h1>
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
              You don't need a cluster to evaluate Jido—start with a single node, a few thousand agents, and your usual metrics tools.
            </p>
          </motion.div>

          {/* Path selection */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="grid sm:grid-cols-2 gap-4 mb-16"
          >
            <div className="feature-card">
              <h3 className="font-semibold mb-2 text-primary">Know Elixir/OTP?</h3>
              <p className="text-sm text-muted-foreground">
                Jump straight to the code. Add to mix.exs, wire into supervision tree, run in iex.
              </p>
            </div>
            <div className="feature-card">
              <h3 className="font-semibold mb-2 text-accent">New to the BEAM?</h3>
              <p className="text-sm text-muted-foreground">
                A process is a lightweight isolated unit with its own state. A supervisor manages process lifecycles.
              </p>
            </div>
          </motion.div>

          {/* Steps */}
          <div className="space-y-12">
            {steps.map((step, index) => (
              <motion.div
                key={step.number}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: index * 0.1 }}
                viewport={{ once: true }}
                className="relative"
              >
                {/* Step number */}
                <div className="flex items-center gap-4 mb-4">
                  <div className="h-10 w-10 rounded-full bg-primary/20 flex items-center justify-center font-bold text-primary">
                    {step.number}
                  </div>
                  <h2 className="text-xl font-semibold">{step.title}</h2>
                </div>

                {/* Code block */}
                <CodeBlock code={step.code} language="elixir" />
                
                {/* Note */}
                {step.note && (
                  <p className="mt-3 text-sm text-muted-foreground italic">
                    Note: {step.note}
                  </p>
                )}
              </motion.div>
            ))}
          </div>

          {/* Next steps */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            viewport={{ once: true }}
            className="mt-16 text-center"
          >
            <h2 className="text-2xl font-bold mb-6">Next Steps</h2>
            <div className="flex flex-wrap justify-center gap-4">
              <Button variant="outline" asChild>
                <Link to="/examples">
                  See full examples
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
              <Button variant="outline" asChild>
                <Link to="/ecosystem">
                  Understand the ecosystem
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
              <Button variant="outline" asChild>
                <a href="https://hexdocs.pm/jido" target="_blank" rel="noopener noreferrer">
                  API Reference
                  <ExternalLink className="ml-2 h-4 w-4" />
                </a>
              </Button>
            </div>
          </motion.div>
        </div>
      </section>
    </Layout>
  );
}
