# Step 11: Catalog & Blog Migration Plan

> Deliverable from [TOP_DOWN_REVIEW.md](TOP_DOWN_REVIEW.md) Step 11.
> Decides whether `/catalog`, `/blog`, and `/cookbook` should adopt the new design system.

**Decision: Yes — all three migrate.** Blog → marketing_layout. Catalog + Cookbook → docs layout.

---

## 1. Current State Audit

### 1.1 `dark:` Variant Class Counts

| File | `dark:` count |
|------|--------------|
| `catalog_live.ex` | 14 |
| `actions_live.ex` | 44 |
| `agents_live.ex` | 20 |
| `sensors_live.ex` | 20 |
| `skills_live.ex` | 20 |
| **Catalog total** | **118** |
| `blog_html/index.html.heex` | 37 |
| `blog_html/show.html.heex` | 11 |
| `blog_html/tag.html.heex` | 40 |
| **Blog total** | **88** |
| `livebook_demo_live.html.heex` | 30 |
| **Cookbook total** | **30** |
| `workbench_layout.ex` | 55 |
| `menu.css` (`.dark` selectors) | 5 |
| **Grand total** | **296** |

### 1.2 PetalComponents Usage

| Module | Petal dependency | Notes |
|--------|-----------------|-------|
| `WorkbenchLayout` | `use PetalComponents` | Full import; only uses `<.icon>` (already in core_components) |
| `Menu` | `import PetalComponents.Link` | Uses `<.a>` link component |
| Catalog LiveViews | None directly | Uses `<.icon>` and `<.input>` from core_components |
| Blog templates | None directly | Plain HTML + `<.workbench_layout>` wrapper |
| Cookbook LiveView | None directly | Uses `<.icon>`, `<.link>` from core_components |

**Only `workbench_layout.ex` and `menu.ex` import Petal directly.** All catalog/blog/cookbook pages use core_components functions (`<.icon>`, `<.input>`, `<.link>`), which will continue to work.

### 1.3 WorkbenchLayout Dependencies

| Consumer | Uses sidebar? | Uses nav_bar? | Uses footer? |
|----------|:---:|:---:|:---:|
| 5 Catalog LiveViews | ✅ (`show_menu` default true) | ✅ | ✅ |
| 3 Blog templates | ❌ (`show_menu={false}`) | ✅ | ✅ |
| Cookbook (`LivebookDemoLive`) | ✅ | ✅ | ✅ |

WorkbenchLayout internal deps: `Menu.vertical_menu/1` → `MenuItems.menu_items/0` → `AgentJido.Documentation.menu_tree/0`.

### 1.4 Template Complexity

| File | LOC | Sections | Notes |
|------|-----|----------|-------|
| `catalog_live.ex` | 87 | 1 (card grid) | Simple, private `catalog_card/1` component |
| `actions_live.ex` | 388 | 2 (list + detail panel) | Most complex; search, detail view with schema params. ~210 LOC commented-out. |
| `agents_live.ex` | 170 | 2 (list + detail panel) | Simpler detail view. ~40 LOC commented-out. |
| `sensors_live.ex` | 170 | 2 (list + detail panel) | Same structure as agents. |
| `skills_live.ex` | 170 | 2 (list + detail panel) | Same structure as agents. |
| `blog_html/index.html.heex` | 126 | 3 (post list, search sidebar, tags) | Inline SVG social icons |
| `blog_html/show.html.heex` | 46 | 2 (back link, article) | Simplest template |
| `blog_html/tag.html.heex` | 143 | 3 (post list, tags sidebar, social) | Nearly identical to index |
| `livebook_demo_live.html.heex` | 142 | 3 (content, index grid, TOC sidebar) | Already has its own sidebar TOC |
| `livebook_demo_live.ex` | 309 | N/A (logic only) | TOC builder, menu builder, document routing |

---

## 2. Migration Decisions

### 2.1 Blog → `marketing_layout`

**Why:** Blog is a full-width content page with no sidebar nav. Marketing layout provides header, footer, and theme support. Blog already passes `show_menu={false}`.

**Effort: S (Small)**

**Steps:**
1. In `blog_html.ex`: replace `import AgentJidoWeb.WorkbenchLayout, only: [workbench_layout: 1]` with `import AgentJidoWeb.Jido.MarketingLayouts, only: [marketing_layout: 1]`
2. In all 3 templates: replace `<.workbench_layout current_page={:blog} show_menu={false}>` with `<.marketing_layout current_path="/blog">`
3. Replace all `dark:` variant classes with CSS custom property equivalents:
   - `bg-white dark:bg-secondary-900` → `bg-card`
   - `text-secondary-900 dark:text-white` → `text-foreground`
   - `text-secondary-600 dark:text-secondary-400` → `text-muted-foreground`
   - `text-primary-600 dark:text-primary-500` → `text-primary`
   - `bg-secondary-200 dark:bg-secondary-800` → `bg-muted`
   - `border-secondary-200 dark:border-secondary-800` → `border-border`
   - `bg-primary-600 dark:bg-primary-600` → `bg-primary`
   - `hover:bg-primary-700 dark:hover:bg-primary-700` → `hover:bg-primary/90`
   - `prose dark:prose-invert` → `prose` (works with CSS custom properties)
   - `bg-secondary-100 dark:bg-secondary-800` → `bg-elevated`
   - `placeholder-secondary-500 dark:placeholder-secondary-400` → `placeholder-muted-foreground`
   - `fill-secondary-600 dark:fill-secondary-400` → `fill-muted-foreground`
4. Remove inline SVG social icons from blog templates — use `Nav.social_icon/1` or keep inline but simplify color classes
5. Verify closing tags match: `</.marketing_layout>`

### 2.2 Cookbook → Docs Layout

**Why:** Cookbook already has sidebar TOC and content structure matching docs layout. It currently builds its own TOC in `livebook_demo_live.ex` which maps well to `docs_right_sidebar`.

**Effort: M (Medium)**

**Steps:**
1. In `livebook_demo_live.ex`: replace `import AgentJidoWeb.WorkbenchLayout` with `import AgentJidoWeb.Jido.DocsComponents`
2. Restructure template to use docs shell:
   - Replace `<.workbench_layout>` wrapper with `<.docs_header>` + `<.docs_secondary_nav>` + flex row
   - Move existing TOC sidebar to use `<.docs_right_sidebar toc={@document_content.toc}>`
   - Replace left sidebar menu with `<.docs_sidebar nav={@menu_items} current_path={@current_path}>`
3. Convert menu_items format: current `build_document_menu/1` returns `%{label, menu_items: [%{label, path, icon, description}]}` — needs to output `%{title, items: [%{label, href}]}` to match `docs_sidebar` expectations
4. Replace all 30 `dark:` classes with CSS custom property tokens (same mapping as blog)
5. Add `@current_path` assign in `handle_params/3` (not currently tracked)
6. Add cookbook tab to `docs_secondary_nav` or make secondary nav configurable

### 2.3 Catalog → Docs Layout

**Why:** Catalog has a list+detail panel structure that maps to docs sidebar + content. Currently uses WorkbenchLayout sidebar for navigation between catalog sections.

**Effort: L (Large)**

**Steps:**
1. In all 5 catalog LiveViews: replace `import AgentJidoWeb.WorkbenchLayout` with `import AgentJidoWeb.Jido.DocsComponents`
2. Build catalog sidebar nav data:
   ```elixir
   [
     %{title: "CATALOG", items: [
       %{label: "Overview", href: "/catalog"},
       %{label: "Actions", href: "/catalog/actions"},
       %{label: "Agents", href: "/catalog/agents"},
       %{label: "Sensors", href: "/catalog/sensors"},
       %{label: "Skills", href: "/catalog/skills"}
     ]}
   ]
   ```
3. Restructure each template to use docs shell:
   - `<.docs_header>` + `<.docs_secondary_nav>` + flex row with `<.docs_sidebar>`
   - Content goes in center column
   - Optional: item-level detail in right sidebar
4. Replace 118 `dark:` classes across 5 files with CSS custom property tokens
5. `catalog_live.ex` (overview): straightforward card grid, minimal effort
6. `actions_live.ex`: most complex — has its own left panel (item list) + right panel (detail). Two options:
   - **Option A:** Keep existing two-panel layout inside the docs content area (sidebar = catalog nav, content = list+detail)
   - **Option B:** Use docs_sidebar for item list, content for detail (bigger restructure)
   - **Recommendation: Option A** — less risk, preserves search/filter UX
7. `agents_live.ex`, `sensors_live.ex`, `skills_live.ex`: same structure, apply same pattern
8. `<.input>` component: currently uses core_components version — keep as-is, only restyle container classes

---

## 3. WorkbenchLayout Deletion Plan

### Deletion Dependency Graph

```
Blog templates ──┐
Catalog pages ───┤── all use ──▶ WorkbenchLayout ──▶ Menu ──▶ MenuItems
Cookbook page ────┘                    │                          │
                                      │                          │
                                      ▼                          ▼
                              PetalComponents            Documentation.menu_tree()
                                      │
                                      ▼
                                 menu.css
```

### Phase-by-Phase Deletion

| After migrating | Can delete | Cannot yet delete |
|-----------------|-----------|-------------------|
| Blog (Phase 2) | Nothing — catalog & cookbook still depend on WorkbenchLayout | WorkbenchLayout, Menu, MenuItems, menu.css |
| Cookbook (Phase 3) | Nothing — catalog still depends | WorkbenchLayout, Menu, MenuItems, menu.css |
| Catalog (Phase 4) | **Everything:** WorkbenchLayout, Menu, MenuItems, menu.css | — |

**After all 3 migrations (Phase 5), delete:**

| File | Lines |
|------|-------|
| `lib/agent_jido_web/components/workbench_layout.ex` | 198 |
| `lib/agent_jido_web/components/menu.ex` | 137 |
| `lib/agent_jido_web/menu_items.ex` | 101 |
| `assets/css/menu.css` | 92 |
| **Total deleted** | **528 LOC** |

---

## 4. CSS Cleanup Plan

### After Each Phase

| Phase | CSS action |
|-------|-----------|
| Phase 2 (Blog) | No CSS changes yet — legacy shim still needed |
| Phase 3 (Cookbook) | No CSS changes yet |
| Phase 4 (Catalog) | No CSS changes yet |
| Phase 5 (Delete WorkbenchLayout) | Remove `@import "./menu.css"` from `app.css` |
| Phase 6 (Final cleanup) | See checklist below |

### Phase 6: Final CSS Cleanup Checklist

After all WorkbenchLayout consumers are migrated and deleted:

1. **Remove `@import "./menu.css"`** from `assets/css/app.css` (line 10)
2. **Delete `assets/css/menu.css`** (92 lines, 5 `.dark` selectors)
3. **Remove `@custom-variant dark`** from `assets/css/app.css` (line 37) — only needed by legacy `dark:` classes
4. **Remove `@theme inline` Petal compat shim** from `assets/css/app.css` (lines 48–192) — the `primary-600`, `secondary-400` etc. color scale mappings
5. **Remove `@import "../../deps/petal_components/assets/default.css"`** from `assets/css/app.css` (line 8) — BUT first verify `core_components.ex` (imports `PetalComponents.Icon`) and `agent_jido_web.ex` (`use PetalComponents`) don't need it
6. **Remove `@source "../../deps/petal_components/**/*.*ex"`** from `assets/css/app.css` (line 3) — only if Petal dependency is fully removed
7. **Grep for remaining `dark:` classes** across all `*.ex` and `*.heex` files — should be zero

### Petal Dependency Removal (separate from this step)

`PetalComponents` is still used by:
- `core_components.ex` — `import PetalComponents.Icon` (for `<.icon>`)
- `agent_jido_web.ex` — `use PetalComponents` in the `html` macro

Removing PetalComponents entirely is a separate task that requires auditing all core_components usage. Not in scope for Step 11.

---

## 5. Recommended Migration Order

1. **Blog** (Small) — lowest risk, no sidebar, fewest files
2. **Cookbook** (Medium) — already has docs-like structure
3. **Catalog** (Large) — most files, most `dark:` classes, most complex templates
4. **Delete WorkbenchLayout stack** — only after all 3 are done
5. **CSS cleanup** — remove legacy shim, menu.css, dark variant

Total estimated `dark:` replacements: **296** across all files (including WorkbenchLayout itself which gets deleted, so effectively **236** to manually convert).
