# Step 2: Layout Strategy Decision

> Deliverable from [TOP_DOWN_REVIEW.md](TOP_DOWN_REVIEW.md) Step 2.
> Based on analysis of all three layout systems and owner decisions.

---

## Decisions

### Two Layouts, No More

The site will have exactly **two layout systems**:

| Layout | Purpose | Used By |
|--------|---------|---------|
| **Marketing Layout** | Full-width marketing pages | `/`, `/ecosystem`, `/getting-started`, `/examples`, `/benchmarks`, `/partners`, `/blog` |
| **Docs Layout** | Content pages with sidebar nav, secondary nav, right TOC | `/docs/*`, `/cookbook/*`, `/catalog/*` |

### What Gets Deleted

| Item | File(s) | Reason |
|------|---------|--------|
| `WorkbenchLayout` | `lib/agent_jido_web/components/workbench_layout.ex` | Replaced entirely — not deprecated, deleted |
| `Menu` | `lib/agent_jido_web/components/menu.ex` | Only used by WorkbenchLayout sidebar |
| `MenuItems` | `lib/agent_jido_web/menu_items.ex` | Only used by WorkbenchLayout sidebar |
| `menu.css` | `assets/css/menu.css` | Styles for deleted sidebar |
| `SettingsLive` | `lib/agent_jido_web/live/settings_live.ex` | Old page, delete |
| `JidoLive` | `lib/agent_jido_web/live/jido_live.ex` | Dead code (commented-out route) |
| `PageLive` | `lib/agent_jido_web/live/page_live.ex` | Dead code (commented-out route) |
| `FormLive` | `lib/agent_jido_web/live/form_live.ex` | Dead code (commented-out route) |

---

## Layout 1: Marketing Layout

**Component:** `MarketingLayouts.marketing_layout/1`
**File:** `lib/agent_jido_web/components/jido/marketing_layouts.ex`
**Theme:** CSS custom properties (`bg-background`, `text-foreground`, etc.)

**Structure:**
```
marketing_header (sticky, scroll-shrink, theme toggle, mobile menu)
  └─ main (flex-1, page content)
marketing_footer (6-column grid)
```

**Current consumers (no change needed):**
- `/` — `JidoHomeLive`
- `/ecosystem` — `JidoEcosystemLive`
- `/getting-started` — `JidoGettingStartedLive`
- `/examples` — `JidoExamplesLive`
- `/benchmarks` — `JidoBenchmarksLive`
- `/partners` — `JidoPartnersLive`

**Needs migration to marketing_layout:**
- `/blog`, `/blog/:slug`, `/blog/tags/:tag` — currently uses `workbench_layout` + `dark:` classes

---

## Layout 2: Docs Layout

**Components:** `DocsComponents.docs_header/1`, `docs_secondary_nav/1`, `docs_sidebar/1`, `docs_right_sidebar/1`
**File:** `lib/agent_jido_web/components/jido/docs_components.ex`
**Theme:** CSS custom properties (same token set as marketing)

**Structure:**
```
docs_header (sticky, own nav links, search, Ask AI)
  └─ docs_secondary_nav (tabbed: Get started | Packages | Agents | ...)
  └─ flex row:
       ├─ docs_sidebar (left, collapsible, section nav)
       ├─ main content (center, max-width)
       └─ docs_right_sidebar (right, TOC + quick links)
  └─ footer (minimal: last updated + edit link)
```

**Design relationship to marketing:** The docs layout is fundamentally different HTML structure (3-column with sidebar nav vs full-width), but should share visual DNA:
- Same CSS custom property tokens
- Could share some sub-components (nav link styles, social icons, logo treatment)
- Header and footer are intentionally different — docs header is denser/more functional

**Current consumers (no change needed):**
- `/docs`, `/docs/*` — `JidoDocsLive`

**Needs migration to docs layout:**
- `/cookbook`, `/cookbook/*` — currently uses `workbench_layout` via `LivebookDemoLive`
- `/catalog/*` — currently uses `workbench_layout` via 5 catalog LiveViews

---

## Migration Plan

### Phase 1: Delete dead code (no UI impact)
1. Delete `JidoLive`, `PageLive`, `FormLive` (dead routes)
2. Delete `SettingsLive` + remove route
3. Remove commented-out routes from `router.ex`

### Phase 2: Migrate Blog to marketing_layout
1. Update `BlogHTML` to import `MarketingLayouts` instead of `WorkbenchLayout`
2. Restyle 3 blog templates (`index`, `show`, `tag`) to use CSS custom property tokens
3. Remove all `dark:` variant classes from blog templates

### Phase 3: Migrate Cookbook to docs layout
1. Update `LivebookDemoLive` to use docs shell components instead of `workbench_layout`
2. Restyle template to use CSS custom property tokens
3. Integrate cookbook content into docs sidebar nav (or add a cookbook section)

### Phase 4: Migrate Catalog to docs layout
1. Update all 5 catalog LiveViews to use docs shell
2. Restyle from `dark:` variants to CSS custom property tokens
3. Add catalog sections to docs sidebar nav
4. Audit Petal component usage (`<.icon>`, `<.input>`) — keep `core_components` versions but drop Petal-specific styling

### Phase 5: Delete WorkbenchLayout stack
1. Delete `workbench_layout.ex`
2. Delete `menu.ex`, `menu_items.ex`
3. Delete `assets/css/menu.css`
4. Remove Petal `default.css` import if no remaining consumers
5. Clean up any remaining `dark:` utility classes

---

## Shared Component Opportunities

The two layouts could share these pieces (to be evaluated in Step 5/Step 7):

| Component | Currently In | Share? |
|-----------|-------------|--------|
| Logo mark (gradient "J" + "JIDO" text) | Both headers, independently | Extract to shared component |
| Social icons (GitHub, Discord, X, etc.) | `marketing_layouts.ex` private functions | Move to `Jido.UI` or shared module |
| Theme toggle | Marketing header (fixed position) | Could appear in both headers |
| `<.icon>` (Heroicons) | `core_components.ex` | Already shared |

---

*This decision doc feeds into Step 3 (Theme Unification), Step 5 (Header/Nav Consolidation), and Steps 10-11 (page-level migration).*
