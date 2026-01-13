import { motion } from "framer-motion";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/button";

export function CTASection() {
  return (
    <motion.section
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      viewport={{ once: true }}
      className="mb-16"
    >
      <div className="cta-glow rounded-lg p-12 text-center">
        <h2 className="text-2xl font-bold mb-3">Ready to build?</h2>
        <p className="text-secondary-foreground text-sm mb-6">
          Start with the getting started guide or explore production examples.
        </p>
        <div className="flex gap-3 justify-center">
          <Button asChild className="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-7 py-5">
            <Link to="/getting-started">$ mix jido.new my_app</Link>
          </Button>
          <Button 
            variant="outline" 
            asChild 
            className="border border-accent-cyan text-accent-cyan hover:bg-accent-cyan/10 text-[13px] font-medium px-7 py-5"
          >
            <Link to="/docs">READ THE DOCS</Link>
          </Button>
        </div>
      </div>
    </motion.section>
  );
}
