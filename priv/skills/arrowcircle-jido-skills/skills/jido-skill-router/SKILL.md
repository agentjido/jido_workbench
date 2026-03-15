---
name: jido-skill-router
description: Meta-skill for routing Jido ecosystem work to the right package skills. Use when Codex needs to choose between $jido, $jido-action, $jido-signal, $req-llm, $llm-db, $ash-jido, $jido-browser, $jido-memory, $jido-behaviortree, $jido-messaging, $jido-otel, or $jido-studio, or when a task spans several of them and needs a handoff order.
---

# Jido Skill Router

Use this skill as the entry point when the correct Jido package skill is unclear or when the work crosses package boundaries.

Read [references/skill-manifest.yaml](references/skill-manifest.yaml) when the task needs a full routing map, related-skill lookup, or a machine-readable inventory of the current catalog.

## Routing Workflow

1. Identify the anchor concern first.
2. Load only the anchor skill.
3. Add one adjacent skill when the task crosses its boundary.
4. Keep each handoff explicit in the work plan or response.
5. If the docs are thin, narrow the scope and call out the gap instead of inventing behavior.

## Anchor Skill Selection

- Use `$jido` for agents, directives, runtime loops, and cross-package orchestration.
- Use `$jido-action` for executable units of work, action schemas, and action reviews.
- Use `$jido-signal` for signal contracts, event structure, and dispatch semantics.
- Use `$llm-db` for model catalogs, provider metadata, and capability or price-based model selection.
- Use `$req-llm` for provider calls, request shaping, streaming, and response normalization.
- Use `$jido-browser` for browser-backed automation and DOM-dependent workflows.
- Use `$jido-memory` for recall, summarization, retrieval, and memory policy.
- Use `$jido-behaviortree` for selectors, sequences, fallback paths, and explicit branching.
- Use `$ash-jido` for Ash-to-Jido boundaries, generated actions, and domain-context propagation.
- Use `$jido-studio` for operator tooling, workbench pages, and ecosystem demos.
- Use `$jido-messaging` for external transport adapters, delivery semantics, and broker boundaries.
- Use `$jido-otel` for tracing, spans, observability hooks, and OpenTelemetry integration.

## Common Handoffs

- `$llm-db -> $req-llm -> $jido` for model-routed AI workflows.
- `$jido-action -> $jido -> $jido-signal` for action-driven agent flows.
- `$ash-jido -> $jido-action -> $jido -> $jido-signal` for Ash-triggered agents.
- `$jido-browser -> $jido-action -> $jido` for browser agents.
- `$jido-signal -> $jido-messaging` for external transport delivery.
- `$jido -> $jido-otel` for runtime observability.
- `$jido -> $jido-memory` when the workflow needs long-lived recall.
- `$jido -> $jido-behaviortree` when branching logic becomes a first-class concern.

## Boundaries

- Do not load all Jido skills by default.
- Do not replace package-specific guidance with generic router text; hand off to the package skill.
- Do not invent cross-package integrations that the package docs do not support.
- Do not use this skill when one package skill already owns the task clearly.
