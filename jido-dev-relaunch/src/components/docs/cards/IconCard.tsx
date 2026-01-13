import { Link } from "react-router-dom";
import { cn } from "@/lib/utils";

type ColorVariant = "green" | "yellow" | "cyan" | "red";

interface IconCardProps {
  icon: string;
  title: string;
  description: string;
  color: ColorVariant;
  href: string;
}

const colorClasses: Record<ColorVariant, string> = {
  green: "text-accent-green",
  yellow: "text-accent-yellow",
  cyan: "text-accent-cyan",
  red: "text-accent-red",
};

const borderClasses: Record<ColorVariant, string> = {
  green: "hover:border-accent-green",
  yellow: "hover:border-accent-yellow",
  cyan: "hover:border-accent-cyan",
  red: "hover:border-accent-red",
};

export function IconCard({ icon, title, description, color, href }: IconCardProps) {
  return (
    <Link to={href} className="block group h-full">
      <div className={cn(
        "bg-card border border-border rounded-md p-5 h-full",
        "transition-all duration-200",
        "hover:-translate-y-0.5",
        borderClasses[color]
      )}>
        <div className={cn(
          "text-2xl mb-3 font-mono",
          colorClasses[color]
        )}>
          {icon}
        </div>
        <div className="text-sm font-semibold text-foreground mb-2">
          {title}
        </div>
        <p className="text-xs text-muted-foreground leading-relaxed">
          {description}
        </p>
      </div>
    </Link>
  );
}
