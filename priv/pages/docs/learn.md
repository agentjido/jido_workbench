%{
  title: "Learn",
  description: "Hands-on tutorials from first install to production agent workflows.",
  category: :docs,
  order: 25,
  tags: [:docs, :learn],
  draft: false
}
---

These tutorials take you from first install to production agent workflows. The onboarding ladder is sequential - start at the top and work down. Training modules and build guides stand alone, so jump to whatever you need.

## Onboarding ladder

Your first-time path through Jido. Complete these four tutorials in order.

1. [Installation and setup](/docs/learn/installation) - add dependencies, configure secrets, and verify everything runs
2. [Build your first agent](/docs/learn/first-agent) - define typed state, wire up actions, and call `cmd/2`
3. [Build your first LLM agent](/docs/learn/first-llm-agent) - add AI reasoning to an agent with `jido_ai`
4. [Build your first workflow](/docs/learn/first-workflow) - compose actions into multi-step plans

## Training modules

Deeper dives into specific Jido primitives. Read them in any order.

- [Agent fundamentals](/docs/learn/agent-fundamentals) - mental model for typed state, deterministic transitions, and signal routing
- [Actions and validation](/docs/learn/actions-validation) - schema validation, composition, and the open validation model
- [Directives and scheduling](/docs/learn/directives-scheduling) - side-effect isolation, execution timing, and the drain loop
- [Signals and routing](/docs/learn/signals-routing) - event-driven dispatch, routing tables, and wildcards
- [Tool use](/docs/learn/tool-use) - integrate external tools and LLM function calling into agent workflows
- [Why not just a GenServer?](/docs/learn/why-not-just-a-genserver) - the case for separating data from process

## Build guides

Hands-on project tutorials that put the pieces together. More guides are coming soon.

- [Counter agent](/docs/learn/counter-agent) - minimal stateful agent from scratch
- [Demand tracker agent](/docs/learn/demand-tracker-agent) - real-world data aggregation pattern
- [AI chat agent](/docs/learn/ai-chat-agent) - conversational agent with streaming responses
- [Multi-agent workflows](/docs/learn/multi-agent-workflows) - coordinate multiple agents on a shared task
- [LiveView integration](/docs/learn/liveview-integration) - wire agents into Phoenix LiveView UIs

## Next steps

- [Concepts](/docs/concepts) - understand the architecture behind what you built
- [Guides](/docs/guides) - task-focused recipes for specific problems
- [Ecosystem](/docs/ecosystem) - explore the packages that extend Jido
