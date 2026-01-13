import { Link } from "react-router-dom";
import { DocsLayout } from "@/components/docs/DocsLayout";
import { CodeBlock } from "@/components/ui/code-block";
import { Terminal } from "lucide-react";

const tableOfContents = [
  { id: "create-project", title: "Create Project", level: 2 },
  { id: "define-agent", title: "Define an Agent", level: 2 },
  { id: "add-supervision", title: "Add Supervision", level: 2 },
  { id: "run-agents", title: "Run Your Agents", level: 2 },
  { id: "whats-next", title: "What's Next", level: 2 },
];

const createProject = `# Create a new Elixir project
$ mix new my_agents --sup

# Add Jido to mix.exs
def deps do
  [{:jido, "~> 0.1.0"}]
end

# Fetch dependencies
$ mix deps.get`;

const defineAgent = `# lib/my_agents/counter_agent.ex
defmodule MyAgents.CounterAgent do
  use Jido.Agent

  def init(args) do
    {:ok, %{
      id: args[:id],
      count: 0
    }}
  end

  def handle_action(:increment, state) do
    new_count = state.count + 1
    IO.puts("Agent #{state.id}: count = #{new_count}")
    {:ok, %{state | count: new_count}}
  end

  def handle_action(:reset, state) do
    {:ok, %{state | count: 0}}
  end
end`;

const addSupervision = `# lib/my_agents/application.ex
defmodule MyAgents.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Start Jido supervisor
      {Jido.Supervisor, name: MyAgents.AgentSupervisor}
    ]

    opts = [strategy: :one_for_one, name: MyAgents.Supervisor]
    Supervisor.start_link(children, opts)
  end
end`;

const runAgents = `# Start iex with your project
$ iex -S mix

# Start some agents
iex> alias MyAgents.{CounterAgent, AgentSupervisor}

iex> for i <- 1..5 do
...>   Jido.Supervisor.start_agent(AgentSupervisor, CounterAgent, id: i)
...> end

# Send actions to agents
iex> Jido.Agent.send_action({:via, Registry, {Jido.Registry, 1}}, :increment)
Agent 1: count = 1

iex> Jido.Agent.send_action({:via, Registry, {Jido.Registry, 1}}, :increment)
Agent 1: count = 2

# All agents are supervised - crash one and it restarts
iex> Process.exit(pid, :kill)
# Supervisor automatically restarts the agent`;

export default function DocsQuickstart() {
  return (
    <DocsLayout 
      tableOfContents={tableOfContents}
      githubPath="docs/quickstart.md"
      livebookUrl="https://livebook.dev/run?url=https://github.com/agentjido/jido/blob/main/notebooks/quickstart.livemd"
      prev={{ title: "Installation", href: "/docs/installation" }}
      next={{ title: "First Agent", href: "/docs/first-agent" }}
    >
      <div className="prose prose-invert max-w-none">
        <h1 className="text-4xl font-bold mb-4 not-prose">Quick Start</h1>
        
        <p className="text-xl text-muted-foreground mb-8 not-prose">
          Build and run your first supervised agents in 5 minutes.
        </p>

        <div className="bg-primary/5 border border-primary/20 rounded-lg p-4 mb-8 not-prose">
          <div className="flex items-start gap-3">
            <Terminal className="h-5 w-5 text-primary mt-0.5" />
            <div>
              <p className="text-sm font-medium">Prerequisites</p>
              <p className="text-sm text-muted-foreground">
                Make sure you have{" "}
                <Link to="/docs/installation" className="text-primary hover:underline">
                  installed Jido
                </Link>{" "}
                before continuing.
              </p>
            </div>
          </div>
        </div>

        <section id="create-project" className="mb-12 not-prose">
          <h2 className="text-2xl font-semibold mb-4">1. Create Project</h2>
          <p className="text-muted-foreground mb-4">
            Create a new Elixir project with a supervision tree:
          </p>
          <CodeBlock code={createProject} filename="terminal" />
        </section>

        <section id="define-agent" className="mb-12 not-prose">
          <h2 className="text-2xl font-semibold mb-4">2. Define an Agent</h2>
          <p className="text-muted-foreground mb-4">
            Create a simple counter agent that can increment and reset:
          </p>
          <CodeBlock code={defineAgent} filename="lib/my_agents/counter_agent.ex" />
          <div className="mt-4 text-sm text-muted-foreground space-y-2">
            <p>
              <strong className="text-foreground">init/1</strong> — Called when the agent starts. 
              Returns the initial state.
            </p>
            <p>
              <strong className="text-foreground">handle_action/2</strong> — Handles incoming actions. 
              Returns the updated state.
            </p>
          </div>
        </section>

        <section id="add-supervision" className="mb-12 not-prose">
          <h2 className="text-2xl font-semibold mb-4">3. Add Supervision</h2>
          <p className="text-muted-foreground mb-4">
            Add the Jido supervisor to your application's supervision tree:
          </p>
          <CodeBlock code={addSupervision} filename="lib/my_agents/application.ex" />
          <p className="text-sm text-muted-foreground mt-4">
            The supervisor will manage all your agents—starting them, restarting on crash, 
            and shutting down gracefully.
          </p>
        </section>

        <section id="run-agents" className="mb-12 not-prose">
          <h2 className="text-2xl font-semibold mb-4">4. Run Your Agents</h2>
          <p className="text-muted-foreground mb-4">
            Start your application and interact with agents:
          </p>
          <CodeBlock code={runAgents} filename="terminal" />
        </section>

        <section id="whats-next" className="mb-12 not-prose">
          <h2 className="text-2xl font-semibold mb-4">What's Next?</h2>
          <div className="grid sm:grid-cols-2 gap-4">
            <Link 
              to="/docs/first-agent"
              className="bg-card border border-border rounded-lg p-4 hover:border-primary/50 transition-colors group"
            >
              <h3 className="font-medium group-hover:text-primary transition-colors">
                Build Your First Agent
              </h3>
              <p className="text-sm text-muted-foreground mt-1">
                Deep dive into agent patterns and best practices.
              </p>
            </Link>
            <Link 
              to="/docs/supervision"
              className="bg-card border border-border rounded-lg p-4 hover:border-primary/50 transition-colors group"
            >
              <h3 className="font-medium group-hover:text-primary transition-colors">
                Supervision Strategies
              </h3>
              <p className="text-sm text-muted-foreground mt-1">
                Learn how to configure restart strategies and fault tolerance.
              </p>
            </Link>
            <Link 
              to="/docs/actions"
              className="bg-card border border-border rounded-lg p-4 hover:border-primary/50 transition-colors group"
            >
              <h3 className="font-medium group-hover:text-primary transition-colors">
                Actions & Validation
              </h3>
              <p className="text-sm text-muted-foreground mt-1">
                Use structured, validated actions with schemas.
              </p>
            </Link>
            <Link 
              to="/examples"
              className="bg-card border border-border rounded-lg p-4 hover:border-primary/50 transition-colors group"
            >
              <h3 className="font-medium group-hover:text-primary transition-colors">
                Production Examples
              </h3>
              <p className="text-sm text-muted-foreground mt-1">
                Real-world patterns with metrics and benchmarks.
              </p>
            </Link>
          </div>
        </section>
      </div>
    </DocsLayout>
  );
}
