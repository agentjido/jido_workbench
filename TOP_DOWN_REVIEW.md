# Top-Down Front-End Review Plan

This document maps out a sequential review of the AgentJido Workbench front-end after porting the updated design from `jido-dev-relaunch/` (React/Vite prototype) into the Phoenix LiveView app. Each step is a self-contained topic that can be tackled by a focused subagent.

---

## Current State Summary

The site has **two competing UI stacks** living side-by-side:

| Stack | Layout | Theming | Used By |
|-------|--------|---------|---------|
| **A) Workbench/Petal** | `WorkbenchLayout.workbench_layout/1` | Tailwind `dark:` variants + PetalComponents | `/catalog/*`, `/settings` |
| **B) Marketing/Docs** | `MarketingLayouts.marketing_layout/1` | CSS custom properties + `.light` class | `/`, `/ecosystem`, `/getting-started`, `/examples`, `/benchmarks`, `/partners` |
| **C) Docs** | Custom (DocsComponents) | CSS custom properties | `/docs`, `/docs/*` |

### Global Duplication Hotspots

1. **Two layout shells**: `WorkbenchLayout.workbench_layout/1` vs `MarketingLayouts.marketing_layout/1`
2. **Three headers**: `WorkbenchLayout.nav_bar/1`, `MarketingLayouts.marketing_header/1`, `DocsComponents.docs_header/1`
3. **Two sidebar/menu systems** + duplicated nav data: `MenuItems/Menu` vs `JidoDocsLive.sidebar_nav + DocsComponents.docs_sidebar`
4. **Duplicate card components**: `DocsComponents.{numbered_card, icon_card}` vs `UI.{numbered_card, icon_card}`
5. **Multiple theme toggles**: `ColorSchemeHook` (+ cookie) vs `ThemeToggle` hook
6. **Font inconsistency**: `root.html.heex` loads Inter/JetBrains Mono/VT323; `app.css` imports IBM Plex Mono
7. **JS hook drift**: `CopyCode` vs `data-copy-button`; scroll hooks; old theme switch files
8. **Legacy CSS**: Petal `default.css` + `menu.css` hard-coded colors + `dark:` utilities alongside CSS custom properties

---

## Review Steps

### Step 1: Route → Layout Inventory

**Goal:** Produce a definitive map of every route and which layout/theme system it uses.

**Files:**
- `lib/agent_jido_web/router.ex`
- All LiveViews in `lib/agent_jido_web/live/`
- Controllers in `lib/agent_jido_web/controllers/`

**What to look for:**
- Which layout each page imports and wraps with (`marketing_layout`, `workbench_layout`, or docs-specific)
- Pages using old `dark:` class patterns vs CSS custom property tokens
- Whether blog controller pages have any layout wrapper at all

**Deliverable:** A route → layout → theme table showing current state and target state.

**Effort:** S (~30min)

---

### Step 2: Layout Strategy Decision

**Goal:** Establish explicit rules for when to use which layout; prevent a third hybrid from emerging.

**Files:**
- `lib/agent_jido_web/components/workbench_layout.ex`
- `lib/agent_jido_web/components/jido/marketing_layouts.ex`
- `lib/agent_jido_web/components/layouts.ex` + `layouts/app.html.heex`

**What to look for:**
- Overlapping responsibilities (both define header + nav + footer)
- Whether `WorkbenchLayout` is still needed or can be deprecated
- Whether docs needs its own layout wrapper or can use `marketing_layout` + docs header

**Deliverable:** A "Layout Decision" declaration:
- Primary layout for marketing pages
- Docs layout approach (specialized or marketing + docs chrome)
- Workbench: migrate or isolate

**Effort:** S (~30min)

---

### Step 3: Theme System Unification

**Goal:** Eliminate split-brain theme handling (`.dark` class + `dark:` variants vs CSS variables + `.light` class).

**Files:**
- `lib/agent_jido_web/components/layouts/root.html.heex`
- `assets/css/app.css` (`:root` and `.light` token blocks)
- `lib/agent_jido_web/components/core_components.ex` (`.color_scheme_switch_js`, `.color_scheme_switch`)
- `lib/agent_jido_web/components/jido/marketing_layouts.ex` (`ThemeToggle` hook buttons)
- `assets/js/hooks/color-scheme-hook.js`
- `assets/js/app.js`

**What to look for:**
- `core_components.ex` toggles `.dark` on `<html>`; `app.css` defines overrides on `.light`
- Which hook is canonical: `ThemeToggle` vs `ColorSchemeHook`
- Whether AlpineJS and js-cookie are still needed (comments suggest legacy theme switch)
- `@custom-variant dark` in `app.css` — is it needed alongside CSS vars?

**Deliverable:** A single "theme contract":
- Which class controls mode (`.light` recommended given CSS vars)
- Which hook is canonical
- What to remove (cookie lib, Alpine, dead hooks)

**Effort:** M (~1-2h)

---

### Step 4: Root Layout & Asset Hygiene

**Goal:** Clean up `root.html.heex` to match the new design system. Remove dead/contradictory asset loads.

**Files:**
- `lib/agent_jido_web/components/layouts/root.html.heex`
- `lib/agent_jido_web/components/layouts/app.html.heex`
- `assets/css/app.css`
- `assets/js/app.js`

**What to look for:**
- **Fonts:** root loads Inter + JetBrains Mono + VT323 via Google Fonts; `app.css` imports IBM Plex Mono and uses it as `--font-mono`. Decide which monospace font is canonical.
- **Scripts:** AlpineJS (`unpkg.com/alpinejs`) — confirm no component uses `x-` directives. If not, remove.
- **Scripts:** js-cookie (`unpkg.com/js-cookie`) — only needed if legacy theme code uses `Cookies.get/set`. If `ThemeToggle` uses `localStorage`, remove.
- **Body classes:** `class="antialiased font-mono"` — `font-mono` maps to the Tailwind mono stack; reconcile with `app.css` body `font-family` rule.

**Deliverable:** List of exact tags to remove/keep with rationale.

**Effort:** S-M (~1h)

---

### Step 5: Header/Nav/Footer Consolidation

**Goal:** Reduce three competing nav implementations to a clear, minimal set.

**Files:**
- `lib/agent_jido_web/components/workbench_layout.ex` — `nav_bar/1` + inline footer
- `lib/agent_jido_web/components/jido/marketing_layouts.ex` — `marketing_header/1`, `marketing_footer/1`
- `lib/agent_jido_web/components/jido/docs_components.ex` — `docs_header/1`
- Reference: `jido-dev-relaunch/src/components/layout/Header.tsx`, `Footer.tsx`

**What to look for:**
- **Inconsistent link sets:**
  - Workbench nav: `/docs`, `/cookbook`, `/catalog`, `/blog` + GitHub/Discord/Twitter
  - Marketing nav: `/ecosystem`, `/partners`, `/examples`, `/benchmarks`, `/docs` + Premium Support + CTA
  - Docs header: `/docs`, `/examples`, `/benchmarks`, `/ecosystem` + Search + Ask AI + GitHub/Hex
- **Duplicated social icons:** SVG icons in `WorkbenchLayout.nav_bar` vs icon functions in `marketing_layouts.ex`
- **GitHub stars:** only in Workbench nav; marketing has no equivalent
- **Theme toggle placement:** fixed position in marketing header vs inline in workbench nav
- **Mobile menu:** marketing has `JS.toggle` mobile menu; workbench has none

**Deliverable:** A "Navigation Model" defining:
- Canonical nav links for marketing pages
- Docs header: share link constants + theme toggle
- Decision on Workbench nav: deprecate, migrate, or intentionally separate

**Effort:** M (~2h)

---

### Step 6: Sidebar & Menu Systems

**Goal:** Consolidate sidebar approaches; remove dead code paths.

**Files:**
- `lib/agent_jido_web/menu_items.ex` — dynamic menu from `Documentation.menu_tree()`
- `lib/agent_jido_web/components/menu.ex` — `vertical_menu/1`, `menu_group/1`, `menu_item/1`
- `assets/css/menu.css` — sidebar styles with hard-coded hex colors + `.dark` selectors
- `lib/agent_jido_web/components/jido/docs_components.ex` — `docs_sidebar/1`, `docs_secondary_nav/1`
- `lib/agent_jido_web/live/jido_docs_live.ex` — `sidebar_nav/0` (hardcoded nav data)

**What to look for:**
- **Duplicate nav data generation:** `MenuItems.menu_items()` is dynamic (reads `Documentation.menu_tree()`); `JidoDocsLive.sidebar_nav/0` is hardcoded and will drift from content
- **Bug:** `MenuItems.convert_doc_tree_to_menu_items/2` sets `_child_base_path` but doesn't use it; children use `base_path` (incorrect nesting)
- **CSS conflict:** `menu.css` uses hard-coded hex colors and `.dark` selectors (old system) while docs sidebar uses CSS custom properties
- **Dead code?** If Workbench sidebar is deprecated, `Menu`, `MenuItems`, and `menu.css` may all be removable

**Deliverable:** Plan to either:
- Make docs sidebar data-driven (reuse `Documentation.menu_tree()`)
- Or delete `MenuItems`/`Menu`/`menu.css` if Workbench sidebar is deprecated

**Effort:** M-L (~3-4h)

---

### Step 7: Component Deduplication

**Goal:** Identify and consolidate duplicate component variants across modules.

**Files:**
- `lib/agent_jido_web/components/jido/ui.ex` — button, badge, code_block, icon_card, numbered_card, section_header, quickstart_card
- `lib/agent_jido_web/components/jido/docs_components.ex` — numbered_card, icon_card (duplicates of UI versions)
- `lib/agent_jido_web/components/jido/marketing_cards.ex` — package_card, layer_badge, metric_card, feature_card, info_card
- `lib/agent_jido_web/components/jido/marketing_code.ex` — code_block, terminal_command, install_steps
- `lib/agent_jido_web/components/core_components.ex` — phx_modal, phx_button, etc. (Phoenix defaults)

**What to look for:**

| Component | Module A | Module B | Difference |
|-----------|----------|----------|------------|
| `numbered_card` | `UI` (integer number, color map) | `DocsComponents` (string number, simpler) | API + styling |
| `icon_card` | `UI` (emoji icon, href optional) | `DocsComponents` (emoji icon, color param, href required) | API + styling |
| `code_block` | `UI` (slot-based, copy button hook) | `MarketingCode` (attr-based `code` string, traffic-light dots) | API + rendering |
| `badge` | `UI` (kind atom, slot) | `MarketingCards.layer_badge` (layer atom, no slot) | Near identical |

**Deliverable:** A "Component Ownership" table:
- `Jido.UI` = generic primitives (button, badge, code_block, etc.)
- `Jido.MarketingCards` / `Jido.MarketingCode` = composed marketing-specific components
- `Jido.DocsComponents` = docs layout pieces only (sidebar, secondary nav, breadcrumb); delete duplicate cards
- Deprecation list with call sites to migrate

**Effort:** M (~2-3h)

---

### Step 8: CSS Architecture & Token Reconciliation

**Goal:** Clarify which CSS system is authoritative. Plan removal of legacy layers.

**Files:**
- `assets/css/app.css` — CSS custom properties, `@theme inline`, component classes, utilities
- `assets/css/menu.css` — old sidebar styles with hard-coded colors
- `assets/css/syntax.css` — syntax highlighting (may be valid for both systems)
- Petal import: `@import "../../deps/petal_components/assets/default.css";`

**What to look for:**
- Whether Petal's `default.css` is still required for any active pages
- `@custom-variant dark` exists but new system uses `.light` overrides — are `dark:` utilities still used?
- Classes like `bg-secondary-50 dark:bg-secondary-950` in catalog/settings pages
- `@theme inline` block maps Petal's `primary-{50..950}` scale to CSS vars — this is a compatibility shim; is it still needed?

**Deliverable:** A staged CSS migration plan:
1. Keep both systems temporarily; document boundaries
2. Migrate remaining Workbench pages to CSS vars
3. Remove Petal `default.css` import + `menu.css` if unused
4. Remove `@custom-variant dark` if `.light` class is canonical

**Effort:** L (~1-2d if removing Petal forces class updates)

---

### Step 9: JS Hooks Audit

**Goal:** Identify orphaned/duplicated hooks; consolidate to a minimal set.

**Files:**
- `assets/js/hooks/` directory:
  - `color-scheme-hook.js` — old theme toggle
  - `copy_to_clipboard.js` — clipboard functionality
  - `highlight.js` — code highlighting
  - `index.js` — hook registry
  - `message-history.js` — chat feature?
  - `scroll_reveal.js` — scroll animation
  - `scroll_spy.js` — scroll position tracking
  - `scroll-bottom.js` — auto-scroll to bottom
- `assets/js/app.js` — main entry point

**What to look for:**
- **Duplicate clipboard:** `CopyCode` hook (used in `UI.code_block`) vs `data-copy-button` approach (used in `JidoHomeLive.install_section`)
- **Theme hooks:** `ColorSchemeHook` (old) vs `ThemeToggle` (new, used in marketing_header) — which is registered?
- **Scroll hooks:** `ScrollReveal` (used in marketing sections), `ScrollShrink` (used in marketing header), `ScrollSpy` (used?) — verify all are needed
- **Dead hooks:** `message-history.js`, `scroll-bottom.js` — are these used by any current LiveView?
- **AlpineJS dependency:** confirm no hook uses Alpine; if not, remove script tag from root layout

**Deliverable:** Hook usage matrix:

| Hook | Defined In | Used By | Keep/Delete/Merge |
|------|-----------|---------|-------------------|
| ... | ... | ... | ... |

**Effort:** M (~1-2h)

---

### Step 10: Docs Content Rendering & Shell Consistency

**Goal:** Ensure the docs shell (header → secondary nav → sidebar → content → right TOC) renders consistently.

**Files:**
- `lib/agent_jido_web/live/jido_docs_live.ex`
- `lib/agent_jido_web/live/jido_docs_live.html.heex`
- `lib/agent_jido_web/components/jido/docs_components.ex`

**What to look for:**
- Does `JidoDocsLive` render all docs components (`docs_header`, `docs_secondary_nav`, `docs_sidebar`, `docs_right_sidebar`) in both `:index` and `:show` actions?
- `build_toc/1` returns a flat list with `children: []` — verify right sidebar handles this correctly
- `sidebar_nav/0` is hardcoded; many listed pages (e.g., `/docs/agents/defining`, `/docs/ai/llm-config`) may not exist as actual documents
- Sidebar toggle (`toggle_sidebar` event) state management — does it persist across navigation?
- Does the docs layout match the reference in `jido-dev-relaunch/src/components/docs/DocsLayout.tsx`?

**Deliverable:** A "Docs Shell Contract" defining required assigns and layout structure for index vs show.

**Effort:** M (~2h)

---

### Step 11: Catalog & Settings — Migrate or Isolate

**Goal:** Decide whether `/catalog` and `/settings` should adopt the new design system.

**Files:**
- `lib/agent_jido_web/live/catalog/catalog_live.ex`
- `lib/agent_jido_web/live/catalog/actions_live.ex`
- `lib/agent_jido_web/live/catalog/agents_live.ex`
- `lib/agent_jido_web/live/catalog/sensors_live.ex`
- `lib/agent_jido_web/live/catalog/skills_live.ex`
- `lib/agent_jido_web/live/settings_live.ex`
- `lib/agent_jido_web/components/workbench_layout.ex`

**What to look for:**
- Extent of old palette usage (`bg-white dark:bg-secondary-900`, `text-primary-600 dark:text-primary-500`, etc.)
- Whether these pages are public-facing (catalog is) and should visually match marketing pages
- Whether the sidebar menu (`Menu.vertical_menu` + `MenuItems.menu_items()`) adds value for these pages

**Deliverable:** Migration decision:
- Option A: Migrate catalog to `marketing_layout` (public-facing, should match)
- Option B: Keep isolated; document as "Workbench legacy"
- Ordered migration list if proceeding

**Effort:** L if migrating (~1-2d for restyling + component swaps)

---

### Step 12: React Prototype Parity Check

**Goal:** Compare ported Phoenix components to React reference; find missing/incomplete ports.

**Files:**
- React: `jido-dev-relaunch/src/components/layout/Header.tsx`, `Footer.tsx`, `Layout.tsx`
- React: `jido-dev-relaunch/src/components/home/*`, `jido-dev-relaunch/src/components/docs/*`
- React: `jido-dev-relaunch/src/index.css`, `jido-dev-relaunch/src/App.css`
- Phoenix: corresponding files in `lib/agent_jido_web/components/jido/`

**What to look for:**
- **Behavioral parity:**
  - Header scroll shrink: React uses `window.scrollY > 20` threshold; Phoenix `ScrollShrink` hook — same behavior?
  - Theme toggle: React uses `localStorage.setItem("theme", ...)` key; Phoenix old code may use different key
- **Missing assets:** React footer uses `jido-logo.png`; Phoenix uses CSS gradient "J" block
- **Missing components:** React has `DocsAskAI`, `DocsBreadcrumb`, `DocsPrevNext`, `DocsSearch` — are these ported?
- **CSS token parity:** Compare React's `tailwind.config.ts` token definitions with Phoenix's `app.css` `:root` block

**Deliverable:** Parity checklist with status: ✅ same, ⚠️ intentionally different, ❌ missing

**Effort:** S-M (~1-2h)

---

## Execution Order

```
Phase 1: Foundation (do these first — decisions drive everything else)
  Step 1 → Step 2 → Step 3

Phase 2: Structural Consolidation
  Step 4 → Step 5 → Step 6

Phase 3: Component & Asset Cleanup
  Step 7 → Step 8 → Step 9

Phase 4: Page-Level Migration
  Step 10 → Step 11

Phase 5: Polish
  Step 12
```

Each step should be completed before starting the next within a phase. Phases 2-3 can partially overlap once Phase 1 decisions are locked in.

---

## Completion Log

| Step | Title | Status | Commit | Notes |
|------|-------|--------|--------|-------|
| 1 | Route → Layout Inventory | ✅ Done | — | Doc only: `STEP1_ROUTE_LAYOUT_INVENTORY.md` |
| 2 | Layout Strategy Decision | ✅ Done | — | Doc only: `STEP2_LAYOUT_STRATEGY.md` |
| 3 | Theme System Unification | ✅ Done | `8c1ff43` | Single canonical toggle (localStorage.theme, .light/.dark on html). Removed AlpineJS, js-cookie CDNs, ColorSchemeHook, old Petal color_scheme_switch components |
| 4 | Root Layout & Asset Hygiene | ✅ Done | `248d19a` | Removed unused fonts (Inter, VT323, JetBrains Mono). Consolidated to IBM Plex Mono only |
| 5 | Header/Nav/Footer Consolidation | ✅ Done | `3abeb84` | Created shared `Jido.Nav` module. Refactored MarketingLayouts and DocsComponents to use it |
| 6 | Dead-Code & Scaffold Sweep | ✅ Done | `34b47f2` | Deleted JidoLive, PageLive, FormLive, SettingsLive, ChatComponents, PageHTML, dead JS hooks. ~1,399 lines removed |
| 7 | Component Deduplication | ✅ Done | `4c2a462` | Deleted unused `Jido.UI` module (210 lines) |
| 8 | CSS Architecture & Token Reconciliation | ✅ Done | `ba0a711` | Added architecture comment to app.css. Fixed syntax.css stale font reference |
| 9 | Final Smoke-Test & Docs Update | ✅ Done | (this commit) | Compile clean (`--warnings-as-errors`), 27 tests pass, routes verified |

### Remaining Work (Future Phases)

The following items from Steps 10–12 are deferred to future work:

- **Migrate blog** (`/blog/*`) from `workbench_layout` + `dark:` variants → `marketing_layout` + CSS custom properties
- **Migrate cookbook** (`/cookbook/*`) from `workbench_layout` → docs shell layout
- **Migrate catalog** (`/catalog/*`) from `workbench_layout` → docs shell or marketing layout
- **Delete WorkbenchLayout stack** (`workbench_layout.ex`, `menu.ex`, `menu_items.ex`, `menu.css`) once all consumers are migrated
- **Remove Petal `default.css` import** and `@theme inline` compat shim once no pages use `dark:` variants
- **React prototype parity check** (Step 12)
