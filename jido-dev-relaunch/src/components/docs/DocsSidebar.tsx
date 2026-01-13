import { useState } from "react";
import { Link, useLocation } from "react-router-dom";
import { cn } from "@/lib/utils";
import { ChevronLeft, ChevronDown, ChevronRight, Home } from "lucide-react";

interface NavItem {
  label: string;
  href?: string;
  badge?: "CORE" | "AI" | "APP" | "FOUNDATION";
}

interface NavSection {
  title: string;
  items: NavItem[];
  defaultOpen?: boolean;
}

const sidebarNav: NavSection[] = [
  {
    title: "Getting Started",
    defaultOpen: true,
    items: [
      { label: "Introduction", href: "/docs" },
      { label: "Installation", href: "/docs/installation" },
      { label: "Quick Start", href: "/docs/quickstart" },
      { label: "Core Concepts", href: "/docs/concepts" },
      { label: "Production Checklist", href: "/docs/production-checklist" },
    ],
  },
  {
    title: "Packages",
    items: [
      { label: "jido", href: "/docs/packages/jido", badge: "CORE" },
      { label: "jido_action", href: "/docs/packages/jido-action" },
      { label: "jido_signal", href: "/docs/packages/jido-signal" },
      { label: "req_llm", href: "/docs/packages/req-llm", badge: "FOUNDATION" },
      { label: "llmdb", href: "/docs/packages/llmdb", badge: "FOUNDATION" },
      { label: "jido_ai", href: "/docs/packages/jido-ai", badge: "AI" },
      { label: "jido_coder", href: "/docs/packages/jido-coder", badge: "APP" },
    ],
  },
  {
    title: "Agents",
    items: [
      { label: "Defining Agents", href: "/docs/agents/defining" },
      { label: "Agent Lifecycle", href: "/docs/agents/lifecycle" },
      { label: "State Management", href: "/docs/agents/state" },
      { label: "Supervision Trees", href: "/docs/agents/supervision" },
      { label: "Multi-Agent Systems", href: "/docs/agents/multi-agent" },
    ],
  },
  {
    title: "Actions & Signals",
    items: [
      { label: "Action Schemas", href: "/docs/actions/schemas" },
      { label: "Validation", href: "/docs/actions/validation" },
      { label: "Signal Pub/Sub", href: "/docs/signals/pubsub" },
      { label: "Inter-Agent Comms", href: "/docs/signals/communication" },
    ],
  },
  {
    title: "AI & LLMs",
    items: [
      { label: "LLM Configuration", href: "/docs/ai/llm-config" },
      { label: "Token Budgets", href: "/docs/ai/budgets" },
      { label: "Tool Calling", href: "/docs/ai/tools" },
      { label: "Streaming", href: "/docs/ai/streaming" },
      { label: "Cost Tracking", href: "/docs/ai/costs" },
    ],
  },
  {
    title: "Production",
    items: [
      { label: "Deployment", href: "/docs/production/deployment" },
      { label: "Observability", href: "/docs/production/observability" },
      { label: "Telemetry", href: "/docs/production/telemetry" },
      { label: "Scaling", href: "/docs/production/scaling" },
      { label: "Failure Handling", href: "/docs/production/failures" },
    ],
  },
  {
    title: "Reference",
    items: [
      { label: "API Reference", href: "https://hexdocs.pm/jido" },
      { label: "CLI Commands", href: "/docs/reference/cli" },
      { label: "Configuration", href: "/docs/reference/config" },
      { label: "Benchmarks", href: "/benchmarks" },
    ],
  },
];

const badgeStyles: Record<string, string> = {
  CORE: "bg-primary/15 text-primary",
  AI: "bg-accent-yellow/15 text-accent-yellow",
  APP: "bg-accent-red/15 text-accent-red",
  FOUNDATION: "bg-accent-cyan/15 text-accent-cyan",
};

interface DocsSidebarProps {
  isCollapsed: boolean;
  onToggle: () => void;
}

export function DocsSidebar({ isCollapsed, onToggle }: DocsSidebarProps) {
  const location = useLocation();
  const [openSections, setOpenSections] = useState<Set<string>>(() => {
    const open = new Set<string>();
    sidebarNav.forEach((section) => {
      if (section.defaultOpen) {
        open.add(section.title);
      }
      // Also open section if it contains active item
      if (section.items.some(item => item.href === location.pathname)) {
        open.add(section.title);
      }
    });
    return open;
  });

  const toggleSection = (title: string) => {
    setOpenSections((prev) => {
      const next = new Set(prev);
      if (next.has(title)) {
        next.delete(title);
      } else {
        next.add(title);
      }
      return next;
    });
  };

  if (isCollapsed) {
    return (
      <aside className={cn(
        "hidden lg:flex flex-col w-[56px] shrink-0",
        "bg-card border-r border-border",
        "sticky top-[105px] h-[calc(100vh-105px)]"
      )}>
        {/* Expand button */}
        <button
          onClick={onToggle}
          className={cn(
            "m-3 p-2 rounded-md",
            "bg-elevated border border-border",
            "text-muted-foreground hover:text-foreground",
            "transition-colors"
          )}
          title="Expand sidebar"
        >
          <ChevronRight className="h-4 w-4" />
        </button>
        
        {/* Home icon */}
        <Link
          to="/docs"
          className={cn(
            "mx-3 p-2 rounded-md",
            "text-muted-foreground hover:text-primary hover:bg-primary/10",
            "transition-colors",
            location.pathname === "/docs" && "text-primary bg-primary/10"
          )}
          title="Jido Docs"
        >
          <Home className="h-4 w-4" />
        </Link>
      </aside>
    );
  }

  return (
    <aside className={cn(
      "hidden lg:block w-[260px] shrink-0",
      "bg-card border-r border-border",
      "overflow-y-auto",
      "sticky top-[105px] h-[calc(100vh-105px)]"
    )}>
      <div className="py-4">
        {/* Collapse button + Jido Docs header */}
        <div className="flex items-center justify-between px-4 mb-4">
          <Link
            to="/docs"
            className={cn(
              "flex items-center gap-2 text-sm font-medium",
              "text-primary hover:text-primary/80 transition-colors"
            )}
          >
            <Home className="h-4 w-4" />
            Jido Docs
          </Link>
          <button
            onClick={onToggle}
            className={cn(
              "p-1.5 rounded-md",
              "text-muted-foreground hover:text-foreground hover:bg-elevated",
              "transition-colors"
            )}
            title="Collapse sidebar"
          >
            <ChevronLeft className="h-4 w-4" />
          </button>
        </div>

        {sidebarNav.map((section, si) => {
          const isOpen = openSections.has(section.title);
          
          return (
            <div key={si} className="mb-2">
              {/* Section header - clickable to toggle */}
              <button
                onClick={() => toggleSection(section.title)}
                className={cn(
                  "w-full flex items-center justify-between",
                  "px-4 py-2.5",
                  "text-[12px] font-bold tracking-[0.05em] uppercase",
                  "text-foreground hover:text-primary",
                  "transition-colors"
                )}
              >
                <span>{section.title}</span>
                {isOpen ? (
                  <ChevronDown className="h-3.5 w-3.5 text-muted-foreground" />
                ) : (
                  <ChevronRight className="h-3.5 w-3.5 text-muted-foreground" />
                )}
              </button>
              
              {/* Section items */}
              {isOpen && (
                <div className="mt-1">
                  {section.items.map((item, ii) => {
                    const isExternal = item.href?.startsWith("http");
                    const isActive = !isExternal && item.href === location.pathname;
                    
                    const linkContent = (
                      <div className={cn(
                        "flex items-center justify-between",
                        "px-4 py-2 ml-2",
                        "text-[13px] transition-all duration-150",
                        "border-l-2",
                        isActive 
                          ? "border-l-primary bg-primary/5 text-primary font-medium"
                          : "border-l-border text-muted-foreground hover:text-foreground hover:bg-elevated hover:border-l-muted-foreground"
                      )}>
                        <span>{item.label}</span>
                        {item.badge && (
                          <span className={cn(
                            "text-[9px] font-semibold tracking-wide px-1.5 py-0.5 rounded",
                            badgeStyles[item.badge]
                          )}>
                            {item.badge}
                          </span>
                        )}
                      </div>
                    );

                    if (isExternal) {
                      return (
                        <a
                          key={ii}
                          href={item.href}
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          {linkContent}
                        </a>
                      );
                    }

                    return (
                      <Link key={ii} to={item.href || "#"}>
                        {linkContent}
                      </Link>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </aside>
  );
}
