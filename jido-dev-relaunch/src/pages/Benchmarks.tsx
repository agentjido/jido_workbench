import { motion } from "framer-motion";
import { Layout } from "@/components/layout/Layout";
import { CodeBlock } from "@/components/ui/code-block";
import { ExternalLink, Github, Play, Server, Cpu, Gauge } from "lucide-react";
import { Button } from "@/components/ui/button";

const singleNodeBenchmarks = [
  { agents: "1,000", memory: "40MB", cpu: "5%", env: "2-core, 4GB" },
  { agents: "5,000", memory: "180MB", cpu: "12%", env: "2-core, 4GB" },
  { agents: "10,000", memory: "350MB", cpu: "22%", env: "4-core, 8GB" },
];

const multiNodeMetrics = [
  { label: "Failover time when node dies", value: "< 2s" },
  { label: "Throughput impact during outage", value: "33% (1 of 3 nodes)" },
  { label: "Agent redistribution time", value: "< 5s" },
];

const experiments = [
  {
    title: "Random agent crashes",
    description: "Crash 10% of agents randomly per second",
    result: "Supervisor restarts isolated to crashed agents",
    impact: "No cascade failures, 99.9% uptime for healthy agents",
  },
  {
    title: "Thundering herd",
    description: "5,000 agents all request external API simultaneously",
    result: "Back-pressure via mailbox monitoring",
    impact: "Graceful degradation, no OOM",
  },
];

const runBenchmarkCode = `git clone https://github.com/agentjido/benchmarks
cd benchmarks
mix deps.get
mix run bench/single_node.exs`;

export default function Benchmarks() {
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
              Benchmarks & <span className="gradient-text">Proof</span>
            </h1>
            <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
              Claims about concurrency and resilience are cheap; these are the numbers Jido actually hits on real hardware.
            </p>
          </motion.div>

          {/* Summary metrics */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5, delay: 0.1 }}
            className="bg-card border border-primary/30 rounded-xl p-8 mb-16"
          >
            <div className="grid sm:grid-cols-3 gap-8 text-center">
              <div>
                <Server className="h-8 w-8 mx-auto mb-3 text-primary" />
                <div className="text-3xl font-bold font-mono text-primary">10,000</div>
                <div className="text-sm text-muted-foreground">agents on 2-core, 4GB VM</div>
              </div>
              <div>
                <Gauge className="h-8 w-8 mx-auto mb-3 text-accent" />
                <div className="text-3xl font-bold font-mono text-accent">&lt; 1ms</div>
                <div className="text-sm text-muted-foreground">median message latency</div>
              </div>
              <div>
                <Cpu className="h-8 w-8 mx-auto mb-3 text-primary" />
                <div className="text-3xl font-bold font-mono text-primary">~20KB</div>
                <div className="text-sm text-muted-foreground">memory per idle agent</div>
              </div>
            </div>
          </motion.div>

          {/* Single-node benchmarks */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            viewport={{ once: true }}
            className="mb-16"
          >
            <h2 className="text-2xl font-bold mb-6">Single-Node Benchmarks</h2>
            <div className="bg-card border border-border rounded-xl overflow-hidden">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-border bg-secondary/30">
                    <th className="text-left p-4 font-medium">Agents</th>
                    <th className="text-left p-4 font-medium">Memory</th>
                    <th className="text-left p-4 font-medium">CPU</th>
                    <th className="text-left p-4 font-medium hidden sm:table-cell">Environment</th>
                  </tr>
                </thead>
                <tbody>
                  {singleNodeBenchmarks.map((row, index) => (
                    <tr key={index} className="border-b border-border last:border-b-0">
                      <td className="p-4 font-mono text-primary">{row.agents}</td>
                      <td className="p-4 font-mono text-accent">{row.memory}</td>
                      <td className="p-4 font-mono">{row.cpu}</td>
                      <td className="p-4 text-muted-foreground hidden sm:table-cell">{row.env}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <p className="text-sm text-muted-foreground mt-4">
              <strong>Test scenario:</strong> Agent behavior is a simple state machine with periodic work. 
              Measurement via <code className="text-accent">:observer</code> and telemetry aggregation over 10-minute sustained load.
            </p>
          </motion.div>

          {/* Multi-node scenarios */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            viewport={{ once: true }}
            className="mb-16"
          >
            <h2 className="text-2xl font-bold mb-6">Multi-Node Scenarios</h2>
            <div className="grid sm:grid-cols-3 gap-4">
              {multiNodeMetrics.map((metric) => (
                <div key={metric.label} className="feature-card text-center">
                  <div className="text-2xl font-bold font-mono text-primary mb-2">
                    {metric.value}
                  </div>
                  <div className="text-sm text-muted-foreground">{metric.label}</div>
                </div>
              ))}
            </div>
          </motion.div>

          {/* Failure experiments */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            viewport={{ once: true }}
            className="mb-16"
          >
            <h2 className="text-2xl font-bold mb-6">Failure Behavior Experiments</h2>
            <div className="grid md:grid-cols-2 gap-6">
              {experiments.map((exp) => (
                <div key={exp.title} className="feature-card">
                  <h3 className="font-semibold mb-2">{exp.title}</h3>
                  <p className="text-sm text-muted-foreground mb-3">{exp.description}</p>
                  <div className="space-y-2 text-sm">
                    <p>
                      <span className="text-primary">Result:</span>{" "}
                      <span className="text-muted-foreground">{exp.result}</span>
                    </p>
                    <p>
                      <span className="text-accent">Impact:</span>{" "}
                      <span className="text-muted-foreground">{exp.impact}</span>
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </motion.div>

          {/* Reproduce */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            viewport={{ once: true }}
            className="mb-16"
          >
            <h2 className="text-2xl font-bold mb-6">Reproduce the Benchmarks</h2>
            <CodeBlock code={runBenchmarkCode} language="bash" />
            <p className="text-sm text-muted-foreground mt-4 italic">
              We expect developers to rerun and verify these numbers on their own hardware.
            </p>
          </motion.div>

          {/* Videos CTA */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
            viewport={{ once: true }}
            className="text-center"
          >
            <h2 className="text-2xl font-bold mb-6">See it in Action</h2>
            <div className="flex flex-wrap justify-center gap-4">
              <Button variant="outline" asChild>
                <a href="#" target="_blank" rel="noopener noreferrer">
                  <Play className="mr-2 h-4 w-4" />
                  10,000 agents with Observer
                </a>
              </Button>
              <Button variant="outline" asChild>
                <a href="#" target="_blank" rel="noopener noreferrer">
                  <Play className="mr-2 h-4 w-4" />
                  Node failover in real-time
                </a>
              </Button>
              <Button variant="outline" asChild>
                <a href="https://github.com/agentjido/benchmarks" target="_blank" rel="noopener noreferrer">
                  <Github className="mr-2 h-4 w-4" />
                  Benchmark repo
                </a>
              </Button>
            </div>
          </motion.div>
        </div>
      </section>
    </Layout>
  );
}
