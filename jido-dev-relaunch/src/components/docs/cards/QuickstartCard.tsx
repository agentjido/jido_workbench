import { Link } from "react-router-dom";
import { cn } from "@/lib/utils";

type ColorVariant = "green" | "yellow" | "cyan" | "red";

interface QuickstartCardProps {
  icon: string;
  title: string;
  description: string;
  color: ColorVariant;
  href?: string;
}

const colorClasses: Record<ColorVariant, string> = {
  green: "text-accent-green",
  yellow: "text-accent-yellow",
  cyan: "text-accent-cyan",
  red: "text-accent-red",
};

const bgClasses: Record<ColorVariant, string> = {
  green: "bg-accent-green/15",
  yellow: "bg-accent-yellow/15",
  cyan: "bg-accent-cyan/15",
  red: "bg-accent-red/15",
};

const borderClasses: Record<ColorVariant, string> = {
  green: "hover:border-accent-green",
  yellow: "hover:border-accent-yellow",
  cyan: "hover:border-accent-cyan",
  red: "hover:border-accent-red",
};

export function QuickstartCard({ icon, title, description, color, href = "#" }: QuickstartCardProps) {
  const content = (
    <div className={cn(
      "bg-card border border-border rounded-md p-4",
      "flex items-center gap-3",
      "transition-all duration-200 cursor-pointer",
      borderClasses[color]
    )}>
      <div className={cn(
        "w-9 h-9 rounded-md flex-shrink-0",
        "flex items-center justify-center text-xl",
        bgClasses[color],
        colorClasses[color]
      )}>
        {icon}
      </div>
      <div>
        <div className="text-[13px] font-semibold text-foreground">
          {title}
        </div>
        <p className="text-[11px] text-muted-foreground">
          {description}
        </p>
      </div>
    </div>
  );

  if (href.startsWith("http")) {
    return (
      <a href={href} target="_blank" rel="noopener noreferrer" className="block">
        {content}
      </a>
    );
  }

  return (
    <Link to={href} className="block">
      {content}
    </Link>
  );
}
