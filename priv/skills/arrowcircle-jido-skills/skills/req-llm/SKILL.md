---
name: req-llm
description: Builder-oriented guidance for the upstream `req_llm` package. Use when Codex needs to configure providers, shape LLM requests, implement streaming or structured outputs, or review `req_llm` boundaries versus `llm_db`, `jido`, and `jido_ai`.
---

# ReqLLM

`req_llm` is the upstream Hex package name.

## Start Here

Use this skill when the task is about making LLM calls from Elixir through Req-based provider adapters.

Good triggers:
- "Add OpenAI or Anthropic support to this Elixir app."
- "Stream model output through ReqLLM."
- "Turn the package docs into a working provider example."
- "Review whether this should live in `req_llm` or in a Jido action."

Read [references/builder-notes.md](references/builder-notes.md) before coding when the task involves provider differences, request/response shapes, or how `req_llm` fits under `jido_ai`.

## Primary Workflows

### Configure providers cleanly

- Separate provider configuration from call sites. Keep API keys, base URLs, and model defaults at the edge.
- Reuse Req idioms for timeouts, middleware, retries, and telemetry instead of inventing a second transport stack.
- Normalize the app-facing request shape before branching into provider-specific options.

### Build model invocation flows

- Decide whether the caller needs one-shot generation, streaming, tool calling, or structured outputs before writing the adapter code.
- Keep message shaping explicit. If prompts or tool schemas become complex, coordinate with `jido_ai` or `jido` rather than hiding orchestration in the HTTP client.
- Feed model selection from `llm_db` when capability or pricing constraints matter.

### Turn docs into runnable examples

- Prefer one provider per example.
- Show environment configuration, request construction, and response handling in a minimal `iex` or test-friendly flow.
- Add one example for failure handling or provider-specific options when that difference is the point of the task.

### Review package boundaries

- Keep provider transport and response normalization in `req_llm`.
- Keep catalog selection in `llm_db`.
- Keep agents, directives, and multi-step reasoning loops in `jido` or `jido_ai`.

## Build Checklist

- Verify the provider, model family, and auth mechanism first.
- Confirm whether the caller needs sync, async, or streaming behavior.
- Keep response parsing small and typed enough for the next layer.
- Add tests around rate limits, provider errors, and empty or partial responses.

## Boundaries

- Do not use this skill for model pricing catalogs.
- Do not use this skill for long-lived agent state or tool orchestration.
- Do not promise cross-provider feature parity when the package docs call out differences.
