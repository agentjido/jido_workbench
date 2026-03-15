# ReqLLM Builder Notes

## Use This Reference For

- Mapping a product requirement onto a provider adapter, request shape, and response flow.
- Deciding when to stay inside `req_llm` versus escalate to `jido_ai` or `jido`.
- Building examples that are transport-focused instead of agent-focused.

## Source Highlights

- `req_llm` is an Elixir LLM client built on Req.
- The package is most useful for provider integration, request building, response parsing, and streaming.
- `jido_ai` adds AI workflow concepts on top of packages like `req_llm`; it is reference material, not a generated skill target here.

## Implementation Heuristics

- Keep the provider edge thin and predictable.
- Normalize the request contract once, then map to provider-specific fields.
- Prefer explicit options for streaming, tools, and structured output modes instead of magical flags.
- Surface provider errors as data the next layer can handle.

## Narrowing Rules

- If the task becomes a multi-step agent loop, move up to `jido` or `jido_ai`.
- If the task is model discovery or price-aware routing, pair with `llm_db`.

## Sources

- https://jido.run/ecosystem
- https://hexdocs.pm/req_llm/readme.html
- https://hex.pm/packages/req_llm
- https://hexdocs.pm/jido_ai/readme.html
