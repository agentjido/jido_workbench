%{
  title: "Incremental Adoption",
  category: :features,
  description: "Start with one agent in an existing Elixir app and expand adoption in controlled steps.",
  doc_type: :explanation,
  audience: :beginner,
  draft: false,
  order: 40
}
---
You do not need a rewrite to adopt Jido. Start with one workflow in one supervised process, then expand to additional agents after you validate behavior in production.

## The problem

Most teams evaluating agent infrastructure already run production systems with existing APIs, queues, and deployment pipelines. A full migration is usually high risk and hard to justify early.

Common adoption blockers look like this:

- Existing services cannot pause feature delivery for a platform rewrite.
- Teams need proof on one critical workflow before broader rollout.
- Runtime behavior must be observable from day one to earn trust.

## How Jido addresses this

Jido supports staged adoption:

1. Model one domain workflow as an Agent with explicit state and Actions.
2. Run that Agent under `Jido.AgentServer` inside your current supervision tree.
3. Expand signal routes and neighboring agents only after the first workflow is stable.

That gives you a bounded pilot with real runtime semantics, instead of a throwaway prototype that must be rewritten later.

## Proof: see it work

You can add a single Agent server to an existing OTP tree and inspect its state immediately.

```elixir
children = [
  {Jido.AgentServer,
   id: :counter_agent_server,
   agent: AgentJido.Demos.CounterAgent,
   jido: AgentJido.Jido,
   name: :counter_agent_server}
]

{:ok, _pid} = Supervisor.start_link(children, strategy: :one_for_one)
{:ok, server_state} = Jido.AgentServer.state(:counter_agent_server)
server_state.agent.state.count
```

**Result:**

```
0
```

The workflow now runs under OTP supervision without changing the rest of your application architecture.

## How this differs

Prototype-first stacks often optimize for greenfield setup, then require additional glue to retrofit reliability and operations controls into an existing system.

Jido starts with runtime boundaries and supervised execution, so a small pilot can use the same operational model as a larger rollout. You can migrate in steps without changing your reliability model later.

## Learn more

- **Ecosystem:** [Jido core runtime](/ecosystem/jido) and [Jido Action](/ecosystem/jido_action)
- **Training:** [Agent Fundamentals on the BEAM](/training/agent-fundamentals)
- **Training:** [LiveView + Jido Integration Patterns](/training/liveview-integration)
- **Docs:** [Architecture](/docs/architecture) and [Guides](/docs/guides)
- **Context:** [All feature pillars](/features)

## Get Building

Ready to pilot one production workflow? [Get Building](/getting-started), then review a minimal implementation in [Counter Agent](/examples/counter-agent).
