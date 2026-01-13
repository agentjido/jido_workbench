import { motion } from "framer-motion";
import { Layout } from "@/components/layout/Layout";
import { Github, BookOpen, Play, ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";

const examples = [
  {
    title: "Tool-Using Multi-Agent Research Swarm",
    scenario: "Coordinated research agents making LLM API calls with tool use",
    metrics: [
      { label: "Agents", value: "1,000" },
      { label: "Node", value: "2-core" },
      { label: "RAM", value: "180MB" },
      { label: "Latency", value: "150ms avg" },
    ],
    productionNote: "When agents fail or timeout, this supervisor restarts them with backoff and cancels in-flight API requests",
    links: {
      github: "https://github.com/agentjido/jido",
      livebook: "#",
      youtube: "#",
    },
  },
  {
    title: "Long-Lived Planning Agents",
    scenario: "Agents orchestrating multi-step workflows with persistent state",
    metrics: [
      { label: "Agents", value: "2,000" },
      { label: "Node", value: "4-core" },
      { label: "RAM", value: "220MB" },
    ],
    productionNote: "Agent state survives node restarts via ETS or external persistence",
    links: {
      github: "https://github.com/agentjido/jido",
      livebook: "#",
      youtube: "#",
    },
  },
  {
    title: "Streaming Log Processing",
    scenario: "Real-time log classification and routing",
    metrics: [
      { label: "Agents", value: "5,000" },
      { label: "Throughput", value: "10k msgs/sec" },
      { label: "Node", value: "8-core" },
    ],
    productionNote: "Back-pressure handling via mailbox monitoring",
    links: {
      github: "https://github.com/agentjido/jido",
      livebook: "#",
      youtube: "#",
    },
  },
  {
    title: "Cost-Aware LLM Agent Coordination",
    scenario: "Token-aware agents coordinating to stay within budget",
    metrics: [
      { label: "Agents", value: "500" },
      { label: "Cost", value: "$0.05/query" },
      { label: "P95", value: "< 300ms" },
    ],
    productionNote: "Per-agent token budgets prevent runaway costs",
    links: {
      github: "https://github.com/agentjido/jido",
      livebook: "#",
      youtube: "#",
    },
  },
  {
    title: "Multi-Node Deployment",
    scenario: "Agents distributed across 3 BEAM nodes",
    metrics: [
      { label: "Total Agents", value: "15,000" },
      { label: "Nodes", value: "3" },
      { label: "Failover", value: "< 2s" },
    ],
    productionNote: "When a node dies, surviving nodes detect it and supervisors redistribute agents",
    links: {
      github: "https://github.com/agentjido/jido",
      livebook: "#",
      youtube: "#",
    },
  },
];

export default function Examples() {
  return (
    <Layout>
      <section className="py-20 lg:py-32">
        <div className="container">
          {/* Hero */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            className="text-center mb-16"
          >
            <h1 className="text-4xl sm:text-5xl font-bold mb-6">
              Production <span className="gradient-text">Examples</span>
            </h1>
            <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
              These examples focus on behavior under load—agent counts, latency, memory—not toy REPL demos. All examples are real projects or Livebooks you can run.
            </p>
          </motion.div>

          {/* Examples grid */}
          <div className="space-y-8">
            {examples.map((example, index) => (
              <motion.div
                key={example.title}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4, delay: index * 0.05 }}
                viewport={{ once: true }}
                className="feature-card"
              >
                <div className="grid lg:grid-cols-3 gap-6">
                  {/* Left: Title and scenario */}
                  <div className="lg:col-span-2">
                    <h3 className="text-xl font-semibold mb-2">{example.title}</h3>
                    <p className="text-muted-foreground mb-4">{example.scenario}</p>
                    
                    {/* Metrics */}
                    <div className="flex flex-wrap gap-3 mb-4">
                      {example.metrics.map((metric) => (
                        <div key={metric.label} className="bg-secondary/50 px-3 py-1.5 rounded-lg">
                          <span className="text-xs text-muted-foreground">{metric.label}:</span>
                          <span className="ml-1 font-mono text-sm text-accent">{metric.value}</span>
                        </div>
                      ))}
                    </div>

                    {/* Production note */}
                    <p className="text-sm text-muted-foreground italic">
                      <span className="text-primary">Production note:</span> {example.productionNote}
                    </p>
                  </div>

                  {/* Right: Links */}
                  <div className="flex lg:flex-col gap-3 lg:items-end lg:justify-center">
                    <Button variant="outline" size="sm" asChild>
                      <a href={example.links.github} target="_blank" rel="noopener noreferrer">
                        <Github className="mr-2 h-4 w-4" />
                        GitHub
                      </a>
                    </Button>
                    <Button variant="outline" size="sm" asChild>
                      <a href={example.links.livebook}>
                        <BookOpen className="mr-2 h-4 w-4" />
                        Livebook
                      </a>
                    </Button>
                    <Button variant="outline" size="sm" asChild>
                      <a href={example.links.youtube}>
                        <Play className="mr-2 h-4 w-4" />
                        Demo
                      </a>
                    </Button>
                  </div>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>
    </Layout>
  );
}
