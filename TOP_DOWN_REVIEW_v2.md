# Top-Down Front-End Review v2

Second-pass review after the v1 cleanup (Steps 1–12). Starts from `root.html.heex` and works down through every layer looking for remaining cruft, bugs, dead code, and inconsistencies.

---

## Executive Summary

The v1 cleanup removed ~1,400 lines of dead code, unified the theme toggle, and deleted unused fonts. The **new design system** (CSS custom properties, `marketing_layout`, `DocsComponents`) is solid. However, **two systemic issues remain**:

1. **The legacy Workbench/Petal stack is still fully wired in** — it's imported globally, its CSS ships to every page, and three page groups (blog, cookbook, catalog) still depend on it.
2. **The docs shell has data-correctness bugs** — `@toc` is never assigned on `:show` pages, the sidebar has ~30 dead links, and the footer is hardcoded to a single document.

---

## Layer 1: Root Layout (`root.html.heex`)

### 1.1 Legacy `localStorage.scheme` migration shim (lines 13–16)
```js
if (!stored && localStorage.scheme) {
  stored = localStorage.scheme === 'dark' ? 'dark' : 'light';
  localStorage.setItem('theme', stored);
  localStorage.removeItem('scheme');
}
```
**Status:** This was a one-time migration from the old `ColorSchemeHook` key. Any user who visited the site since Step 3 has been migrated. This block can be removed — it's dead weight.

**Action:** Remove the `localStorage.scheme` migration block. Keep only the `localStorage.getItem('theme')` check.

### 1.2 `<body class="antialiased font-mono">`
`font-mono` maps to `--font-mono` (IBM Plex Mono) via the `@theme inline` block. If the `@theme inline` block is eventually removed (when Petal shim is removed), `font-mono` will fall back to the Tailwind default mono stack and IBM Plex Mono will silently stop applying.

**Action:** No change now, but document as a dependency on the `@theme inline` block.

---

## Layer 2: JavaScript (`app.js` + `assets/js/hooks/`)

### 2.1 Three competing clipboard mechanisms

| Mechanism | Defined In | Used By | Notes |
|-----------|-----------|---------|-------|
| `Hooks.CopyCode` | `app.js` L108–134 | `JidoBenchmarksLive` (1 usage) | LiveView hook, text replacement feedback |
| `Hooks.CopyToClipboard` | `hooks/copy_to_clipboard.js` | **Nothing** — zero `phx-hook="CopyToClipboard"` in templates | Dead code |
| `document.addEventListener("click", [data-copy-button])` | `app.js` L152–169 | `JidoHomeLive` (1 usage) | Global delegated handler, SVG feedback |

**Action:**
- Delete `hooks/copy_to_clipboard.js` and remove its import/registration from `app.js` — it's dead.
- Migrate `JidoBenchmarksLive` to use `data-copy-button` approach (set `data-content` attr).
- Delete `Hooks.CopyCode` once migrated.
- Result: single clipboard mechanism via global event delegation.

### 2.2 `Highlight` hook is dead and references missing global

`hooks/highlight.js` calls `hljs.highlightElement(block)` but:
- `highlight.js` (the library) is **not loaded anywhere** — no CDN tag, no npm import.
- Zero templates use `phx-hook="Highlight"`.

**Action:** Delete `hooks/highlight.js` and remove its import/registration from `app.js`.

### 2.3 `ScrollSpy` hook uses legacy color classes

`hooks/scroll_spy.js` toggles `text-lime-500`, `bg-zinc-800`, `text-zinc-300` — these are raw Tailwind colors, not the CSS custom property tokens. Only used by `livebook_demo_live.html.heex` (cookbook pages, legacy Workbench stack).

**Action:** Keep until cookbook migration (tracked in Layer 5). Mark as legacy.

### 2.4 `ThemeToggle` hook uses `document.getElementById` (fragile)

`Hooks.ThemeToggle.updateButtonStates()` uses `document.getElementById("theme-dark-btn")` and `document.getElementById("theme-light-btn")`. If a second toggle is ever rendered (e.g., in docs header), IDs will collide.

**Action:** Refactor to query within `this.el.closest(...)` or the parent container instead of global ID lookup. Low priority but worth noting.

### 2.5 `ScrollReveal` — keep

Used by 6 sections in `JidoHomeLive`. Working correctly with the CSS custom property `animate-fade-in` animation. No issues.

### 2.6 `ScrollShrink` — keep

Used by `marketing_header`. Working correctly. Matches React reference behavior (`window.scrollY > 20`).

### Hook Usage Matrix

| Hook | Defined In | Used By | Status |
|------|-----------|---------|--------|
| `ThemeToggle` | `app.js` (inline) | `marketing_layouts.ex` (2 buttons) | ✅ Keep (refactor ID lookup) |
| `ScrollShrink` | `app.js` (inline) | `marketing_layouts.ex` (header) | ✅ Keep |
| `ScrollReveal` | `hooks/scroll_reveal.js` | `jido_home_live.ex` (6 sections) | ✅ Keep |
| `CopyCode` | `app.js` (inline) | `jido_benchmarks_live.ex` (1 button) | ⚠️ Merge into `data-copy-button` |
| `ScrollSpy` | `hooks/scroll_spy.js` | `livebook_demo_live.html.heex` (1 sidebar) | ⚠️ Legacy — keep until cookbook migration |
| `CopyToClipboard` | `hooks/copy_to_clipboard.js` | **Nothing** | ❌ Delete |
| `Highlight` | `hooks/highlight.js` | **Nothing** | ❌ Delete |
| `data-copy-button` | `app.js` (global handler) | `jido_home_live.ex` (1 button) | ✅ Keep — make canonical |

---

## Layer 3: CSS (`app.css`, `menu.css`, `syntax.css`)

### 3.1 Petal compatibility shim is still globally loaded

These lines in `app.css` exist solely for the legacy Workbench stack:
- `@source "../../deps/petal_components/**/*.*ex";` (L3) — Tailwind scans Petal for class names
- `@import "../../deps/petal_components/assets/default.css";` (L8) — Petal base styles
- `@import "./menu.css";` (L10) — Workbench sidebar styles
- `@custom-variant dark (&:where(.dark, .dark *));` (L37) — enables `dark:` prefix
- `@theme inline { ... primary-50..950, secondary-50..950 ... }` (L48–192) — maps Petal color scale to CSS vars

**All of this ships to every page**, including marketing pages that don't use it. It adds CSS weight and class namespace pollution.

**Action:** Cannot remove until blog/cookbook/catalog are migrated off Workbench stack. Document as tracked dependency.

### 3.2 `menu.css` — hard-coded hex colors + `.dark` selectors

All 92 lines use hard-coded hex colors (`#4b5563`, `#9ca3af`, `#4f46e5`, etc.) and `.dark .menu-item` selectors. This is the old Petal theme system. Only used by `Menu.vertical_menu/1` which is only used by `WorkbenchLayout`.

**Action:** Delete when WorkbenchLayout is removed.

### 3.3 `syntax.css` — hard-coded light/dark colors

`syntax.css` uses hard-coded hex values for syntax highlighting of `NimbleOptions.Makeup` output (`.makeup` classes). Has both light and dark mode blocks using `.dark .makeup` selectors. This is separate from the hand-authored `<span class="text-code-keyword">` approach used in marketing/docs pages.

**Action:** Keep — it's valid for rendered markdown content. Consider migrating colors to CSS vars for consistency (low priority).

### 3.4 CSS component classes in `app.css` — usage audit

| CSS Class | Used By | Status |
|-----------|---------|--------|
| `.package-card`, `.package-card-*` | `MarketingCards.package_card` | ✅ Active |
| `.badge-*` | `MarketingCards.layer_badge` | ✅ Active |
| `.code-block`, `.code-header` | `MarketingCode.code_block`, docs template | ✅ Active |
| `.metric-card` | `MarketingCards.metric_card` | ✅ Active |
| `.feature-card` | `MarketingCards.feature_card` | ✅ Active |
| `.gradient-text` | Multiple marketing pages | ✅ Active |
| `.cta-glow` | `JidoHomeLive` | ✅ Active |
| `.nav-surface` | `marketing_layouts.ex` header nav | ✅ Active |
| `.icon-card` | Multiple pages via CSS class | ✅ Active |
| `.numbered-card` | Docs index via CSS class | ✅ Active |
| `.quickstart-card` | Docs index | ✅ Active |
| `.neon-glow`, `.neon-border` | Needs verification | ⚠️ Check if used |
| `.syntax-*` utilities | Docs/marketing code examples | ✅ Active |

---

## Layer 4: Layouts & Navigation

### 4.1 `WorkbenchLayout` — still active, blocking removal

**Consumers:**
- `BlogHTML` (`import AgentJidoWeb.WorkbenchLayout`) → blog index, show, tag templates
- `LivebookDemoLive` (`import AgentJidoWeb.WorkbenchLayout`) → cookbook pages
- All catalog LiveViews (5 modules) → catalog pages

**Issues:**
- Footer says `"© {year} - eBoss.ai - All rights reserved."` — **wrong brand name**. Should be AgentJido.
- Nav bar includes inline SVG icons duplicated from `Nav` module (GitHub, Discord, X).
- `GithubStarsTracker` is only used here — once removed, the GenServer in `application.ex` can also be removed.
- `show_layout` helper function is defined but unclear if it's actually used anymore.

**Action:** Track as migration target (see Layer 5).

### 4.2 `Nav` module — broken footer links

`Nav.footer_company_links()` and `Nav.footer_resource_links()` include routes that **do not exist in `router.ex`**:

| Link | Route Exists? |
|------|--------------|
| `/about` | ❌ No |
| `/careers` | ❌ No |
| `/contact` | ❌ No |
| `/community` | ❌ No |
| `/changelog` | ❌ No |
| `/privacy` | ❌ No (linked in `marketing_footer`) |
| `/terms` | ❌ No (linked in `marketing_footer`) |

These are **broken internal navigations on every marketing page footer**.

**Action:** Remove non-existent links from `Nav` module until pages exist. Keep only links that resolve to actual routes.

### 4.3 `Nav.marketing_nav_links` — labels are paths

```elixir
@marketing_nav_links [
  {"/ecosystem", "/ecosystem"},
  {"/partners", "/partners"},
  ...
]
```

The first element (label) is `"/ecosystem"` (with slash), not `"Ecosystem"`. However, looking at `marketing_layouts.ex` L59–65, the label is rendered directly as link text. Currently renders as `/ecosystem` in the nav bar — **this is a display bug** if the intent was human-readable labels.

**Action:** Change labels to proper names: `{"Ecosystem", "/ecosystem"}`, etc.

### 4.4 Hardcoded version `v0.1.0`

Appears in:
- `Nav.logo/1` (line 79)
- `marketing_footer` (line 225)

**Action:** Extract to a module attribute or config value. Low priority but worth centralizing.

### 4.5 Duplicate social icons

Social icon SVGs exist in three places:
1. `Nav` module — `discord_icon/1`, `github_icon/1`, `x_icon/1`, `linkedin_icon/1`, `youtube_icon/1`
2. `WorkbenchLayout.nav_bar/1` — inline SVGs for GitHub, Discord, X
3. `BlogHTML` templates — inline SVGs for GitHub, X

**Action:** Once blog/catalog migrate to marketing layout, `Nav` icons become the single source.

---

## Layer 5: Legacy Pages (Blog, Cookbook, Catalog)

### 5.1 `dark:` class usage count by area

| Area | `dark:` count | Layout | Migration Effort |
|------|--------------|--------|-----------------|
| Blog templates (3 files) | ~40 | `workbench_layout` | S |
| `livebook_demo_live.html.heex` | ~15 | `workbench_layout` | M |
| Catalog LiveViews (5 files) | ~80 | `workbench_layout` | M-L |
| `workbench_layout.ex` | ~20 | Self | Deleted after migrations |
| `core_components.ex` | ~12 | Phoenix defaults | M (careful — shared) |
| `menu.css` | ~8 | Workbench sidebar | Deleted after migrations |

**Total:** ~175 `dark:` class instances to migrate.

### 5.2 Migration priority order

1. **Blog** (S effort) — 3 template files, simple card layouts. Swap `workbench_layout` → `marketing_layout`, replace `dark:` classes with CSS var tokens.
2. **Cookbook** (M effort) — 1 LiveView + template. Needs sidebar rework (currently uses `ScrollSpy` with legacy colors). Consider reusing `DocsComponents.docs_sidebar` if structure fits.
3. **Catalog** (L effort) — 5 LiveViews with complex list/detail layouts. Largest class migration.
4. **Delete WorkbenchLayout** — once all consumers removed (~198 lines + 101 lines `menu.ex` + 92 lines `menu.css` + 101 lines `menu_items.ex` = ~492 lines).

### 5.3 Petal dependency removal sequence

After all migrations complete:
1. Remove `@import "../../deps/petal_components/assets/default.css"` from `app.css`
2. Remove `@import "./menu.css"` from `app.css`
3. Remove `@source "../../deps/petal_components/**/*.*ex"` from `app.css`
4. Remove `@custom-variant dark` from `app.css`
5. Remove `@theme inline { --color-primary-50 ... }` block from `app.css` (BUT keep `--font-mono`, radius, animations — move to `:root` or separate `@theme`)
6. Remove `use PetalComponents` from `agent_jido_web.ex` `html_helpers/0`
7. Remove `use PetalComponents` from `workbench_layout.ex` (deleted with it)
8. Remove `import PetalComponents.Link` from `menu.ex` (deleted with it)
9. Audit `import PetalComponents.Icon` in `core_components.ex` — `.icon` component is used everywhere. If Petal is removed, need to bring icon rendering inline or use `heroicons` directly.
10. Remove `{:petal_components, "~> 3.0"}` from `mix.exs`

**Risk:** `PetalComponents.Icon` (`<.icon name="hero-*" />`) is used across the entire app (marketing, docs, catalog). This is the single biggest blocker to removing the Petal dependency. Evaluate whether to vendor the icon component or switch to `heroicons_elixir` directly.

---

## Layer 6: Docs Shell

### 6.1 P0 Bug: `@toc` not assigned in `:show` action

`JidoDocsLive.handle_show/2` assigns `document_content: %{html: doc.body, toc: toc}` but **does not assign `toc: toc`** to the socket. The template at line 360 checks `@toc`:

```heex
<%= if @toc && @toc != [] do %>
  <.docs_right_sidebar toc={@toc} />
<% end %>
```

On `:show` pages, `@toc` is either missing (KeyError) or stale from the `:index` mount. The TOC is computed but only stored inside `@document_content.toc`, which is never read.

**Fix:** Add `toc: toc` to the `assign/2` call in `handle_show/2`.

### 6.2 P0 Bug: ~30 dead sidebar links

`JidoDocsLive.sidebar_nav/0` is hardcoded with paths like `/docs/agents/defining`, `/docs/ai/llm-config`, `/docs/production/deployment`, etc. Most of these documents **do not exist** in `Documentation.all_documents()`. Clicking them triggers the `put_flash(:error, "Document not found")` fallback and redirects to `/docs`.

**Fix:** Generate sidebar nav from `Documentation.menu_tree()` (same source the router uses). Delete `sidebar_nav/0`.

### 6.3 `docs_secondary_nav` — hardcoded tabs with dead links

`DocsComponents.docs_secondary_nav/1` (lines 75–83) hardcodes 7 tabs with hrefs like `/docs/packages/jido`, `/docs/agents/defining`, `/docs/ai/llm-config`. Same problem as sidebar — most don't resolve.

**Fix:** Generate from document categories or remove tabs that don't have content.

### 6.4 Docs footer — hardcoded to single document

```heex
<span>Last updated: January 2026</span>
<a href="https://github.com/agentjido/jido/edit/main/docs/introduction.md">
  Edit this page →
</a>
```

- "January 2026" is stale and wrong for most docs.
- "Edit this page" always points to `introduction.md` regardless of which doc is displayed.

**Fix:** Compute edit URL from `@selected_document.path` (map to repo path). Either show real last-modified date or remove the "Last updated" text.

### 6.5 `docs_header` — Search and Ask AI are non-functional

The search box (⌘K) and "Ask AI" button in `docs_header` are **purely decorative** — they have no event handlers, no hooks, no backend.

**Action:** Either implement or add `disabled` state with tooltip "Coming soon". Currently misleading.

### 6.6 `dark:prose-invert` usage in docs template

`jido_docs_live.html.heex` line 31 uses `prose prose-sm dark:prose-invert`. The `dark:` variant works because `@custom-variant dark` is globally defined. However, this is the **only** `dark:` usage in the new design system templates. When the Petal shim is removed, this will break.

**Action:** Add a `prose-invert` rule to the `:root` (dark) block in `app.css`, or handle prose styling via CSS vars. Track as part of Petal removal.

---

## Layer 7: Component Modules

### 7.1 `DocsComponents` — `numbered_card` and `icon_card` are duplicates of deleted `UI` module

In v1 Step 7, `Jido.UI` was deleted (210 lines). `DocsComponents` retained its own `numbered_card/1` and `icon_card/1`. These are now the **only** versions, used by:
- `jido_docs_live.html.heex` (docs index page)

No duplication issue remaining — just noting they're docs-specific now.

### 7.2 `MenuItems` module — `_child_base_path` bug still present

```elixir
_child_base_path = "#{base_path}/#{section_name}"
Map.put(menu_item, :menu_items, convert_doc_tree_to_menu_items(children, base_path))
```

`_child_base_path` is computed but the underscore prefix means it's deliberately unused. Children use `base_path` instead. This means nested docs don't get properly nested paths. Only matters if WorkbenchLayout sidebar is kept.

**Action:** Will be deleted with WorkbenchLayout migration.

### 7.3 `MarketingCode.code_block` vs inline code in docs

Marketing pages use `MarketingCode.code_block/1` (with traffic light dots header). Docs template uses hand-authored `<pre><code>` blocks with `text-code-*` classes. These serve different purposes — no duplication issue.

---

## Layer 8: Application-Level Cruft

### 8.1 `GithubStarsTracker` GenServer

Started in `application.ex`. Only consumed by `WorkbenchLayout.nav_bar/1`. Once WorkbenchLayout is deleted, this GenServer and its module can be removed.

**Action:** Delete with WorkbenchLayout migration.

### 8.2 `use PetalComponents` in `html_helpers/0`

`agent_jido_web.ex` line 88: `use PetalComponents` is injected into every module that `use AgentJidoWeb, :html` or `:live_view`. This makes Petal components available everywhere, even in the new design system modules that don't use them.

**Action:** Remove after Petal dependency elimination. Requires ensuring `<.icon>` has a replacement.

---

## Priority Action List

### P0 — Bugs (fix immediately)

| # | Issue | File(s) | Effort |
|---|-------|---------|--------|
| 1 | `@toc` not assigned in docs `:show` | `jido_docs_live.ex` L67–75 | XS |
| 2 | Broken footer links (7 dead routes) | `nav.ex` L18–31, `marketing_layouts.ex` L220–223 | XS |
| 3 | WorkbenchLayout footer says "eBoss.ai" | `workbench_layout.ex` L49 | XS |

### P1 — Dead Code Removal (safe, no behavior change)

| # | Issue | File(s) | Effort |
|---|-------|---------|--------|
| 4 | Delete `CopyToClipboard` hook (unused) | `hooks/copy_to_clipboard.js`, `app.js` L5,22 | XS |
| 5 | Delete `Highlight` hook (unused, broken) | `hooks/highlight.js`, `app.js` L6,23 | XS |
| 6 | Remove `localStorage.scheme` migration shim | `root.html.heex` L13–16 | XS |
| 7 | Remove `localStorage.removeItem('scheme')` | `root.html.heex` L17 | XS |

### P2 — Data Correctness (docs shell)

| # | Issue | File(s) | Effort |
|---|-------|---------|--------|
| 8 | Generate sidebar nav from `Documentation.menu_tree()` | `jido_docs_live.ex` (delete `sidebar_nav/0`) | M |
| 9 | Fix `docs_secondary_nav` dead tab hrefs | `docs_components.ex` L75–83 | S |
| 10 | Fix docs footer (edit URL + date) | `jido_docs_live.html.heex` L344–355 | S |

### P3 — Consolidation

| # | Issue | File(s) | Effort |
|---|-------|---------|--------|
| 11 | Fix nav link labels (paths → names) | `nav.ex` L8–14 | XS |
| 12 | Merge `CopyCode` → `data-copy-button` | `app.js`, `jido_benchmarks_live.ex` | S |
| 13 | Centralize version string | `nav.ex`, `marketing_layouts.ex` | XS |

### P4 — Page Migrations (sequenced)

| # | Issue | File(s) | Effort |
|---|-------|---------|--------|
| 14 | Migrate blog to `marketing_layout` | `blog_html.ex`, `blog_html/*.heex` | S |
| 15 | Migrate cookbook to docs shell | `livebook_demo_live.ex`, `.html.heex` | M |
| 16 | Migrate catalog to docs shell or marketing layout | `catalog/*.ex` (5 files) | L |
| 17 | Delete WorkbenchLayout stack | `workbench_layout.ex`, `menu.ex`, `menu_items.ex`, `menu.css` | S (after 14–16) |
| 18 | Remove Petal dependency | `app.css`, `mix.exs`, `agent_jido_web.ex` | M (after 17, icon audit) |

---

## Dependency Graph

```
P0 bugs (1-3) — independent, do first
    ↓
P1 dead code (4-7) — independent, do anytime
    ↓
P2 docs data (8-10) — depends on understanding Documentation module
    ↓
P3 consolidation (11-13) — independent
    ↓
P4 migrations (14 → 15 → 16 → 17 → 18) — strictly sequenced
```

---

## Files Safe to Delete (after all migrations)

| File | Lines | Blocked By |
|------|-------|-----------|
| `assets/js/hooks/copy_to_clipboard.js` | 10 | Nothing — delete now |
| `assets/js/hooks/highlight.js` | 14 | Nothing — delete now |
| `assets/css/menu.css` | 92 | WorkbenchLayout removal |
| `lib/agent_jido_web/components/workbench_layout.ex` | 198 | Blog/cookbook/catalog migration |
| `lib/agent_jido_web/components/menu.ex` | 137 | WorkbenchLayout removal |
| `lib/agent_jido_web/menu_items.ex` | 100 | WorkbenchLayout removal |
| `lib/agent_jido/github_stars_tracker.ex` | ~50 | WorkbenchLayout removal |
| **Total** | **~601** | |
