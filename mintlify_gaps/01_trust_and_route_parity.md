# 01 - Trust And Route Parity

Priority: P0
Outcome: Remove dead docs links and make the docs landing page content-driven.

## Why This Matters

Mintlify-quality docs fail closed on navigation integrity. If a user clicks a docs card and lands on a redirect or error, trust drops immediately.

## Current Codebase Findings

- Docs routes are generated from files at compile time in `lib/agent_jido_web/router.ex:9`.
- Actual docs content under `/docs` currently maps to two files:
  - `priv/documentation/docs/index.md`
  - `priv/documentation/docs/getting-started.livemd`
- Docs landing page hardcodes many links to pages that do not exist in current docs content:
  - Examples: `lib/agent_jido_web/live/jido_docs_live.html.heex:81`, `lib/agent_jido_web/live/jido_docs_live.html.heex:93`, `lib/agent_jido_web/live/jido_docs_live.html.heex:209`, `lib/agent_jido_web/live/jido_docs_live.html.heex:216`
- Missing pages are currently handled by flash + redirect back to `/docs` in `lib/agent_jido_web/live/jido_docs_live.ex:61`.

## Gap Statement

Navigation IA in the docs home is out of sync with route generation and source content, causing dead-link behavior.

## Implementation Steps

1. Replace hardcoded docs-card links on the `/docs` landing page with links generated from `Documentation.all_documents_by_category(:docs)` from `lib/agent_jido/documentation.ex:127`.
2. Keep only non-doc marketing links hardcoded (for example `/examples`, `/benchmarks`).
3. Introduce a helper in `AgentJidoWeb.JidoDocsLive` to derive docs sections from `Documentation.menu_tree/0` (`lib/agent_jido/documentation.ex:83`) instead of static card destinations.
4. Add a CI test that parses docs templates and verifies every internal `/docs/...` link exists in router-generated docs routes.
5. Add a second test that ensures docs home only renders links for docs that exist in `Documentation.all_documents/0`.

## Suggested Test Additions

- File: `test/agent_jido/documentation_test.exs`
- New tests:
  - `docs home internal links resolve to known docs routes`
  - `no orphan docs routes in docs landing`

## Acceptance Criteria

1. Clicking any internal `/docs/...` link from `/docs` never redirects to "Document not found".
2. Route additions/removals in `priv/documentation/docs` are automatically reflected in `/docs` navigation without manual template edits.
3. CI fails if a dead internal docs link is introduced.

## Dependencies

- None. This should be first.
