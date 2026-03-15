---
name: llm-db
description: Builder-oriented guidance for the upstream `llm_db` package. Use when Codex needs to model provider and model catalogs, select models by capability or price, wire catalog lookups into Elixir code, or review `llm_db` boundaries versus `req_llm`, `jido`, and `jido_ai`.
---

# LLM DB

`llm_db` is the upstream Hex package name.

## Start Here

Use this skill when the task is about model metadata, capability catalogs, or provider/model selection logic.

Good triggers:
- "Add model selection based on context window or pricing."
- "Normalize OpenAI, Anthropic, or OpenRouter model ids in Elixir."
- "Turn the LLM DB docs into a runnable catalog lookup example."
- "Review whether this code belongs in `llm_db` or in the provider client."

Read [references/builder-notes.md](references/builder-notes.md) before editing when the task touches capability filters, pricing metadata, or cross-provider normalization.

## Primary Workflows

### Build catalog-backed selection

- Model the caller's selection criteria first: provider allowlist, modality, tool support, context window, price ceiling, or local-vs-hosted constraint.
- Keep catalog lookup pure and deterministic. Return model metadata or a narrowed candidate list before making any network call.
- Push actual inference requests into `req_llm` or another provider client. `llm_db` should decide, not execute.

### Add or refine provider metadata

- Start from the package's existing schema and naming conventions instead of inventing a parallel shape.
- Preserve upstream provider ids exactly, then add a local mapping layer only if the app needs aliases.
- Prefer additive metadata updates over app-specific branching in the core catalog.

### Turn docs into runnable examples

- Build examples around lookup, filtering, ranking, or capability checks.
- Show how the chosen model metadata feeds a later `req_llm` or Jido workflow.
- Keep examples small enough to run in `iex` or a focused test.

### Review package boundaries

- Keep catalog concerns in `llm_db`.
- Keep request transport, retries, and streaming in `req_llm`.
- Keep agent orchestration, directives, and tool use in `jido` or `jido_ai`.

## Build Checklist

- Confirm which providers and model families the app actually needs.
- Verify whether the task needs static metadata, live pricing refresh, or both.
- Keep the API shape obvious: input criteria in, ranked models or metadata out.
- Add tests for provider aliases, missing models, and fallback behavior.

## Boundaries

- Do not use this skill for prompt design or message shaping.
- Do not hide provider-specific HTTP logic inside catalog helpers.
- Do not promise pricing freshness beyond what the package sources actually support.
