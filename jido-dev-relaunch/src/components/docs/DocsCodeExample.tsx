import { cn } from "@/lib/utils";

interface DocsCodeExampleProps {
  filename: string;
  children: React.ReactNode;
  actions?: React.ReactNode;
}

export function DocsCodeExample({ filename, children, actions }: DocsCodeExampleProps) {
  return (
    <div className={cn(
      "rounded-md border overflow-hidden",
      "bg-code-bg border-code-border"
    )}>
      <div className={cn(
        "px-5 py-3 border-b border-border",
        "bg-elevated",
        "flex items-center justify-between"
      )}>
        <span className="text-xs text-muted-foreground">{filename}</span>
        {actions || (
          <button className={cn(
            "text-[10px] font-medium",
            "px-3 py-1 rounded",
            "bg-card border border-border",
            "text-muted-foreground hover:text-foreground",
            "transition-colors"
          )}>
            COPY
          </button>
        )}
      </div>
      <div className="p-5 text-xs leading-relaxed overflow-x-auto">
        {children}
      </div>
    </div>
  );
}

// Syntax highlighting components
export function Keyword({ children }: { children: React.ReactNode }) {
  return <span className="syntax-keyword">{children}</span>;
}

export function Str({ children }: { children: React.ReactNode }) {
  return <span className="syntax-string">{children}</span>;
}

export function Func({ children }: { children: React.ReactNode }) {
  return <span className="syntax-function">{children}</span>;
}

export function Type({ children }: { children: React.ReactNode }) {
  return <span className="syntax-type">{children}</span>;
}

export function Comment({ children }: { children: React.ReactNode }) {
  return <span className="syntax-comment">{children}</span>;
}
