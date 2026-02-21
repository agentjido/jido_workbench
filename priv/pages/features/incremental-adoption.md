%{
  title: "Incremental adoption",
  category: :features,
  description: "Adopt Jido in bounded stages: one supervised workflow first, then expand package scope with clear guardrails.",
  doc_type: :explanation,
  audience: :beginner,
  draft: false,
  order: 40
}
---
You do not need a rewrite to adopt Jido. The recommended posture is bounded adoption: one production-relevant workflow, one explicit success criterion, then controlled expansion.

## At a glance

| Item | Summary |
|---|---|
| Best for | Staff architects, mixed-stack teams, engineering managers |
| Core packages | [jido](/ecosystem/jido), [jido_action](/ecosystem/jido_action) |
| Integration options | [ash_jido](/ecosystem/ash_jido), [jido_messaging](/ecosystem/jido_messaging), [jido_studio](/ecosystem/jido_studio) |
| Package status | Core runtime packages are Beta; integration packages are mostly Experimental |
| First proof path | [Counter Agent](/examples/counter-agent) -> [Quickstarts by persona](/build/quickstarts-by-persona) |

## Why phased adoption works better

Most teams already have production systems, existing APIs, and delivery commitments. A full migration increases risk and delays learning.

A phased rollout makes evaluation measurable:

- Pilot one workflow with clear runtime boundaries.
- Keep package scope minimal until the workflow is stable.
- Expand only after readiness and operational checks are passing.

## Phased rollout model

| Phase | Goal | Typical package set | Exit criteria |
|---|---|---|---|
| Phase 1: bounded pilot | Run one supervised workflow | `jido`, `jido_action`, `jido_signal` | deterministic behavior + basic runbook |
| Phase 2: product integration | Connect existing app boundaries | phase 1 + `ash_jido` or `jido_messaging` | integration tests + rollback path |
| Phase 3: intelligence expansion | Add LLM and advanced strategies where needed | phase 2 + `jido_ai`, `req_llm`, optional strategy packages | workload SLOs + cost controls |

## Proof: add one Agent server to an existing supervision tree

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

This proves bounded runtime adoption without changing the rest of your application architecture.

## Tradeoffs and non-goals

- Incremental rollout is slower than all-at-once rebuilds but lowers operational risk.
- Experimental integration packages require explicit pilot guardrails.
- Phased adoption still needs ownership for architecture decisions and runbook quality.

## What to explore next

- **Architectural framing:** [Reference architectures](/build/reference-architectures)
- **Mixed-stack boundary design:** [Mixed-stack integration](/build/mixed-stack-integration)
- **Decision support:** [Executive brief](/features/executive-brief)
- **Readiness docs:** [Production readiness checklist](/docs/operations/production-readiness-checklist), [Security and governance](/docs/operations/security-and-governance)

## Get Building

Start with one [Counter Agent](/examples/counter-agent) workflow, then map your next package decisions in [quickstarts by persona](/build/quickstarts-by-persona).
