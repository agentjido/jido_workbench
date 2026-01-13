import { useState } from "react";
import { motion } from "framer-motion";

const tabs = [
  { id: "full", label: "FULL AI STACK" },
  { id: "bots", label: "BOTS ONLY" },
  { id: "custom", label: "CUSTOM" },
];

const codeBlocks = {
  full: {
    comment: "# Full stack: AI coding agents",
    deps: [{ name: ":jido_coder", version: '"~> 0.1.0"', note: "" }],
    note: "# includes jido_ai, jido, req_llm, llmdb",
  },
  bots: {
    comment: "# Bots only: no LLM dependencies",
    deps: [{ name: ":jido", version: '"~> 0.1.0"', note: "" }],
    note: "# pure bot framework, OTP supervision",
  },
  custom: {
    comment: "# Custom: mix and match",
    deps: [
      { name: ":jido", version: '"~> 0.1.0"', note: "# bot framework" },
      { name: ":jido_action", version: '"~> 0.1.0"', note: "# validation" },
      { name: ":req_llm", version: '"~> 0.1.0"', note: "# LLM client" },
    ],
    note: "",
  },
};

export function InstallSection() {
  const [activeTab, setActiveTab] = useState<"full" | "bots" | "custom">("full");
  const config = codeBlocks[activeTab];

  const copyCode = () => {
    const code = `def deps do\n  [\n${config.deps.map(d => `    {${d.name}, ${d.version}}`).join(',\n')}\n  ]\nend`;
    navigator.clipboard.writeText(code);
  };

  return (
    <motion.section
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      viewport={{ once: true }}
      className="mb-16"
    >
      <div className="mb-5">
        <span className="font-bold text-sm tracking-wider">CHOOSE YOUR STACK</span>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 mb-4">
        {tabs.map((tab) => (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id as typeof activeTab)}
            className={`px-5 py-2.5 rounded text-[11px] font-semibold transition-colors border ${
              activeTab === tab.id
                ? "border-primary bg-primary/10 text-primary"
                : "border-border text-secondary-foreground hover:text-foreground"
            }`}
          >
            {tab.label}
          </button>
        ))}
      </div>

      {/* Code Block */}
      <div className="code-block overflow-hidden">
        <div className="code-header">
          <span className="text-muted-foreground text-xs">mix.exs</span>
          <button
            onClick={copyCode}
            className="bg-surface border border-border text-secondary-foreground px-3 py-1 rounded text-[10px] hover:text-foreground transition-colors"
          >
            COPY
          </button>
        </div>
        <div className="p-5">
          <pre className="text-[13px] leading-relaxed">
            <span className="syntax-comment">{config.comment}</span>{"\n"}
            <span className="syntax-keyword">def</span>{" "}
            <span className="syntax-function">deps</span>{" "}
            <span className="syntax-keyword">do</span>{"\n"}
            {"  "}[{"\n"}
            {config.deps.map((dep, i) => (
              <span key={i}>
                {"    "}{"{"}
                <span className="syntax-keyword">{dep.name}</span>
                {", "}
                <span className="syntax-string">{dep.version}</span>
                {"}"}{i < config.deps.length - 1 ? "," : ""}
                {dep.note && (
                  <span className="syntax-comment"> {dep.note}</span>
                )}
                {"\n"}
              </span>
            ))}
            {config.note && !config.deps.some(d => d.note) && (
              <>{"    "}<span className="syntax-comment">{config.note}</span>{"\n"}</>
            )}
            {"  "}]{"\n"}
            <span className="syntax-keyword">end</span>
          </pre>
        </div>
      </div>
    </motion.section>
  );
}
