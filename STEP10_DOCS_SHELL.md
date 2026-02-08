# Step 10 — Docs Shell Audit

## 1. Docs Shell Contract

### Layout Structure

```
┌─────────────────────────────────────────────────────┐
│  docs_header (sticky top-0, z-50)                   │
├─────────────────────────────────────────────────────┤
│  docs_secondary_nav (border-b tabs)                 │
├──────────┬────────────────────────────┬─────────────┤
│ sidebar  │  main content              │ right_sidebar│
│ 260px    │  max-w-[900px]             │ 200px        │
│ lg:block │  + footer inside <main>    │ xl:block     │
│ sticky   │                            │ sticky       │
│ top-105  │                            │ top-105      │
└──────────┴────────────────────────────┴─────────────┘
```

### Required Assigns by Action

| Assign             | `:index`                                 | `:show`                                | Source          |
|--------------------|------------------------------------------|----------------------------------------|-----------------|
| `page_title`       | `"Jido Documentation"`                   | `doc.title`                            | `handle_params` |
| `request_path`     | URI path                                 | URI path                               | `handle_params` |
| `sidebar_open`     | `true` (from mount)                      | `true` (from mount)                    | `mount`         |
| `documents`        | `all_documents_by_category(:docs)`       | `all_documents_by_category(:docs)`     | `handle_params` |
| `selected_document`| `nil`                                    | `%Document{}`                          | `handle_params` |
| `toc`              | Hardcoded list of 6 items                | **BUG: not assigned at top level**     | `handle_params` |
| `document_content` | **not assigned**                         | `%{html: ..., toc: ...}`              | `handle_params` |

---

## 2. Findings

### Concern 1: Do all docs components render in both `:index` and `:show`?

**Partially.** The template (`jido_docs_live.html.heex`) renders all four shell components in both actions:

| Component            | `:index` | `:show` | Notes |
|----------------------|----------|---------|-------|
| `docs_header`        | ✅       | ✅      | Uses `@request_path` |
| `docs_secondary_nav` | ✅       | ✅      | Uses `@request_path` |
| `docs_sidebar`       | ✅       | ✅      | Uses `sidebar_nav()`, `@request_path`, `@sidebar_open` |
| `docs_right_sidebar` | ⚠️       | ❌ **BUG** | Guarded by `@toc`, which is not assigned in `:show` |

**Bug detail:** `handle_show/2` puts the TOC inside `document_content.toc` (line 74) but never assigns a top-level `:toc` key. The template checks `@toc` (line 360). Behavior depends on navigation path:
- **Direct navigation to `/docs/getting-started`** → `@toc` was never assigned → `KeyError` crash
- **Navigate from `/docs` → `/docs/getting-started`** → `@toc` retains stale index TOC → wrong TOC displayed on the right sidebar

### Concern 2: `build_toc/1` returns flat list with `children: []`

The right sidebar (`docs_right_sidebar`) iterates `@toc` as a flat list and never accesses `.children`, so the empty `children: []` field is harmless. However, `build_toc/1` includes `h1` tags alongside `h2`/`h3`, producing mixed heading levels with no indentation. The React reference `DocsRightSidebar.tsx` also renders a flat list with no nesting, so this matches the reference.

**No functional issue, but:**
- `children: []` is dead data — either remove it or implement hierarchical nesting later
- Including `h1` is unusual; typically only `h2`/`h3` appear in a "On This Page" sidebar

### Concern 3: `sidebar_nav/0` is hardcoded; many listed pages may not exist

**Critical finding.** Only 2 documents exist under `priv/documentation/docs/`:

| File                       | Path (derived) |
|---------------------------|----------------|
| `docs/index.md`           | `/docs`        |
| `docs/getting-started.livemd` | `/docs/getting-started` |

The sidebar lists **32 internal hrefs** across 7 sections. **30 of 32 links point to nonexistent documents.** Clicking any of these will trigger the `handle_show` error path → flash "Document not found" → redirect to `/docs`.

Additionally, `sidebar_nav/0` has no entry for `/docs/getting-started` — the only real document page besides the index is missing from the sidebar.

| Sidebar Section       | # Links | # Existing | Missing Examples |
|-----------------------|---------|------------|------------------|
| Getting Started       | 5       | 1 (`/docs`) | installation, quickstart, concepts, production-checklist |
| Packages              | 7       | 0          | all missing |
| Agents                | 5       | 0          | all missing |
| Actions & Signals     | 4       | 0          | all missing |
| AI & LLMs             | 5       | 0          | all missing |
| Production            | 5       | 0          | all missing |
| Reference             | 4       | 0 internal | `/benchmarks` goes to a different LiveView; API Reference is external |

### Concern 4: Sidebar toggle (`toggle_sidebar`) state persistence across navigation

**Does not persist across full page loads** but does persist across LiveView patch navigation.

- `sidebar_open` is initialized to `true` in `mount/3` (line 8)
- `toggle_sidebar` event flips the boolean (line 125)
- `handle_params` does not reassign `sidebar_open`, so it survives patch navigations within the same LiveView
- A full page refresh resets to `true`
- The React reference also uses `useState(false)` with no persistence, so this matches

**Minor difference:** The React sidebar defaults to **expanded** (`useState(false)` for `sidebarCollapsed`), matching Phoenix's `sidebar_open: true`.

### Concern 5: React reference comparison

See Section 4 below.

---

## 3. Issues & Recommended Fixes

### P0 — Critical

| # | Issue | File | Fix |
|---|-------|------|-----|
| 1 | **`@toc` not assigned in `:show` action** — causes `KeyError` on direct navigation or stale TOC on patch navigation | `jido_docs_live.ex` line 69–75 | Add `toc: toc` to the assign map in `handle_show`, alongside `document_content` |
| 2 | **30 of 32 sidebar links are dead** — no matching documents exist | `jido_docs_live.ex` `sidebar_nav/0` | Either (a) create stub documents for all sidebar entries, or (b) generate sidebar from `Documentation.menu_tree()` instead of hardcoding |

### P1 — Functional

| # | Issue | File | Fix |
|---|-------|------|-----|
| 3 | **`/docs/getting-started` not in sidebar** — the only real doc page is unreachable from nav | `jido_docs_live.ex` `sidebar_nav/0` | Add entry or switch to dynamic sidebar |
| 4 | **No breadcrumb component** — React reference has `DocsBreadcrumb`, Phoenix shell does not | `jido_docs_live.html.heex` | Port `DocsBreadcrumb` component; `Documentation.breadcrumbs_with_docs/1` already exists |
| 5 | **No prev/next navigation** — React reference has `DocsPrevNext`, Phoenix shell does not | `jido_docs_live.html.heex` | Port `DocsPrevNext` component; `Documentation.neighbors/1` already exists |
| 6 | **`document_content` assign unused** — assigned in `:show` but template reads `@selected_document.body` directly, never `@document_content` | `jido_docs_live.ex` line 74, template line 32 | Remove `document_content` assign or refactor template to use it |
| 7 | **Sidebar sections always open** — no expand/collapse on section headers despite chevron icon being rendered | `docs_components.ex` line 129–132 | Add `phx-click` handler for section toggle, track open sections in assigns (React ref uses `openSections` Set) |

### P2 — Polish

| # | Issue | File | Fix |
|---|-------|------|-----|
| 8 | **No active-heading tracking in right sidebar** — React ref uses `IntersectionObserver` to highlight current heading | `docs_components.ex` `docs_right_sidebar` | Add JS hook for scroll-spy |
| 9 | **`build_toc` includes `h1`** — "On This Page" typically only shows `h2`/`h3` | `jido_docs_live.ex` line 90 | Change Floki selector to `"h2, h3"` |
| 10 | **`children: []` dead field in TOC items** | `jido_docs_live.ex` line 107 | Remove `children` key from build_toc output |
| 11 | **Right sidebar missing `githubPath` / `livebookUrl` props** — React ref has per-page edit and Livebook links | `docs_components.ex` | Add `github_path` and `livebook_url` attrs to `docs_right_sidebar` |
| 12 | **Footer `w-full` but no max-width** — unlike main content which is `max-w-[900px]` | `jido_docs_live.html.heex` line 344 | Match footer width to content area |
| 13 | **Header nav links render raw paths** (e.g., `docs` not `/docs`) — `String.replace_prefix(item, "/", "")` strips the `/` | `docs_components.ex` line 28 | Keep the leading `/` to match React reference (`/{item.label}`) |

---

## 4. React Reference Comparison

### DocsLayout.tsx vs jido_docs_live.html.heex

| Feature | React Reference | Phoenix Implementation | Match? |
|---------|----------------|----------------------|--------|
| Overall structure (header → secondary → sidebar + content + right) | ✅ | ✅ | ✅ |
| `DocsBreadcrumb` between secondary nav and content | ✅ | Missing | ❌ |
| `DocsPrevNext` at bottom of content area | ✅ | Missing | ❌ |
| Footer inside `<main>` | ✅ | ✅ | ✅ |
| `DocsRightSidebar` always rendered (handles empty TOC internally) | ✅ | Conditionally rendered with `if @toc` | ❌ |
| `DocsSearch` (⌘K modal) | Functional component | Static placeholder div | ❌ |
| `DocsAskAI` | Functional component | Static button | ❌ |
| `DocsFooter` (full site footer) | Rich multi-column footer | Minimal inline footer | ⚠️ |
| Sidebar section collapse/expand | Functional with state | Visual only (chevron rendered, no toggle) | ❌ |
| Sidebar auto-opens section containing active item | ✅ | All sections always open | ❌ |
| Right sidebar scroll-spy (active heading highlight) | `IntersectionObserver` | None | ❌ |
| Right sidebar "Edit this page" link | Per-page `githubPath` | Hardcoded single URL | ⚠️ |
| Content max-width | `max-w-[900px]` | `max-w-[900px]` | ✅ |
| Sidebar width | `w-[260px]` | `w-[260px]` | ✅ |
| Right sidebar width | `w-[200px]` | `w-[200px]` | ✅ |
| Sticky offset | `top-[105px]` | `top-[105px]` | ✅ |
| Sidebar breakpoint | `lg:block` | `lg:block` | ✅ |
| Right sidebar breakpoint | `xl:block` | `xl:block` | ✅ |

### Summary

The Phoenix shell faithfully reproduces the **static layout geometry** (widths, breakpoints, sticky offsets, color tokens) from the React reference. The gaps are entirely in **interactive behavior** (breadcrumbs, prev/next, search modal, section collapse, scroll-spy) and **data correctness** (stale/missing `@toc`, dead sidebar links).
