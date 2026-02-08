# Step 1: Route → Layout → Theme Inventory

> Deliverable from [TOP_DOWN_REVIEW.md](TOP_DOWN_REVIEW.md) Step 1.
> Produced by auditing `router.ex`, all LiveViews, controllers, and their templates.

---

## Summary

The site has **three layout/theme stacks** in active use:

| Stack | Layout Component | Theme System | Token Style |
|-------|-----------------|--------------|-------------|
| **A — Marketing** | `MarketingLayouts.marketing_layout/1` | CSS custom properties + `.light` class | `bg-background`, `text-foreground`, `text-primary`, `text-muted-foreground` |
| **B — Workbench/Petal** | `WorkbenchLayout.workbench_layout/1` | Tailwind `dark:` variants + Petal color scale | `bg-white dark:bg-secondary-900`, `text-primary-600 dark:text-primary-500` |
| **C — Docs** | Custom (no layout wrapper — builds its own shell from `DocsComponents`) | CSS custom properties | Same tokens as Marketing |

---

## Complete Route Map

### Marketing Pages — `marketing_layout` + CSS Custom Properties ✅

| Route | Module | File |
|-------|--------|------|
| `/` | `JidoHomeLive` | `lib/agent_jido_web/live/jido_home_live.ex` |
| `/ecosystem` | `JidoEcosystemLive` | `lib/agent_jido_web/live/jido_ecosystem_live.ex` |
| `/getting-started` | `JidoGettingStartedLive` | `lib/agent_jido_web/live/jido_getting_started_live.ex` |
| `/examples` | `JidoExamplesLive` | `lib/agent_jido_web/live/jido_examples_live.ex` |
| `/benchmarks` | `JidoBenchmarksLive` | `lib/agent_jido_web/live/jido_benchmarks_live.ex` |
| `/partners` | `JidoPartnersLive` | `lib/agent_jido_web/live/jido_partners_live.ex` |

**Status:** These are fully ported to the new design system. No `dark:` variants used.

---

### Docs Pages — Custom Shell + CSS Custom Properties ✅

| Route | Module | File |
|-------|--------|------|
| `/docs` | `JidoDocsLive` (`:index`) | `lib/agent_jido_web/live/jido_docs_live.ex` |
| `/docs/*` | `JidoDocsLive` (`:show`) | `lib/agent_jido_web/live/jido_docs_live.ex` |

**Layout:** No shared layout wrapper. The [template](lib/agent_jido_web/live/jido_docs_live.html.heex) builds its own shell:
```
docs_header → docs_secondary_nav → [docs_sidebar | main content | docs_right_sidebar]
```

**Theme:** Uses CSS custom property tokens (`bg-background`, `text-foreground`, `bg-card`, `border-border`, etc.) — consistent with Marketing.

**Note:** Uses `DocsComponents` (`docs_header/1`, `docs_sidebar/1`, etc.) which are separate from the marketing header/footer. The docs header has its own nav links, search, and "Ask AI" button.

---

### Cookbook — `workbench_layout` + `dark:` Variants ⚠️

| Route | Module | File |
|-------|--------|------|
| `/cookbook` | `LivebookDemoLive` (`:index`) | `lib/agent_jido_web/live/livebook_demo_live.ex` |
| `/cookbook/*` | `LivebookDemoLive` (`:show`) | `lib/agent_jido_web/live/livebook_demo_live.ex` |

**Layout:** Uses `workbench_layout` (old Petal layout with sidebar menu).

**Theme:** Old `dark:` variants throughout the [template](lib/agent_jido_web/live/livebook_demo_live.html.heex):
- `bg-white dark:bg-secondary-900`
- `text-primary-600 dark:text-primary-500`
- `bg-secondary-100 dark:bg-secondary-800`

**Problem:** Cookbook is content pages (like docs) but uses the Workbench layout and old theme system. Should likely use docs layout or marketing layout.

---

### Blog — `workbench_layout` + `dark:` Variants ⚠️

| Route | Module | File |
|-------|--------|------|
| `/blog` | `BlogController` → `BlogHTML` | `lib/agent_jido_web/controllers/blog_controller.ex` |
| `/blog/:slug` | `BlogController` → `BlogHTML` | `lib/agent_jido_web/controllers/blog_html/show.html.heex` |
| `/blog/tags/:tag` | `BlogController` → `BlogHTML` | `lib/agent_jido_web/controllers/blog_html/tag.html.heex` |
| `/blog/search` | `BlogController` | Redirects to DuckDuckGo |
| `/feed` | `BlogController` | XML response (no layout) |

**Layout:** `BlogHTML` imports `workbench_layout` and all three templates wrap in `<.workbench_layout>`.

**Theme:** Old `dark:` variants throughout all templates:
- `bg-white dark:bg-secondary-900`
- `text-secondary-900 dark:text-white`
- `bg-secondary-200 dark:bg-secondary-800`
- `bg-primary-600 dark:bg-primary-600`

**Problem:** Blog is public-facing content and visually disconnects from the marketing pages. Should be migrated to `marketing_layout` or a blog-specific variant.

---

### Catalog — `workbench_layout` + `dark:` Variants ⚠️

| Route | Module | File |
|-------|--------|------|
| `/catalog` | `CatalogLive` | `lib/agent_jido_web/live/catalog/catalog_live.ex` |
| `/catalog/actions` | `CatalogActionsLive` | `lib/agent_jido_web/live/catalog/actions_live.ex` |
| `/catalog/actions/:slug` | `CatalogActionsLive` | (same file, `:show` action) |
| `/catalog/agents` | `CatalogAgentsLive` | `lib/agent_jido_web/live/catalog/agents_live.ex` |
| `/catalog/sensors` | `CatalogSensorsLive` | `lib/agent_jido_web/live/catalog/sensors_live.ex` |
| `/catalog/skills` | `CatalogSkillsLive` | `lib/agent_jido_web/live/catalog/skills_live.ex` |

**Layout:** All use `workbench_layout` with sidebar menu.

**Theme:** Heavy use of old `dark:` variants:
- `bg-white dark:bg-secondary-900`
- `text-primary-600 dark:text-primary-500`
- `border-secondary-200 dark:border-secondary-700`
- `bg-secondary-100 dark:bg-secondary-800`

**Note:** Catalog is public-facing (discoverable via nav). Uses Petal's `<.icon>` and `<.input>` components from `core_components.ex`.

---

### Settings — `workbench_layout` + `dark:` Variants ⚠️

| Route | Module | File |
|-------|--------|------|
| `/settings` | `SettingsLive` | `lib/agent_jido_web/live/settings_live.ex` |

**Theme:** `bg-secondary-50 dark:bg-secondary-950`, `text-primary-600 dark:text-primary-500`.

---

### Utility Routes (No Layout)

| Route | Module | Notes |
|-------|--------|-------|
| `/discord` | `PageController.discord/2` | Redirect to Discord invite link |
| `/feed` | `BlogController.feed/2` | XML RSS feed (no HTML layout) |

---

### Dead Code 🗑️

| Route | Module | File | Notes |
|-------|--------|------|-------|
| `/jido` (commented out) | `JidoLive` | `lib/agent_jido_web/live/jido_live.ex` | Entire module is commented out. Chat feature, never enabled. |
| `/live` (commented out) | `PageLive` | `lib/agent_jido_web/live/page_live.ex` | Petal component showcase. Route commented out in router. |
| `/form` (commented out) | `FormLive` | `lib/agent_jido_web/live/form_live.ex` | Petal form demo. Route commented out in router. |

**Recommendation:** Delete these three files. They are Petal boilerplate with no active routes.

---

## Visual Summary

```
Routes by Layout
═══════════════════════════════════════════════════════════════

marketing_layout (CSS vars)          workbench_layout (dark: variants)
─────────────────────────            ────────────────────────────────
/                                    /catalog
/ecosystem                           /catalog/actions[/:slug]
/getting-started                     /catalog/agents
/examples                            /catalog/sensors
/benchmarks                          /catalog/skills
/partners                            /settings
                                     /blog[/:slug]
                                     /blog/tags/:tag
                                     /cookbook[/*]

Custom shell (CSS vars)              Dead code (no route)
────────────────────────             ────────────────────
/docs                                JidoLive
/docs/*                              PageLive
                                     FormLive
```

---

## Key Findings

### 1. Clean Marketing/Workbench Split
6 marketing routes consistently use `marketing_layout` + CSS custom properties. 10 routes use `workbench_layout` + `dark:` variants. There is no accidental mixing within a single page.

### 2. Docs Is a Third System
`JidoDocsLive` uses **neither** layout wrapper. It builds its own shell directly from `DocsComponents`. The tokens are consistent with Marketing (CSS custom properties), but there's no shared layout code between docs and marketing pages — the header, footer, and nav are all separate implementations.

### 3. Cookbook Uses the Wrong Layout
`LivebookDemoLive` handles both `/cookbook` and (confusingly) some `/docs` routes via `get_route_tag/1`. It uses `workbench_layout` + old `dark:` theme classes, despite being content pages that should visually match the docs design.

### 4. Blog Uses the Wrong Layout
All blog templates (`index`, `show`, `tag`) use `workbench_layout` with old Petal-style `dark:` classes. Blog is public-facing content and should use the marketing design system.

### 5. Three Dead LiveView Modules
`JidoLive`, `PageLive`, and `FormLive` have their routes commented out in the router but the module files still exist. They are Petal boilerplate and can be safely deleted.

---

## Target State (Proposed)

| Route Group | Target Layout | Target Theme | Migration Effort |
|-------------|--------------|--------------|-----------------|
| Marketing (`/`, `/ecosystem`, etc.) | `marketing_layout` | CSS custom properties | None (already done) |
| Docs (`/docs/*`) | Docs shell (keep as-is, or wrap in `marketing_layout` + docs chrome) | CSS custom properties | S — Decision only |
| Cookbook (`/cookbook/*`) | `marketing_layout` or docs shell | CSS custom properties | M — Restyle templates |
| Blog (`/blog/*`) | `marketing_layout` | CSS custom properties | M — Restyle 3 templates |
| Catalog (`/catalog/*`) | `marketing_layout` or keep isolated | CSS custom properties | L — Restyle 5 LiveViews |
| Settings (`/settings`) | TBD (keep isolated or migrate) | CSS custom properties | S — 1 simple page |
| Dead code | Delete | — | S — Delete 3 files |

---

*This inventory feeds into Step 2 (Layout Strategy Decision) and Step 3 (Theme System Unification).*
