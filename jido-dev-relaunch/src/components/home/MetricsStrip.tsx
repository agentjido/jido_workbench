import { motion } from "framer-motion";

const metrics = [
  { value: "10,000+", label: "agents/node", colorClass: "text-accent-green" },
  { value: "~200MB", label: "RAM @ 5k agents", colorClass: "text-accent-yellow" },
  { value: "<1ms", label: "message latency", colorClass: "text-accent-cyan" },
  { value: "7", label: "packages", colorClass: "text-accent-red" },
];

export function MetricsStrip() {
  return (
    <motion.section
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: 0.4 }}
      className="mb-16"
    >
      <div className="grid grid-cols-4 gap-px bg-border rounded-md overflow-hidden max-w-[700px] mx-auto">
        {metrics.map((metric, i) => (
          <div key={i} className="metric-card">
            <div className={`text-xl sm:text-[22px] font-bold ${metric.colorClass}`}>
              {metric.value}
            </div>
            <div className="text-[10px] text-muted-foreground uppercase tracking-wider mt-1.5">
              {metric.label}
            </div>
          </div>
        ))}
      </div>
    </motion.section>
  );
}
