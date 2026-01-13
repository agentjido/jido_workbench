import { Link, useLocation } from "react-router-dom";
import { cn } from "@/lib/utils";
import { Command, Sparkles } from "lucide-react";

const navItems = [
  { label: "docs", href: "/docs" },
  { label: "examples", href: "/examples" },
  { label: "benchmarks", href: "/benchmarks" },
  { label: "ecosystem", href: "/ecosystem" },
];

export function DocsHeader() {
  const location = useLocation();

  return (
    <nav className={cn(
      "flex items-center justify-between",
      "px-6 py-4",
      "bg-card border-b border-border",
      "sticky top-0 z-50"
    )}>
      {/* Left: Logo + Nav */}
      <div className="flex items-center gap-6">
        <Link to="/" className="flex items-center gap-2.5">
          <div className={cn(
            "w-7 h-7 rounded-[5px]",
            "bg-gradient-to-br from-primary to-accent-yellow",
            "flex items-center justify-center",
            "text-sm font-bold text-background"
          )}>
            J
          </div>
          <span className="font-bold text-base tracking-wide text-foreground">JIDO</span>
          <span className={cn(
            "text-[11px] text-muted-foreground px-2 py-0.5",
            "bg-elevated rounded"
          )}>
            Docs
          </span>
        </Link>

        <div className="hidden md:flex items-center gap-5">
          {navItems.map((item) => {
            const isActive = location.pathname.startsWith(item.href);
            return (
              <Link
                key={item.label}
                to={item.href}
                className={cn(
                  "text-xs transition-colors",
                  isActive 
                    ? "text-primary font-semibold" 
                    : "text-muted-foreground hover:text-foreground"
                )}
              >
                /{item.label}
              </Link>
            );
          })}
        </div>
      </div>

      {/* Right: Search + Ask AI */}
      <div className="flex items-center gap-3">
        {/* Search Box */}
        <div className={cn(
          "hidden md:flex items-center gap-2",
          "bg-elevated border border-border rounded",
          "px-3 py-2 min-w-[200px]",
          "cursor-pointer hover:border-muted-foreground transition-colors"
        )}>
          <Command className="h-3 w-3 text-muted-foreground" />
          <span className="text-xs text-muted-foreground flex-1">Search...</span>
          <kbd className={cn(
            "text-[10px] text-muted-foreground",
            "px-1.5 py-0.5 bg-card border border-border rounded"
          )}>
            ⌘K
          </kbd>
        </div>

        {/* Ask AI Button */}
        <button className={cn(
          "hidden md:flex items-center gap-2",
          "bg-primary/10 border border-primary/30 rounded",
          "px-3 py-2",
          "text-xs text-primary font-medium",
          "hover:bg-primary/20 transition-colors"
        )}>
          <Sparkles className="h-3 w-3" />
          Ask AI
        </button>

        <a 
          href="https://github.com/agentjido/jido" 
          target="_blank" 
          rel="noopener noreferrer"
          className="text-xs text-muted-foreground hover:text-foreground transition-colors"
        >
          GitHub
        </a>
        <a 
          href="https://hex.pm/packages/jido" 
          target="_blank" 
          rel="noopener noreferrer"
          className="text-xs text-muted-foreground hover:text-foreground transition-colors"
        >
          Hex
        </a>
      </div>
    </nav>
  );
}
