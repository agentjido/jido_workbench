%{
  title: "Directives",
  order: 4,
  purpose: "How agents describe side effects without performing them",
  audience: :intermediate,
  content_type: :guide,
  learning_outcomes: [
    "Understand the directive pattern and why it exists",
    "Return directives from cmd/2",
    "Use built-in directives (Emit, Spawn, Schedule, etc.)",
    "Know how AgentServer executes directives"
  ],
  repos: ["jido"],
  source_modules: ["Jido.Agent.Directive"],
  source_files: ["lib/jido/agent/directive.ex"],
  status: :planned,
  priority: :medium,
  prerequisites: ["agents", "actions"],
  related: ["agent-server", "signals"],
  ecosystem_packages: ["jido"],
  tags: [:core, :directives, :effects]
}
---
## Content Brief

The directive system — how pure agent logic describes effects:

- Why directives exist (separation of pure and effectful)
- Built-in directive types: Emit, Error, Spawn, SpawnAgent, StopChild, Schedule, Stop, Cron, CronCancel
- How to return directives from cmd/2
- How AgentServer processes the directive queue
- Custom directives (if supported)

### Validation Criteria
- All listed directive types must exist in source
- Directive struct fields must match source definitions
