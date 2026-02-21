%{
  title: "Reliability by Architecture",
  category: :features,
  description: "Design agent workflows around OTP supervision, process isolation, and deterministic state transitions.",
  doc_type: :explanation,
  audience: :intermediate,
  draft: false,
  order: 10
}
---
Jido treats reliability as a runtime design concern, not an afterthought. The core pattern is simple: deterministic Agent logic in `cmd/2`, supervised execution in `Jido.AgentServer`, and explicit side effects through Directives.

## At a glance

| Item | Summary |
|---|---|
| Best for | Elixir platform engineers, SRE/platform teams, and architects reviewing failure boundaries |
| Core packages | [jido](/ecosystem/jido), [jido_action](/ecosystem/jido_action), [jido_signal](/ecosystem/jido_signal) |
| Package status | `jido` (Beta), `jido_action` (Beta), `jido_signal` (Beta) |
| First proof path | [Counter Agent](/examples/counter-agent) -> [Production readiness checklist](/docs/operations/production-readiness-checklist) |
| Adoption stance | Start with one supervised workflow, then expand scope |

## Where reliability breaks in agent systems

Reliability usually degrades when runtime concerns are implicit:

- Restart behavior is spread across retries, queues, and app-level callbacks.
- Side effects run directly in business logic, which makes recovery paths hard to test.
- Multi-agent failures propagate across shared state boundaries.

Jido addresses this by separating concerns: pure decision logic in Agents, runtime lifecycle in OTP, and effect execution through Directives.

## Capability map

| Capability | Runtime mechanism | Package proof | Status |
|---|---|---|---|
| Agent lifecycle control | `Jido.AgentServer` wraps Agent execution under OTP processes | [jido](/ecosystem/jido) | Beta |
| Deterministic updates | `cmd/2` returns updated Agent + Directives | [jido](/ecosystem/jido) | Beta |
| Typed capability boundaries | Schema-validated Actions gate state changes | [jido_action](/ecosystem/jido_action) | Beta |
| Explicit coordination signals | Named Signals prevent hidden coupling | [jido_signal](/ecosystem/jido_signal) | Beta |
| Trace export bridge | Telemetry can be bridged to OTel | [jido_otel](/ecosystem/jido_otel) | Experimental |

## Proof: supervise one Agent and inspect state

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

Expected result:

```
0
```

This verifies a supervised runtime process with inspectable Agent state before adding LLMs, external tools, or distributed complexity.

## Tradeoffs and non-goals

- Jido is intentionally explicit; there is more up-front structure than prototype-first frameworks.
- Reliability still depends on your supervision topology and runbook quality.
- `jido` is currently **Beta**; treat API changes as part of rollout planning.

## What to explore next

- **Coordination contracts:** [Multi-agent coordination](/features/multi-agent-coordination)
- **Operations checks:** [Operations and observability](/features/operations-observability)
- **Hands-on training:** [Agent fundamentals](/training/agent-fundamentals), [Production readiness](/training/production-readiness)
- **Reference docs:** [Architecture](/docs/reference/architecture), [Incident playbooks](/docs/operations/incident-playbooks)

## Get Building

Start with [Counter Agent](/examples/counter-agent), then run the [production readiness checklist](/docs/operations/production-readiness-checklist) against your first supervised workflow.
