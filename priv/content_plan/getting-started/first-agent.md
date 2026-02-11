%{
  title: "Building Your First Agent",
  order: 2,
  purpose: "Walk a new user from zero to a running agent in under 10 minutes",
  audience: :beginner,
  content_type: :tutorial,
  learning_outcomes: [
    "Define an agent module with schema-validated state",
    "Write a basic action and wire it to cmd/2",
    "Run the agent in IEx and observe state changes"
  ],
  repos: ["jido"],
  source_modules: ["Jido.Agent", "Jido.Action"],
  source_files: ["lib/jido/agent.ex", "lib/jido/action.ex"],
  status: :planned,
  priority: :critical,
  prerequisites: ["installation"],
  related: ["key-concepts", "actions"],
  ecosystem_packages: ["jido", "jido_action"],
  tags: [:getting_started, :agents, :tutorial]
}
---
## Content Brief

The canonical "hello world" for Jido. Build a simple counter agent:

1. Define `MyApp.CounterAgent` using `use Jido.Agent`
2. Define schema with a `:count` field
3. Create a `MyApp.IncrementAction` using `use Jido.Action`
4. Run `cmd/2` and observe the state change
5. Show the returned directives (even if empty)

### Code Examples Needed
- Complete agent module definition
- Complete action module definition
- IEx session showing cmd/2 in action

### Validation Criteria
- All code examples must compile against jido 2.0.0-rc.4
- Must reference the cmd/2 contract accurately
- Agent struct fields must match current Jido.Agent schema
