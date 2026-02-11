# 08 - Versioning, Docs Config, And Localization Foundation

Priority: P2
Outcome: Introduce a single docs config source to support versioning, nav governance, and future i18n.

## Why This Matters

Mintlify uses centralized config to define docs structure and behavior. Without a config source, nav and IA drift into template code and become hard to maintain.

## Current Codebase Findings

- Docs navigation is partially data-driven (`Documentation.menu_tree`) and partially hardcoded template/nav code:
  - data-driven: `lib/agent_jido_web/live/jido_docs_live.ex:130`
  - hardcoded tabs and header links: `lib/agent_jido_web/components/jido/docs_components.ex:75`
  - large hardcoded docs home sections: `lib/agent_jido_web/live/jido_docs_live.html.heex:70`
- Docs categories are currently flat and limited by source files:
  - `priv/documentation/docs/index.md`
  - `priv/documentation/docs/getting-started.livemd`

## Gap Statement

No single docs configuration file controls navigation, grouping, versions, badges, or localization strategy.

## Implementation Steps

1. Create docs config schema (Elixir map or external file):
   - sections
   - ordering policy
   - external links
   - feature toggles (Ask AI enabled, search mode, etc.)
2. Load config at compile time and merge with `Documentation.menu_tree`.
3. Refactor hardcoded docs landing sections into config-driven cards or generated sections.
4. Add versioning foundation:
   - URL strategy (`/docs/v1/...` or host/path strategy)
   - active version indicator in docs header
5. Add localization foundation:
   - reserved locale-aware path structure (`/docs/en/...`)
   - translation-ready metadata fields

## Suggested File Targets

- `config/docs.exs` (new) or `config/docs/*.exs`
- `lib/agent_jido/documentation/config.ex` (new)
- `lib/agent_jido_web/live/jido_docs_live.ex` (config integration)
- `lib/agent_jido_web/components/jido/docs_components.ex` (nav driven by config)

## Acceptance Criteria

1. Navigation and docs home IA are driven by one configuration source.
2. Adding a section does not require manual template edits in multiple files.
3. Versioning and locale path strategy are defined and test-covered, even if only one active version/locale exists.

## Dependencies

- Recommended after 01 through 05 are complete.
