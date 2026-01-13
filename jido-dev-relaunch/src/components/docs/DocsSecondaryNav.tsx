import { Link, useLocation } from "react-router-dom";
import { cn } from "@/lib/utils";

interface TabItem {
  label: string;
  href: string;
  hasDropdown?: boolean;
}

const tabs: TabItem[] = [
  { label: "Get started", href: "/docs" },
  { label: "Packages", href: "/docs/packages/jido", hasDropdown: true },
  { label: "Agents", href: "/docs/agents/defining", hasDropdown: true },
  { label: "Actions", href: "/docs/actions/schemas", hasDropdown: true },
  { label: "AI & LLMs", href: "/docs/ai/llm-config", hasDropdown: true },
  { label: "Production", href: "/docs/production/deployment", hasDropdown: true },
  { label: "Reference", href: "/docs/reference/cli" },
];

export function DocsSecondaryNav() {
  const location = useLocation();
  
  const isTabActive = (tab: TabItem) => {
    if (tab.label === "Get started") {
      return location.pathname === "/docs" || 
             location.pathname === "/docs/installation" ||
             location.pathname === "/docs/quickstart" ||
             location.pathname === "/docs/concepts" ||
             location.pathname === "/docs/production-checklist";
    }
    if (tab.label === "Packages") {
      return location.pathname.startsWith("/docs/packages");
    }
    if (tab.label === "Agents") {
      return location.pathname.startsWith("/docs/agents");
    }
    if (tab.label === "Actions") {
      return location.pathname.startsWith("/docs/actions") || 
             location.pathname.startsWith("/docs/signals");
    }
    if (tab.label === "AI & LLMs") {
      return location.pathname.startsWith("/docs/ai");
    }
    if (tab.label === "Production") {
      return location.pathname.startsWith("/docs/production");
    }
    if (tab.label === "Reference") {
      return location.pathname.startsWith("/docs/reference");
    }
    return false;
  };

  return (
    <div className={cn(
      "border-b border-border bg-card/50",
      "px-6 overflow-x-auto"
    )}>
      <nav className="flex items-center gap-1">
        {tabs.map((tab) => {
          const isActive = isTabActive(tab);
          return (
            <Link
              key={tab.label}
              to={tab.href}
              className={cn(
                "flex items-center gap-1 px-4 py-3",
                "text-[13px] whitespace-nowrap transition-colors",
                "border-b-2 -mb-[1px]",
                isActive
                  ? "text-foreground font-medium border-b-primary"
                  : "text-muted-foreground border-b-transparent hover:text-foreground hover:border-b-border"
              )}
            >
              {tab.label}
              {tab.hasDropdown && (
                <svg 
                  className="w-3 h-3 opacity-50" 
                  fill="none" 
                  viewBox="0 0 24 24" 
                  stroke="currentColor"
                >
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              )}
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
