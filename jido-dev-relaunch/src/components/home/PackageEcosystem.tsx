import { motion } from "framer-motion";
import { Link } from "react-router-dom";

const packages = {
  app: [
    {
      name: "jido_coder",
      desc: "AI coding agent with file operations, git integration, and test execution",
      type: "app",
    },
  ],
  ai: [
    {
      name: "jido_ai",
      desc: "LLM-powered agents with token/cost tracking, tool calling, and streaming. Combines jido + req_llm + llmdb.",
      type: "ai",
    },
    {
      name: "jido_behaviortree",
      desc: "Behavior tree execution for complex agent decision-making. Composable nodes, conditions, and actions.",
      type: "ai",
    },
  ],
  core: [
    {
      name: "jido",
      desc: "BEAM-native bot framework. OTP supervision, isolated processes, 10k+ agents per node.",
      type: "core",
    },
    {
      name: "jido_action",
      desc: "Schema-based action validation. Required fields, defaults, type constraints.",
      type: "core",
    },
    {
      name: "jido_signal",
      desc: "Pub/sub signaling between agents. Decoupled coordination via message-passing.",
      type: "core",
    },
  ],
  foundation: [
    {
      name: "req_llm",
      desc: "HTTP client for LLM APIs. Built on Req with retries, rate limiting, and streaming support.",
      type: "foundation",
    },
    {
      name: "llmdb",
      desc: "Model registry and metadata. Token limits, pricing, capabilities for all major providers.",
      type: "foundation",
    },
  ],
};

const PackageCard = ({ pkg, className }: { pkg: typeof packages.core[0]; className: string }) => (
  <div className={className}>
    <div className="flex justify-between items-start mb-3">
      <span className="font-bold text-sm">{pkg.name}</span>
      <span className={`badge-${pkg.type}`}>{pkg.type.toUpperCase()}</span>
    </div>
    <p className="text-muted-foreground text-xs leading-relaxed">{pkg.desc}</p>
    <div className="flex gap-2 mt-4">
      {["hex", "docs", "github"].map((link) => (
        <span
          key={link}
          className="text-[10px] text-secondary-foreground px-2 py-1 bg-elevated rounded cursor-pointer hover:text-foreground transition-colors"
        >
          {link}
        </span>
      ))}
    </div>
  </div>
);

export function PackageEcosystem() {
  return (
    <motion.section
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      viewport={{ once: true }}
      className="mb-16"
    >
      {/* Header */}
      <div className="flex justify-between items-center mb-6">
        <div>
          <span className="font-bold text-sm tracking-wider">PACKAGE ECOSYSTEM</span>
          <span className="text-muted-foreground text-xs ml-4">4 layers • composable by design</span>
        </div>
        <Link to="/ecosystem" className="text-primary text-xs hover:underline">
          view all →
        </Link>
      </div>

      {/* Row 1: App + AI */}
      <div className="grid grid-cols-1 md:grid-cols-[1fr_2fr] gap-3 mb-3">
        {packages.app.map((pkg) => (
          <PackageCard key={pkg.name} pkg={pkg} className="package-card-app" />
        ))}
        {packages.ai.map((pkg) => (
          <PackageCard key={pkg.name} pkg={pkg} className="package-card-ai" />
        ))}
      </div>

      {/* Row 2: Core */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
        {packages.core.map((pkg) => (
          <PackageCard key={pkg.name} pkg={pkg} className="package-card-core" />
        ))}
      </div>

      {/* Row 3: Foundation */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        {packages.foundation.map((pkg) => (
          <PackageCard key={pkg.name} pkg={pkg} className="package-card-foundation" />
        ))}
      </div>
    </motion.section>
  );
}
