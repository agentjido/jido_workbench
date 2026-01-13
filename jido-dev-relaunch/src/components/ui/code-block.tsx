import { useMemo } from "react";
import { cn } from "@/lib/utils";

interface CodeBlockProps {
  code: string;
  language?: string;
  caption?: string;
  filename?: string;
  className?: string;
}

// Simple Elixir syntax highlighter
function highlightElixir(code: string): React.ReactNode[] {
  const lines = code.split("\n");
  
  return lines.map((line, lineIndex) => {
    const tokens: React.ReactNode[] = [];
    let remaining = line;
    let keyIndex = 0;

    // Process each token
    while (remaining.length > 0) {
      let matched = false;

      // Comments
      const commentMatch = remaining.match(/^(#.*)$/);
      if (commentMatch) {
        tokens.push(
          <span key={keyIndex++} className="syntax-comment">
            {commentMatch[1]}
          </span>
        );
        remaining = "";
        matched = true;
      }

      // Keywords
      if (!matched) {
        const keywordMatch = remaining.match(
          /^(defmodule|def|defp|do|end|use|if|else|case|when|fn|for|in|with|cond|quote|unquote|require|import|alias|raise|try|catch|rescue|after)\b/
        );
        if (keywordMatch) {
          tokens.push(
            <span key={keyIndex++} className="syntax-keyword">
              {keywordMatch[1]}
            </span>
          );
          remaining = remaining.slice(keywordMatch[1].length);
          matched = true;
        }
      }

      // Module names (capitalized words)
      if (!matched) {
        const moduleMatch = remaining.match(/^([A-Z][A-Za-z0-9_.]*)/);
        if (moduleMatch) {
          tokens.push(
            <span key={keyIndex++} className="syntax-module">
              {moduleMatch[1]}
            </span>
          );
          remaining = remaining.slice(moduleMatch[1].length);
          matched = true;
        }
      }

      // Atoms
      if (!matched) {
        const atomMatch = remaining.match(/^(:[a-z_][a-z0-9_]*\??)/);
        if (atomMatch) {
          tokens.push(
            <span key={keyIndex++} className="syntax-atom">
              {atomMatch[1]}
            </span>
          );
          remaining = remaining.slice(atomMatch[1].length);
          matched = true;
        }
      }

      // Strings
      if (!matched) {
        const stringMatch = remaining.match(/^("[^"]*"|'[^']*')/);
        if (stringMatch) {
          tokens.push(
            <span key={keyIndex++} className="syntax-string">
              {stringMatch[1]}
            </span>
          );
          remaining = remaining.slice(stringMatch[1].length);
          matched = true;
        }
      }

      // Numbers
      if (!matched) {
        const numberMatch = remaining.match(/^(\d+(?:_\d+)*(?:\.\d+)?)/);
        if (numberMatch) {
          tokens.push(
            <span key={keyIndex++} className="syntax-number">
              {numberMatch[1]}
            </span>
          );
          remaining = remaining.slice(numberMatch[1].length);
          matched = true;
        }
      }

      // Function calls
      if (!matched) {
        const funcMatch = remaining.match(/^([a-z_][a-z0-9_]*[!?]?)(\()/);
        if (funcMatch) {
          tokens.push(
            <span key={keyIndex++} className="syntax-function">
              {funcMatch[1]}
            </span>
          );
          tokens.push(<span key={keyIndex++}>{funcMatch[2]}</span>);
          remaining = remaining.slice(funcMatch[0].length);
          matched = true;
        }
      }

      // Operators and special characters
      if (!matched) {
        const opMatch = remaining.match(/^(->|<-|=>|::|\\\\|\|>|&&|\|\||==|!=|<=|>=|<|>|=|{|}|\[|\]|\(|\)|,|\.|:)/);
        if (opMatch) {
          tokens.push(
            <span key={keyIndex++} className="syntax-operator">
              {opMatch[1]}
            </span>
          );
          remaining = remaining.slice(opMatch[1].length);
          matched = true;
        }
      }

      // Default: single character
      if (!matched) {
        tokens.push(<span key={keyIndex++}>{remaining[0]}</span>);
        remaining = remaining.slice(1);
      }
    }

    return (
      <div key={lineIndex} className="leading-relaxed">
        {tokens.length > 0 ? tokens : " "}
      </div>
    );
  });
}

export function CodeBlock({ code, language = "elixir", caption, filename, className }: CodeBlockProps) {
  const highlighted = useMemo(() => {
    if (language === "elixir") {
      return highlightElixir(code);
    }
    return code.split("\n").map((line, i) => <div key={i}>{line || " "}</div>);
  }, [code, language]);

  return (
    <div className={cn("relative group", className)}>
      {filename && (
        <div className="flex items-center gap-2 px-4 py-2 bg-muted/50 border border-code-border border-b-0 rounded-t-lg">
          <div className="flex gap-1.5">
            <div className="w-3 h-3 rounded-full bg-destructive/50" />
            <div className="w-3 h-3 rounded-full bg-yellow-500/50" />
            <div className="w-3 h-3 rounded-full bg-green-500/50" />
          </div>
          <span className="text-xs text-muted-foreground font-mono ml-2">{filename}</span>
        </div>
      )}
      {!filename && language && (
        <div className="absolute top-3 right-3 text-xs text-muted-foreground font-mono opacity-50 group-hover:opacity-100 transition-opacity">
          {language}
        </div>
      )}
      <pre className={cn("code-block text-sm font-mono overflow-x-auto", filename && "rounded-t-none")}>
        <code>{highlighted}</code>
      </pre>
      {caption && (
        <p className="mt-2 text-xs text-muted-foreground italic">{caption}</p>
      )}
    </div>
  );
}
