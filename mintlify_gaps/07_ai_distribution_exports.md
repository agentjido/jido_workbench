# 07 - AI Distribution Exports

Priority: P2
Outcome: Add machine-friendly docs exports (`llms.txt` and structured docs feeds) for AI tooling.

## Why This Matters

Mintlify emphasizes AI-consumable docs outputs. This improves indexing by agentic tools and allows deterministic ingestion by assistants.

## Current Codebase Findings

- No `llms.txt` found under static assets or routes.
- SEO and sitemap are present:
  - `priv/static/robots.txt:1`
  - `lib/agent_jido_web/controllers/sitemap_html/index.xml.eex:1`
- Documentation data is already structured and queryable:
  - `lib/agent_jido/documentation.ex:59`
  - `lib/agent_jido/documentation.ex:83`

## Gap Statement

You have human-facing discovery (`sitemap.xml`) but no AI-specific discovery or machine-readable docs export endpoint.

## Implementation Steps

1. Add static `llms.txt` route:
   - include canonical docs root
   - include key docs categories
   - include update cadence and contact
2. Add machine-readable docs index endpoint:
   - JSON endpoint containing `{title, path, description, tags, freshness}`
3. Add machine-readable docs page endpoint:
   - include plain text body and structured headings
4. Add ETag/Last-Modified caching for AI crawler efficiency.
5. Add CI check that generated exports include all published docs.

## Suggested File Targets

- `lib/agent_jido_web/router.ex` (new routes)
- `lib/agent_jido_web/controllers/docs_export_controller.ex` (new)
- `priv/static/llms.txt` (new) or dynamic controller
- `test/...` new export tests

## Acceptance Criteria

1. `GET /llms.txt` exists and is valid plain text.
2. `GET /docs/index.json` returns all published docs.
3. `GET /docs/page/<id>.json` returns structured content for ingestion.

## Dependencies

- Best after 05 so freshness and metadata fields are accurate.
