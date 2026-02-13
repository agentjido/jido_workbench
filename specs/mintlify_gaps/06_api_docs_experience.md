# 06 - API Docs Experience

Priority: P1
Outcome: Provide a first-class API docs entrypoint beyond external HexDocs links.

## Why This Matters

Mintlify excels at interactive API docs. Your current docs shell sends users to external docs, which fragments the learning path.

## Current Codebase Findings

- Docs nav and sidebars primarily point to external HexDocs for API reference:
  - `lib/agent_jido_web/live/jido_docs_live.ex:142`
  - `lib/agent_jido_web/components/jido/docs_components.ex:78`
  - `lib/agent_jido_web/components/jido/docs_components.ex:246`
- No OpenAPI/Swagger route detected in router:
  - `lib/agent_jido_web/router.ex:48`

## Gap Statement

API references are external-only, and there is no integrated API reference experience inside the docs site.

## Implementation Steps

1. Create `/docs/api` landing page in current docs system.
2. Add API guides that cover:
   - request/response contracts
   - common errors
   - auth patterns (if applicable)
3. If OpenAPI specs exist or can be generated:
   - add spec artifact endpoint (json/yaml)
   - add interactive explorer view
4. Add code snippets with copy support:
   - curl
   - Elixir (`Req`, `ReqLLM`, or domain-specific examples)
5. Keep external HexDocs links, but position them as deep reference, not primary path.

## Suggested File Targets

- `priv/documentation/docs/api/index.md` (new)
- `lib/agent_jido_web/router.ex` (new docs route if needed)
- `lib/agent_jido_web/live/jido_docs_live.html.heex` (API section link)
- `lib/agent_jido_web/components/jido/docs_components.ex` (sidebar/nav updates)

## Acceptance Criteria

1. Users can start API onboarding inside `/docs` without leaving the site.
2. API docs include runnable request examples with copy UX.
3. External HexDocs remain accessible for detailed module docs.

## Dependencies

- Works best after 04 and 05, so API docs can reuse metadata and components.
