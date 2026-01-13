import { useLocation, Link } from "react-router-dom";
import { cn } from "@/lib/utils";

const pathLabels: Record<string, string> = {
  "docs": "Docs",
  "installation": "Installation",
  "quickstart": "Quick Start",
  "first-agent": "First Agent",
  "agents": "Agents",
  "defining": "Defining Agents",
  "lifecycle": "Agent Lifecycle",
  "state": "State Management",
  "supervision": "Supervision Trees",
  "multi-agent": "Multi-Agent Systems",
  "actions": "Actions",
  "schemas": "Action Schemas",
  "validation": "Validation",
  "signals": "Signals",
  "pubsub": "Pub/Sub",
  "communication": "Inter-Agent Comms",
  "ai": "AI & LLMs",
  "llm-config": "LLM Configuration",
  "budgets": "Token Budgets",
  "tools": "Tool Calling",
  "streaming": "Streaming",
  "costs": "Cost Tracking",
  "production": "Production",
  "deployment": "Deployment",
  "observability": "Observability",
  "telemetry": "Telemetry",
  "scaling": "Scaling",
  "failures": "Failure Handling",
  "production-checklist": "Production Checklist",
  "concepts": "Core Concepts",
  "packages": "Packages",
  "jido": "jido",
  "jido-action": "jido_action",
  "jido-signal": "jido_signal",
  "jido-ai": "jido_ai",
  "jido-coder": "jido_coder",
  "req-llm": "req_llm",
  "llmdb": "llmdb",
  "reference": "Reference",
  "cli": "CLI Commands",
  "config": "Configuration",
};

export function DocsBreadcrumb() {
  const location = useLocation();
  const pathSegments = location.pathname.split("/").filter(Boolean);
  
  // Build breadcrumb items
  const breadcrumbItems = pathSegments.map((segment, index) => {
    const path = "/" + pathSegments.slice(0, index + 1).join("/");
    const label = pathLabels[segment] || segment.charAt(0).toUpperCase() + segment.slice(1);
    const isLast = index === pathSegments.length - 1;
    
    return { path, label, isLast };
  });

  return (
    <div className="text-xs text-muted-foreground flex items-center gap-2">
      {breadcrumbItems.map((item, index) => (
        <span key={item.path} className="flex items-center gap-2">
          {index > 0 && <span>/</span>}
          {item.isLast ? (
            <span className="text-primary">{item.label}</span>
          ) : (
            <Link 
              to={item.path}
              className="hover:text-foreground transition-colors"
            >
              {item.label}
            </Link>
          )}
        </span>
      ))}
    </div>
  );
}
