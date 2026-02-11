# 03 - Ask AI With Citations

Priority: P0
Outcome: Replace placeholder Ask AI with grounded docs Q/A that cites source pages.

## Why This Matters

Mintlify-style AI is useful only when it is grounded in documentation and cites sources. Uncited answers reduce trust and can drift from actual docs content.

## Current Codebase Findings

- Ask AI button is currently visual only in `lib/agent_jido_web/components/jido/docs_components.ex:43`.
- Arcana stack is already present in the app supervision tree:
  - `lib/agent_jido/application.ex:13`
  - `lib/agent_jido/application.ex:14`
- Arcana and pgvector tables exist in migrations:
  - `priv/repo/migrations/20260211124047_create_arcana_tables.exs:7`
  - `priv/repo/migrations/20260211124047_create_arcana_tables.exs:32`
  - `priv/repo/migrations/20260211124047_create_arcana_tables.exs:49`
- There is no docs ingestion pipeline into Arcana found in current `lib/`.

## Gap Statement

The UI advertises Ask AI, but there is no retrieval/indexing/chat path for docs.

## Implementation Steps

1. Add docs ingestion task:
   - iterate `Documentation.all_documents/0`
   - chunk by headings/paragraph blocks
   - upsert into Arcana collection with metadata `{path, title, section}`
2. Add a docs ask service:
   - semantic retrieve top-k chunks
   - generate response with strict citation requirement
   - return answer + citations `[path, snippet]`
3. Add Ask AI modal component:
   - input box
   - streaming answer region
   - citation list with direct links
4. Add guardrails:
   - if confidence low or no sources, answer with "I could not find this in docs."
   - never return uncited facts
5. Add a refresh workflow:
   - local task: `mix docs.index`
   - CI or deploy hook to rebuild index on docs changes

## Suggested File Targets

- `lib/agent_jido/documentation/indexer.ex` (new)
- `lib/agent_jido/documentation/ask_ai.ex` (new)
- `lib/agent_jido_web/live/components/docs_ask_ai_component.ex` (new)
- `lib/agent_jido_web/components/jido/docs_components.ex` (button wiring)
- `lib/mix/tasks/docs.index.ex` (new)

## Acceptance Criteria

1. Ask AI button opens an interactive assistant.
2. Every answer includes at least one citation link to an existing docs page.
3. Assistant refuses unsupported questions outside indexed docs.
4. Reindex task updates results after docs content changes.

## Dependencies

- Recommended after `02_docs_search_cmdk.md`.
