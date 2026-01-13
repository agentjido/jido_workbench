import { Link } from "react-router-dom";
import { ChevronLeft, ChevronRight } from "lucide-react";

interface DocsPrevNextProps {
  prev?: { title: string; href: string };
  next?: { title: string; href: string };
}

export function DocsPrevNext({ prev, next }: DocsPrevNextProps) {
  if (!prev && !next) return null;

  return (
    <div className="flex gap-4 mt-12 pt-8 border-t border-border">
      {prev ? (
        <Link
          to={prev.href}
          className="flex-1 group rounded-lg border border-border bg-card/50 p-4 hover:border-primary/50 hover:bg-card transition-colors"
        >
          <div className="flex items-center gap-1 text-sm text-muted-foreground mb-1">
            <ChevronLeft className="h-3 w-3" />
            <span>Previous</span>
          </div>
          <div className="font-medium text-foreground group-hover:text-primary transition-colors">
            {prev.title}
          </div>
        </Link>
      ) : (
        <div className="flex-1" />
      )}
      
      {next ? (
        <Link
          to={next.href}
          className="flex-1 group rounded-lg border border-border bg-card/50 p-4 hover:border-primary/50 hover:bg-card transition-colors text-right"
        >
          <div className="flex items-center justify-end gap-1 text-sm text-muted-foreground mb-1">
            <span>Next</span>
            <ChevronRight className="h-3 w-3" />
          </div>
          <div className="font-medium text-foreground group-hover:text-primary transition-colors">
            {next.title}
          </div>
        </Link>
      ) : (
        <div className="flex-1" />
      )}
    </div>
  );
}