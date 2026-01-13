import { motion } from "framer-motion";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";

export function HeroSection() {
  return (
    <section className="text-center mb-16">
      {/* Badge */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5 }}
        className="inline-block bg-primary/10 border border-primary/30 px-4 py-2 rounded mb-6"
      >
        <span className="text-primary text-[11px] font-semibold tracking-widest">
          BEAM-NATIVE AGENT ECOSYSTEM
        </span>
      </motion.div>

      {/* Headline */}
      <motion.h1
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.1 }}
        className="text-4xl sm:text-[42px] font-bold leading-tight mb-5 tracking-tight"
      >
        From <span className="text-accent-cyan">LLM calls</span> to
        <br />
        <span className="text-primary">autonomous agents</span>
      </motion.h1>

      {/* Subheadline */}
      <motion.p
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.2 }}
        className="text-secondary-foreground text-[15px] leading-relaxed mb-8 max-w-lg mx-auto"
      >
        7 composable packages. One unified stack.
        <br />
        Run 10,000+ agents on a single BEAM node.
      </motion.p>

      {/* CTAs */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, delay: 0.3 }}
        className="flex gap-3 justify-center mb-12"
      >
        <Button asChild className="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-5">
          <Link to="/ecosystem">EXPLORE ECOSYSTEM →</Link>
        </Button>
        <Button 
          variant="outline" 
          asChild 
          className="border-2 border-accent-yellow text-accent-yellow hover:bg-accent-yellow/10 text-[13px] font-semibold px-6 py-5"
        >
          <Link to="/benchmarks">VIEW BENCHMARKS</Link>
        </Button>
      </motion.div>
    </section>
  );
}
