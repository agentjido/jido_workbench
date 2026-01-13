import { motion } from "framer-motion";

const features = [
  {
    icon: "◉",
    title: "Isolated Processes",
    desc: "Each agent runs in its own BEAM process with isolated state. No shared memory, no locks.",
    colorClass: "text-accent-green",
  },
  {
    icon: "⟳",
    title: "OTP Supervision",
    desc: "When agents crash, supervisors restart them in milliseconds. No external orchestrator needed.",
    colorClass: "text-accent-yellow",
  },
  {
    icon: "⚡",
    title: "Native Concurrency",
    desc: "Preemptive scheduler handles 10k+ agents per node. True parallelism on multi-core.",
    colorClass: "text-accent-cyan",
  },
];

export function WhyBeamSection() {
  return (
    <motion.section
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      viewport={{ once: true }}
      className="mb-16"
    >
      <div className="text-center mb-8">
        <span className="font-bold text-sm tracking-wider">WHY BEAM-NATIVE?</span>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {features.map((feature, i) => (
          <motion.div
            key={feature.title}
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4, delay: i * 0.1 }}
            viewport={{ once: true }}
            className="feature-card text-center"
          >
            <div className={`text-2xl mb-4 ${feature.colorClass}`}>{feature.icon}</div>
            <div className="font-bold text-[13px] mb-2">{feature.title}</div>
            <p className="text-muted-foreground text-xs leading-relaxed">{feature.desc}</p>
          </motion.div>
        ))}
      </div>
    </motion.section>
  );
}
