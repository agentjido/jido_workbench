%{
  description: "Hands-on tutorials from first install to production agent workflows.",
  title: "Learn",
  category: :docs,
  legacy_paths: [],
  tags: [:docs, :learn],
  order: 20
}
---

These tutorials take you from zero to running agents in production. The onboarding ladder is sequential - start at the top and work down. Training modules and build guides stand alone, so jump to whatever you need.

## Onboarding ladder

Your first-time path through Jido. Complete these four tutorials in order.

- [Installation and setup](/docs/learn/installation) - add deps, configure secrets, smoke test
- [Build your first agent](/docs/learn/first-agent) - typed state, actions, `cmd/2`
- [Build your first LLM agent](/docs/learn/first-llm-agent) - add AI reasoning with jido_ai
- [Build your first workflow](/docs/learn/first-workflow) - compose actions into plans

## Training modules

Deeper dives into specific areas. Read them in any order.

- [Agent fundamentals](/docs/learn/agent-fundamentals) - mental model: typed state, deterministic transitions, signal routing
- [Actions and validation](/docs/learn/actions-validation) - schema validation, composition patterns
- [Directives and scheduling](/docs/learn/directives-scheduling) - side-effect isolation, execution timing
- [Signals and routing](/docs/learn/signals-routing) - event-driven dispatch
- [Tool use](/docs/learn/tool-use) - integrating external tools into agent workflows
- [Why not just a GenServer?](/docs/learn/why-not-just-a-genserver) - the case for separating data from process

## Build guides

Hands-on projects that put the pieces together.

- [Counter agent](/docs/learn/counter-agent) - minimal stateful agent from scratch
- [Demand tracker agent](/docs/learn/demand-tracker-agent) - real-world data aggregation pattern
- [AI chat agent](/docs/learn/ai-chat-agent) - conversational agent with streaming responses
- [Multi-agent workflows](/docs/learn/multi-agent-workflows) - coordinate multiple agents on a shared task
- [LiveView integration](/docs/learn/liveview-integration) - wire agents into Phoenix LiveView UIs

## Next steps

- [Concepts](/docs/concepts) - understand the architecture behind what you just built
- [Guides](/docs/guides) - task-focused recipes for specific problems
