import { useState, useEffect, useRef } from "react";
import { Search, File, Hash, ArrowRight, Command } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { cn } from "@/lib/utils";
import {
  Dialog,
  DialogContent,
  DialogTitle,
} from "@/components/ui/dialog";
import { VisuallyHidden } from "@radix-ui/react-visually-hidden";

interface SearchResult {
  title: string;
  section?: string;
  href: string;
  type: "page" | "heading";
}

const searchIndex: SearchResult[] = [
  { title: "Introduction", href: "/docs", type: "page" },
  { title: "What is Jido?", section: "Introduction", href: "/docs#what-is-jido", type: "heading" },
  { title: "Why BEAM?", section: "Introduction", href: "/docs#why-beam", type: "heading" },
  { title: "Key Concepts", section: "Introduction", href: "/docs#key-concepts", type: "heading" },
  { title: "Installation", href: "/docs/installation", type: "page" },
  { title: "Prerequisites", section: "Installation", href: "/docs/installation#prerequisites", type: "heading" },
  { title: "Quick Start", href: "/docs/quickstart", type: "page" },
  { title: "Agents & Processes", href: "/docs/agents", type: "page" },
  { title: "Supervision", href: "/docs/supervision", type: "page" },
  { title: "Actions", href: "/docs/actions", type: "page" },
  { title: "Signals", href: "/docs/signals", type: "page" },
  { title: "JidoAI Overview", href: "/docs/jido-ai", type: "page" },
  { title: "LLM Configuration", href: "/docs/llm-config", type: "page" },
  { title: "Tool Calling", href: "/docs/tools", type: "page" },
];

interface DocsSearchProps {
  variant?: "button" | "input";
}

export function DocsSearch({ variant = "button" }: DocsSearchProps) {
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [results, setResults] = useState<SearchResult[]>([]);
  const [selectedIndex, setSelectedIndex] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);
  const navigate = useNavigate();

  // Keyboard shortcut
  useEffect(() => {
    const down = (e: KeyboardEvent) => {
      if (e.key === "k" && (e.metaKey || e.ctrlKey)) {
        e.preventDefault();
        setOpen((open) => !open);
      }
    };

    document.addEventListener("keydown", down);
    return () => document.removeEventListener("keydown", down);
  }, []);

  // Search logic
  useEffect(() => {
    if (!query.trim()) {
      setResults([]);
      return;
    }

    const filtered = searchIndex.filter(
      (item) =>
        item.title.toLowerCase().includes(query.toLowerCase()) ||
        item.section?.toLowerCase().includes(query.toLowerCase())
    );
    setResults(filtered);
    setSelectedIndex(0);
  }, [query]);

  // Keyboard navigation
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setSelectedIndex((i) => Math.min(i + 1, results.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setSelectedIndex((i) => Math.max(i - 1, 0));
    } else if (e.key === "Enter" && results[selectedIndex]) {
      e.preventDefault();
      handleSelect(results[selectedIndex]);
    }
  };

  const handleSelect = (result: SearchResult) => {
    setOpen(false);
    setQuery("");
    navigate(result.href);
  };

  return (
    <>
      {variant === "button" ? (
        <button
          onClick={() => setOpen(true)}
          className="flex items-center gap-2 px-3 py-1.5 rounded-lg border border-border bg-secondary/50 hover:bg-secondary text-muted-foreground hover:text-foreground transition-colors text-sm"
        >
          <Search className="h-4 w-4" />
          <span className="hidden md:inline">Search docs...</span>
          <kbd className="hidden md:inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded bg-muted text-[10px] font-mono">
            <Command className="h-3 w-3" />K
          </kbd>
        </button>
      ) : (
        <button
          onClick={() => setOpen(true)}
          className="w-full flex items-center gap-2 px-3 py-2 rounded-lg border border-border bg-background hover:bg-secondary/50 text-muted-foreground transition-colors text-sm"
        >
          <Search className="h-4 w-4" />
          <span>Search...</span>
          <kbd className="ml-auto inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded bg-muted text-[10px] font-mono">
            <Command className="h-3 w-3" />K
          </kbd>
        </button>
      )}

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="p-0 max-w-lg overflow-hidden">
          <VisuallyHidden>
            <DialogTitle>Search Documentation</DialogTitle>
          </VisuallyHidden>
          
          {/* Search Input */}
          <div className="flex items-center gap-3 px-4 py-3 border-b border-border">
            <Search className="h-5 w-5 text-muted-foreground shrink-0" />
            <input
              ref={inputRef}
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="Search documentation..."
              className="flex-1 bg-transparent outline-none text-sm placeholder:text-muted-foreground"
              autoFocus
            />
            {query && (
              <button
                onClick={() => setQuery("")}
                className="text-xs text-muted-foreground hover:text-foreground"
              >
                Clear
              </button>
            )}
          </div>

          {/* Results */}
          <div className="max-h-80 overflow-y-auto">
            {query && results.length === 0 && (
              <div className="px-4 py-8 text-center text-sm text-muted-foreground">
                No results found for "{query}"
              </div>
            )}

            {results.length > 0 && (
              <div className="py-2">
                {results.map((result, index) => (
                  <button
                    key={result.href}
                    onClick={() => handleSelect(result)}
                    className={cn(
                      "w-full flex items-center gap-3 px-4 py-2.5 text-left transition-colors",
                      index === selectedIndex
                        ? "bg-primary/10 text-foreground"
                        : "text-muted-foreground hover:bg-secondary/50 hover:text-foreground"
                    )}
                  >
                    {result.type === "page" ? (
                      <File className="h-4 w-4 shrink-0" />
                    ) : (
                      <Hash className="h-4 w-4 shrink-0" />
                    )}
                    <div className="flex-1 min-w-0">
                      <p className="text-sm font-medium truncate">{result.title}</p>
                      {result.section && (
                        <p className="text-xs text-muted-foreground truncate">
                          in {result.section}
                        </p>
                      )}
                    </div>
                    <ArrowRight className={cn(
                      "h-4 w-4 shrink-0 transition-opacity",
                      index === selectedIndex ? "opacity-100" : "opacity-0"
                    )} />
                  </button>
                ))}
              </div>
            )}

            {!query && (
              <div className="px-4 py-6 text-center text-sm text-muted-foreground">
                <p>Type to search the documentation</p>
                <div className="flex items-center justify-center gap-4 mt-3 text-xs">
                  <span className="flex items-center gap-1">
                    <kbd className="px-1.5 py-0.5 rounded bg-muted font-mono">↑</kbd>
                    <kbd className="px-1.5 py-0.5 rounded bg-muted font-mono">↓</kbd>
                    to navigate
                  </span>
                  <span className="flex items-center gap-1">
                    <kbd className="px-1.5 py-0.5 rounded bg-muted font-mono">↵</kbd>
                    to select
                  </span>
                  <span className="flex items-center gap-1">
                    <kbd className="px-1.5 py-0.5 rounded bg-muted font-mono">esc</kbd>
                    to close
                  </span>
                </div>
              </div>
            )}
          </div>
        </DialogContent>
      </Dialog>
    </>
  );
}
