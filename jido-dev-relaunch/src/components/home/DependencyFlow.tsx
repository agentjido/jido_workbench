import { motion } from "framer-motion";

const diagram = `                                    ┌─────────────┐
                                    │ jido_coder  │  ← AI coding workflows
                                    └──────┬──────┘
                                           │
                                    ┌──────┴──────┐
                                    │   jido_ai   │  ← LLM-powered agents
                                    └──────┬──────┘
                           ┌───────────────┼───────────────┐
                           │               │               │
                    ┌──────┴──────┐ ┌──────┴──────┐ ┌──────┴──────┐
                    │    jido     │ │ jido_action │ │ jido_signal │
                    └──────┬──────┘ └─────────────┘ └─────────────┘
                           │
              ┌────────────┴────────────┐
              │                         │
       ┌──────┴──────┐          ┌───────┴───────┐
       │   req_llm   │          │     llmdb     │
       └─────────────┘          └───────────────┘`;

export function DependencyFlow() {
  return (
    <motion.section
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      viewport={{ once: true }}
      className="mb-16"
    >
      <div className="code-block overflow-hidden">
        <div className="code-header">
          <span className="text-muted-foreground text-xs">
            <span className="text-accent-yellow">#</span> dependency flow
          </span>
          <span className="text-muted-foreground text-[10px]">packages compose bottom-up</span>
        </div>
        <div className="p-6 overflow-x-auto">
          <pre className="text-[11px] leading-relaxed whitespace-pre">
            {diagram.split('\n').map((line, i) => (
              <div key={i}>
                {line
                  .replace(/jido_coder/g, '%%%JIDOCODER%%%')
                  .replace(/jido_ai/g, '%%%JIDOAI%%%')
                  .replace(/jido_action/g, '%%%JIDOACTION%%%')
                  .replace(/jido_signal/g, '%%%JIDOSIGNAL%%%')
                  .replace(/jido/g, '%%%JIDO%%%')
                  .replace(/req_llm/g, '%%%REQLLM%%%')
                  .replace(/llmdb/g, '%%%LLMDB%%%')
                  .split(/(%%%[A-Z]+%%%)/g)
                  .map((part, j) => {
                    if (part === '%%%JIDOCODER%%%') return <span key={j} className="text-accent-red">jido_coder</span>;
                    if (part === '%%%JIDOAI%%%') return <span key={j} className="text-accent-yellow">jido_ai</span>;
                    if (part === '%%%JIDOACTION%%%') return <span key={j} className="text-accent-green">jido_action</span>;
                    if (part === '%%%JIDOSIGNAL%%%') return <span key={j} className="text-accent-green">jido_signal</span>;
                    if (part === '%%%JIDO%%%') return <span key={j} className="text-accent-green">jido</span>;
                    if (part === '%%%REQLLM%%%') return <span key={j} className="text-accent-cyan">req_llm</span>;
                    if (part === '%%%LLMDB%%%') return <span key={j} className="text-accent-cyan">llmdb</span>;
                    return part;
                  })}
              </div>
            ))}
          </pre>
        </div>
      </div>
    </motion.section>
  );
}
