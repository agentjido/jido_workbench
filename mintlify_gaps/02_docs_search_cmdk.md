# 02 - Docs Search And Command Palette

Priority: P0
Outcome: Convert placeholder search UI into real docs search with keyboard-first UX.

## Why This Matters

Mintlify docs are strong because search is first-class. Users can jump directly to the right page or section without navigating hierarchy.

## Current Codebase Findings

- Search field in docs header is static UI only in `lib/agent_jido_web/components/jido/docs_components.ex:35`.
- `Cmd+K` hint is present but no keyboard handler exists in `assets/js/app.js:1`.
- There is a reusable modal component available in `lib/agent_jido_web/components/core_components.ex:49`.
- Docs content and metadata are already indexed in memory at compile time:
  - `lib/agent_jido/documentation.ex:28`
  - `lib/agent_jido/documentation.ex:31`
  - `lib/agent_jido/documentation.ex:35`

## Gap Statement

Search interaction exists visually but has no behavior, no index, and no results UI.

## Implementation Steps

1. Add a docs search index builder module (for example `AgentJido.Documentation.SearchIndex`) that builds records from:
   - title, description, tags, path
   - extracted headings from `doc.body`
2. Add `search(query)` API in the same module with simple scoring:
   - exact title match boost
   - prefix title/path boost
   - body heading and description fallback
3. Add search modal LiveComponent for docs:
   - open on click and `Cmd+K` or `Ctrl+K`
   - render top results grouped by category
   - arrow key navigation + Enter to navigate
4. Wire the static search control in `docs_components.ex` to open the modal.
5. Add telemetry events:
   - search opened
   - search query changed
   - result selected
   - no results

## Suggested File Targets

- `lib/agent_jido/documentation/search_index.ex` (new)
- `lib/agent_jido_web/live/components/docs_search_component.ex` (new)
- `lib/agent_jido_web/components/jido/docs_components.ex` (wire trigger)
- `assets/js/app.js` (keyboard shortcut hook)

## Acceptance Criteria

1. `Cmd+K` or `Ctrl+K` opens docs search from `/docs` and `/cookbook`.
2. Querying "getting started" returns `/docs/getting-started`.
3. Keyboard-only flow works (open, type, select, navigate).
4. No-results state is visible and tracked.

## Dependencies

- Best after `01_trust_and_route_parity.md`, so results never point at dead pages.
