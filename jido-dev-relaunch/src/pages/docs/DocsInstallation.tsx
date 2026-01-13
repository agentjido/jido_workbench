import { DocsLayout } from "@/components/docs/DocsLayout";
import { CodeBlock } from "@/components/ui/code-block";
import { CheckCircle2 } from "lucide-react";

const tableOfContents = [
  { id: "requirements", title: "Requirements", level: 2 },
  { id: "add-dependency", title: "Add Dependency", level: 2 },
  { id: "choose-package", title: "Choose Your Package", level: 2 },
  { id: "verify", title: "Verify Installation", level: 2 },
];

const mixDeps = `# mix.exs
def deps do
  [
    {:jido, "~> 0.1.0"}
  ]
end`;

const fullStackDeps = `# For AI-powered agents (includes jido, req_llm, llmdb)
def deps do
  [
    {:jido_ai, "~> 0.1.0"}
  ]
end`;

const verifyCode = `# Start iex with your project
$ iex -S mix

# Verify Jido is loaded
iex> Jido.version()
"0.1.0"

# You're ready to create your first agent!`;

export default function DocsInstallation() {
  return (
    <DocsLayout 
      tableOfContents={tableOfContents}
      githubPath="docs/installation.md"
      livebookUrl="https://livebook.dev/run?url=https://github.com/agentjido/jido/blob/main/notebooks/installation.livemd"
      prev={{ title: "Introduction", href: "/docs" }}
      next={{ title: "Quick Start", href: "/docs/quickstart" }}
    >
      <div className="prose prose-invert max-w-none">
        <h1 className="text-4xl font-bold mb-4 not-prose">Installation</h1>
        
        <p className="text-xl text-muted-foreground mb-8 not-prose">
          Get Jido installed in your Elixir project in under a minute.
        </p>

        <section id="requirements" className="mb-12 not-prose">
          <h2 className="text-2xl font-semibold mb-4">Requirements</h2>
          <ul className="space-y-2">
            <li className="flex items-center gap-3">
              <CheckCircle2 className="h-5 w-5 text-primary" />
              <span><strong>Elixir</strong> 1.14 or later</span>
            </li>
            <li className="flex items-center gap-3">
              <CheckCircle2 className="h-5 w-5 text-primary" />
              <span><strong>Erlang/OTP</strong> 25 or later</span>
            </li>
            <li className="flex items-center gap-3">
              <CheckCircle2 className="h-5 w-5 text-primary" />
              <span><strong>Mix</strong> (comes with Elixir)</span>
            </li>
          </ul>
          <p className="text-sm text-muted-foreground mt-4">
            Don't have Elixir installed? Follow the{" "}
            <a 
              href="https://elixir-lang.org/install.html" 
              target="_blank" 
              rel="noopener noreferrer"
              className="text-primary hover:underline"
            >
              official installation guide
            </a>.
          </p>
        </section>

        <section id="add-dependency" className="mb-12 not-prose">
          <h2 className="text-2xl font-semibold mb-4">Add Dependency</h2>
          <p className="text-muted-foreground mb-4">
            Add Jido to your <code className="text-accent">mix.exs</code> dependencies:
          </p>
          <CodeBlock code={mixDeps} filename="mix.exs" />
          <p className="text-muted-foreground mt-4">
            Then fetch the dependency:
          </p>
          <div className="bg-code-bg border border-code-border rounded-lg p-4 font-mono text-sm mt-2">
            <span className="text-muted-foreground">$</span>{" "}
            <span className="text-foreground">mix deps.get</span>
          </div>
        </section>

        <section id="choose-package" className="mb-12 not-prose">
          <h2 className="text-2xl font-semibold mb-4">Choose Your Package</h2>
          <p className="text-muted-foreground mb-4">
            Jido is modular. Install only what you need:
          </p>
          
          <div className="space-y-4">
            <div className="bg-card border border-border rounded-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <code className="text-primary font-mono">jido</code>
                <span className="text-xs bg-primary/10 text-primary px-2 py-0.5 rounded">Core</span>
              </div>
              <p className="text-sm text-muted-foreground mb-2">
                The core bot/agent framework. Use this if you don't need AI/LLM capabilities.
              </p>
              <code className="text-xs text-muted-foreground">{`:jido, "~> 0.1.0"`}</code>
            </div>

            <div className="bg-card border border-border rounded-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <code className="text-primary font-mono">jido_ai</code>
                <span className="text-xs bg-accent/10 text-accent px-2 py-0.5 rounded">AI Stack</span>
              </div>
              <p className="text-sm text-muted-foreground mb-2">
                Full AI agent stack. Includes jido + req_llm + llmdb for LLM-powered agents.
              </p>
              <code className="text-xs text-muted-foreground">{`:jido_ai, "~> 0.1.0"`}</code>
            </div>

            <div className="bg-card border border-border rounded-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <code className="text-primary font-mono">jido_coder</code>
                <span className="text-xs bg-muted text-muted-foreground px-2 py-0.5 rounded">Specialized</span>
              </div>
              <p className="text-sm text-muted-foreground mb-2">
                AI coding agents with file system, Git, and code analysis tools.
              </p>
              <code className="text-xs text-muted-foreground">{`:jido_coder, "~> 0.1.0"`}</code>
            </div>
          </div>

          <div className="mt-6">
            <p className="text-sm text-muted-foreground mb-2">
              For AI-powered agents, use the full stack:
            </p>
            <CodeBlock code={fullStackDeps} filename="mix.exs" />
          </div>
        </section>

        <section id="verify" className="mb-12 not-prose">
          <h2 className="text-2xl font-semibold mb-4">Verify Installation</h2>
          <p className="text-muted-foreground mb-4">
            Confirm everything is working:
          </p>
        </section>
      </div>
    </DocsLayout>
  );
}
