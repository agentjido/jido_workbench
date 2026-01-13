import { ReactNode, useState } from "react";
import { DocsSidebar } from "./DocsSidebar";
import { DocsRightSidebar } from "./DocsRightSidebar";
import { DocsHeader } from "./DocsHeader";
import { DocsSecondaryNav } from "./DocsSecondaryNav";
import { DocsBreadcrumb } from "./DocsBreadcrumb";
import { DocsPrevNext } from "./DocsPrevNext";

interface DocsLayoutProps {
  children: ReactNode;
  tableOfContents?: { id: string; title: string; level: number }[];
  githubPath?: string;
  livebookUrl?: string;
  prev?: { title: string; href: string };
  next?: { title: string; href: string };
  hideBreadcrumb?: boolean;
}

export function DocsLayout({ 
  children, 
  tableOfContents,
  githubPath = "docs/introduction.md",
  livebookUrl = "https://livebook.dev/run?url=https://github.com/agentjido/jido",
  prev,
  next,
  hideBreadcrumb = false
}: DocsLayoutProps) {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  return (
    <div className="min-h-screen bg-background flex flex-col">
      <DocsHeader />
      <DocsSecondaryNav />
      <div className="flex flex-1">
        <DocsSidebar 
          isCollapsed={sidebarCollapsed} 
          onToggle={() => setSidebarCollapsed(!sidebarCollapsed)} 
        />
        <main className="flex-1 min-w-0 flex flex-col items-center">
          <div className="flex-1 max-w-[900px] px-8 lg:px-16 py-12 w-full">
            {!hideBreadcrumb && <DocsBreadcrumb />}
            <div className={hideBreadcrumb ? "" : "mt-6"}>
              {children}
            </div>
            <DocsPrevNext prev={prev} next={next} />
          </div>
          
          {/* Simple footer */}
          <footer className="border-t border-border py-6 px-8 lg:px-16">
            <div className="flex items-center justify-between text-[11px] text-muted-foreground">
              <span>Last updated: January 2026</span>
              {githubPath && (
                <a 
                  href={`https://github.com/agentjido/jido/edit/main/${githubPath}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="hover:text-foreground transition-colors"
                >
                  Edit this page →
                </a>
              )}
            </div>
          </footer>
        </main>
        <DocsRightSidebar 
          tableOfContents={tableOfContents} 
          githubPath={githubPath}
          livebookUrl={livebookUrl}
        />
      </div>
    </div>
  );
}
