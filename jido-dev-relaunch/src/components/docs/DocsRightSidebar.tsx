import { useEffect, useState } from "react";
import { cn } from "@/lib/utils";
import { ExternalLink } from "lucide-react";

interface TocItem {
  id: string;
  title: string;
  level: number;
}

interface DocsRightSidebarProps {
  tableOfContents?: TocItem[];
  githubPath?: string;
  livebookUrl?: string;
}

const quickLinks = [
  { label: "HexDocs", icon: "◇", href: "https://hexdocs.pm/jido" },
  { label: "GitHub", icon: "◈", href: "https://github.com/agentjido/jido" },
  { label: "Hex.pm", icon: "⬡", href: "https://hex.pm/packages/jido" },
];

export function DocsRightSidebar({ 
  tableOfContents = [], 
  githubPath,
  livebookUrl 
}: DocsRightSidebarProps) {
  const [activeId, setActiveId] = useState<string>("");

  useEffect(() => {
    if (tableOfContents.length === 0) return;

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            setActiveId(entry.target.id);
          }
        });
      },
      { rootMargin: "-100px 0px -80% 0px" }
    );

    tableOfContents.forEach((item) => {
      const element = document.getElementById(item.id);
      if (element) observer.observe(element);
    });

    return () => observer.disconnect();
  }, [tableOfContents]);

  return (
    <aside className={cn(
      "hidden xl:block w-[200px] shrink-0",
      "sticky top-[105px] h-[calc(100vh-105px)]",
      "py-12 px-5 overflow-y-auto"
    )}>
      {/* On This Page */}
      {tableOfContents.length > 0 && (
        <div className="mb-8">
          <div className={cn(
            "text-[10px] font-bold tracking-[0.1em] uppercase",
            "text-muted-foreground mb-4"
          )}>
            ON THIS PAGE
          </div>
          <nav className="space-y-0">
            {tableOfContents.map((item, i) => (
              <a
                key={item.id}
                href={`#${item.id}`}
                className={cn(
                  "block text-[11px] py-1.5 transition-colors",
                  "border-l-2 pl-3 -ml-px",
                  activeId === item.id
                    ? "text-primary border-l-primary"
                    : "text-muted-foreground border-l-transparent hover:text-foreground"
                )}
              >
                {item.title}
              </a>
            ))}
          </nav>
        </div>
      )}

      {/* Quick Links */}
      <div className={cn(
        "p-4 rounded-md",
        "bg-card border border-border"
      )}>
        <div className={cn(
          "text-[10px] font-semibold",
          "text-muted-foreground mb-2"
        )}>
          QUICK LINKS
        </div>
        <div className="flex flex-col gap-2">
          {quickLinks.map((link, i) => (
            <a
              key={i}
              href={link.href}
              target="_blank"
              rel="noopener noreferrer"
              className={cn(
                "text-[11px] text-muted-foreground",
                "flex items-center gap-1.5",
                "hover:text-primary transition-colors"
              )}
            >
              <span>{link.icon}</span>
              <span>{link.label}</span>
            </a>
          ))}
        </div>
      </div>

      {/* Edit link */}
      {githubPath && (
        <a
          href={`https://github.com/agentjido/jido/edit/main/${githubPath}`}
          target="_blank"
          rel="noopener noreferrer"
          className={cn(
            "mt-8 block text-[11px] text-muted-foreground",
            "hover:text-foreground transition-colors",
            "flex items-center gap-1"
          )}
        >
          Edit this page
          <ExternalLink className="h-3 w-3" />
        </a>
      )}
    </aside>
  );
}
