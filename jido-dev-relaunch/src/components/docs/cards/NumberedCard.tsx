import { Link } from "react-router-dom";
import { cn } from "@/lib/utils";

interface NumberedCardProps {
  number: string;
  title: string;
  description: string;
  href: string;
}

export function NumberedCard({ number, title, description, href }: NumberedCardProps) {
  return (
    <Link to={href} className="block group">
      <div className={cn(
        "bg-card border border-border rounded-md p-5",
        "flex gap-4 items-start",
        "transition-all duration-200",
        "hover:border-primary hover:-translate-y-0.5"
      )}>
        <div className={cn(
          "w-8 h-8 rounded-md flex-shrink-0",
          "flex items-center justify-center",
          "bg-primary/15 text-primary",
          "font-bold text-sm"
        )}>
          {number}
        </div>
        <div>
          <div className="text-sm font-semibold text-foreground mb-1 group-hover:text-primary transition-colors">
            {title}
          </div>
          <p className="text-xs text-muted-foreground leading-relaxed">
            {description}
          </p>
        </div>
      </div>
    </Link>
  );
}
