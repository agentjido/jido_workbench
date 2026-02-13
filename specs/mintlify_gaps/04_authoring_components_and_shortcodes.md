# 04 - Authoring Components And Shortcodes

Priority: P1
Outcome: Move from plain markdown pages to reusable, composable docs primitives.

## Why This Matters

Mintlify docs scale because teams can compose content with consistent components (tabs, callouts, steps, cards) instead of repeating HTML snippets.

## Current Codebase Findings

- Markdown rendering is standard Earmark conversion through NimblePublisher:
  - `deps/nimble_publisher/lib/nimble_publisher.ex:127`
  - `lib/agent_jido/documentation.ex:17`
- Custom parser validates frontmatter but not rich content primitives:
  - `lib/agent_jido/documentation/livebook_parser.ex:151`
- Document bodies are rendered directly as raw HTML:
  - `lib/agent_jido_web/live/jido_docs_live.html.heex:31`
  - `lib/agent_jido_web/live/livebook_demo_live.html.heex:35`

## Gap Statement

The content pipeline supports metadata validation but not reusable docs UI primitives, making docs harder to maintain and less consistent.

## Implementation Steps

1. Define a minimal directive syntax for docs content (example):
   - `:::callout type=warning`
   - `:::tabs`
   - `:::steps`
2. Add a post-processing stage after markdown conversion:
   - parse directive blocks from generated HTML
   - map to consistent HTML classes used by site design system
3. Create a docs component style guide in markdown with examples.
4. Add lint rules for content:
   - invalid directive names
   - malformed directive parameters
   - nested directives that are unsupported
5. Apply to first docs pages:
   - `priv/documentation/docs/getting-started.livemd`
   - `priv/documentation/cookbook/*.livemd`

## Suggested File Targets

- `lib/agent_jido/documentation/html_post_processor.ex` (new)
- `lib/agent_jido/documentation/livebook_parser.ex` (directive validation hooks)
- `assets/css/app.css` (component styles)
- `priv/documentation/docs/authoring-guide.md` (new docs for writers)

## Acceptance Criteria

1. Authors can use at least `callout`, `tabs`, and `steps` without inline HTML.
2. Invalid directives fail fast during compile.
3. Rendered output is visually consistent between docs and cookbook pages.

## Dependencies

- Independent from P0 tasks, but should start after route/search trust issues are fixed.
