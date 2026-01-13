import { useState } from "react";
import { Sparkles, Send, ArrowRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";

export function DocsAskAI() {
  const [query, setQuery] = useState("");
  const [isFocused, setIsFocused] = useState(false);

  const suggestions = [
    "How do I create my first agent?",
    "What are Actions in Jido?",
    "How does supervision work?",
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (query.trim()) {
      // For now, just clear - in real implementation this would call an AI API
      console.log("Ask AI:", query);
      setQuery("");
    }
  };

  return (
    <div className="mt-12 pt-8 border-t border-border">
      <div className="relative">
        {/* Glow effect */}
        <div 
          className={cn(
            "absolute -inset-1 rounded-xl bg-gradient-to-r from-primary/20 via-accent/20 to-primary/20 blur-lg transition-opacity duration-300",
            isFocused ? "opacity-100" : "opacity-0"
          )} 
        />
        
        <div className="relative bg-card border border-border rounded-xl p-6">
          <div className="flex items-center gap-2 mb-4">
            <div className="h-8 w-8 rounded-lg bg-primary/10 flex items-center justify-center">
              <Sparkles className="h-4 w-4 text-primary" />
            </div>
            <div>
              <h3 className="text-sm font-medium">Ask a Question</h3>
              <p className="text-xs text-muted-foreground">Get AI-powered answers about Jido</p>
            </div>
          </div>

          <form onSubmit={handleSubmit} className="relative">
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onFocus={() => setIsFocused(true)}
              onBlur={() => setIsFocused(false)}
              placeholder="Ask anything about Jido..."
              className="w-full px-4 py-3 pr-12 rounded-lg bg-background border border-border focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all text-sm placeholder:text-muted-foreground outline-none"
            />
            <Button 
              type="submit"
              size="icon"
              variant="ghost"
              className="absolute right-2 top-1/2 -translate-y-1/2 h-8 w-8 text-muted-foreground hover:text-primary"
              disabled={!query.trim()}
            >
              <Send className="h-4 w-4" />
            </Button>
          </form>

          {/* Suggestion chips */}
          <div className="flex flex-wrap gap-2 mt-4">
            {suggestions.map((suggestion) => (
              <button
                key={suggestion}
                onClick={() => setQuery(suggestion)}
                className="inline-flex items-center gap-1 px-3 py-1.5 rounded-full bg-secondary/50 hover:bg-secondary text-xs text-muted-foreground hover:text-foreground transition-colors"
              >
                {suggestion}
                <ArrowRight className="h-3 w-3" />
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
