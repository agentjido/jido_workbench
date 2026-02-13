# 05 - Metadata And SEO Surface Area

Priority: P1
Outcome: Use your existing document metadata model in page UX and page-level SEO tags.

## Why This Matters

Mintlify-quality docs expose freshness and ownership signals (updated dates, labels, context) and emit page-specific metadata for indexing and sharing.

## Current Codebase Findings

- Document schema already contains rich metadata:
  - freshness, quality, seo, audience, doc_type in `lib/agent_jido/documentation/document.ex:70`
  - computed reading time in `lib/agent_jido/documentation/document.ex:202`
- Docs page currently renders only title/description/body:
  - `lib/agent_jido_web/live/jido_docs_live.html.heex:23`
  - `lib/agent_jido_web/live/jido_docs_live.html.heex:31`
- Global SEO defaults are static:
  - `lib/agent_jido_web/seo.ex:27`
  - `lib/agent_jido_web/components/layouts/root.html.heex:39`
- Sitemap includes docs URLs but does not emit docs `lastmod` values from freshness metadata:
  - `lib/agent_jido_web/controllers/sitemap_html/index.xml.eex:51`

## Gap Statement

Metadata exists in the model but is mostly not surfaced in UI, SEO tags, or sitemap richness.

## Implementation Steps

1. Surface metadata on docs pages:
   - reading time
   - last reviewed / validation status
   - doc type and audience badge
2. Add page-level SEO assignment in docs LiveViews:
   - description from doc frontmatter
   - canonical URL from doc.seo.canonical_url if present
   - OG title/description/image fallbacks from doc metadata
3. Extend sitemap docs entries with `lastmod` using:
   - `freshness.last_refreshed_at` if present
   - fallback to source file mtime
4. Add docs metadata validation tests:
   - disallow empty descriptions on published docs
   - ensure noindex docs are intentionally marked

## Suggested File Targets

- `lib/agent_jido_web/live/jido_docs_live.ex`
- `lib/agent_jido_web/live/jido_docs_live.html.heex`
- `lib/agent_jido_web/live/livebook_demo_live.ex`
- `lib/agent_jido_web/controllers/sitemap_html/index.xml.eex`
- `test/agent_jido/documentation_test.exs`

## Acceptance Criteria

1. Docs pages show freshness and reading-time metadata.
2. SEO tags are per-page instead of generic-only defaults.
3. Sitemap docs entries include `lastmod`.

## Dependencies

- None, but best value after route/search fixes.
