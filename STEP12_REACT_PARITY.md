# Step 12 — React → Phoenix Parity Report

## 1. Component Parity Checklist

### Layout Components

| React Component | Phoenix Equivalent | Status | Notes |
|---|---|---|---|
| `layout/Layout.tsx` | `MarketingLayouts.marketing_layout/1` | ✅ same | Both: min-h-screen flex col, header + main + footer |
| `layout/Header.tsx` | `MarketingLayouts.marketing_header/1` | ✅ same | Nav links, logo, CTA, mobile menu, theme toggle — all ported |
| `layout/Footer.tsx` | `MarketingLayouts.marketing_footer/1` | ⚠️ intentionally different | React uses `jido-logo.png`; Phoenix uses CSS gradient "J" block via `Nav.logo`. Same link data. |

### Home Page Sections

| React Component | Phoenix Equivalent | Status | Notes |
|---|---|---|---|
| `home/HeroSection.tsx` | `JidoHomeLive.hero_section/1` | ⚠️ intentionally different | React uses framer-motion staggered fade-in; Phoenix uses CSS `animate-fade-in` class (single animation, no stagger). Content identical. |
| `home/MetricsStrip.tsx` | `JidoHomeLive.metrics_strip/1` | ✅ same | Same 4 metrics, same grid, same colors |
| `home/PackageEcosystem.tsx` | `JidoHomeLive.package_ecosystem/1` | ✅ same | Same 3-row layout, same package data. Phoenix adds `ScrollReveal` hook. |
| `home/DependencyFlow.tsx` | `JidoHomeLive.dependency_flow/1` | ✅ same | Same ASCII diagram, same color spans |
| `home/InstallSection.tsx` | `JidoHomeLive.install_section/1` | ✅ same | Same 3 tabs, same deps. React uses `useState`; Phoenix uses `phx-click` event. |
| `home/WhyBeamSection.tsx` | `JidoHomeLive.why_beam_section/1` | ✅ same | Same 3 features, same icons/colors |
| `home/QuickStartCode.tsx` | `JidoHomeLive.quick_start_code/1` | ✅ same | Same code sample, same syntax highlighting approach |
| `home/CTASection.tsx` | `JidoHomeLive.cta_section/1` | ✅ same | Same headline, buttons, `.cta-glow` class |

### Docs Components

| React Component | Phoenix Equivalent | Status | Notes |
|---|---|---|---|
| `docs/DocsLayout.tsx` | `jido_docs_live.html.heex` | ✅ same | Same 3-column layout (sidebar + main + right sidebar) |
| `docs/DocsHeader.tsx` | `DocsComponents.docs_header/1` | ✅ same | Same nav items, logo, search stub, "Ask AI" button, GitHub/Hex links |
| `docs/DocsSecondaryNav.tsx` | `DocsComponents.docs_secondary_nav/1` | ✅ same | Same 7 tabs, same active-path logic |
| `docs/DocsSidebar.tsx` | `DocsComponents.docs_sidebar/1` | ✅ same | Same nav structure, collapsible sections, badges. Phoenix uses `phx-click="toggle_sidebar"`. |
| `docs/DocsRightSidebar.tsx` | `DocsComponents.docs_right_sidebar/1` | ⚠️ intentionally different | React has IntersectionObserver active-highlight on ToC + edit link; Phoenix ToC has no active highlighting + no edit link. Quick Links identical. |
| `docs/DocsCodeExample.tsx` | `MarketingCode.code_block/1` | ✅ same | Both render code-block with header and copy button |
| `docs/DocsBreadcrumb.tsx` | — | ❌ missing | Path-to-label breadcrumb not ported |
| `docs/DocsPrevNext.tsx` | — | ❌ missing | Previous/Next navigation not ported |
| `docs/DocsAskAI.tsx` | — | ❌ missing | AI question input with suggestions not ported |
| `docs/DocsSearch.tsx` | — | ❌ missing | ⌘K search dialog with keyboard nav not ported |
| `docs/DocsFooter.tsx` | Inline in heex | ⚠️ intentionally different | React has a full 4-column docs footer; Phoenix has a minimal 1-line footer. Content differs. |
| `docs/cards/NumberedCard.tsx` | `DocsComponents.numbered_card/1` | ✅ same | Same layout |
| `docs/cards/IconCard.tsx` | `DocsComponents.icon_card/1` | ✅ same | Same layout + color mapping |
| `docs/cards/QuickstartCard.tsx` | — | ❌ missing | Not a separate component; functionality folded into `icon_card` in docs index |

### UI Primitives (shadcn/ui)

| React Component | Phoenix Equivalent | Status | Notes |
|---|---|---|---|
| `ui/code-block.tsx` | `MarketingCode.code_block/1` | ✅ same | Custom Elixir syntax highlighter ported |
| `ui/button.tsx` (+ 48 others) | — | ⚠️ N/A | These are shadcn/ui primitives (accordion, dialog, toast, etc.). Phoenix uses HEEx + Tailwind directly. **Not needed** — Phoenix doesn't use Radix. |

### Shared Modules

| React Module | Phoenix Equivalent | Status | Notes |
|---|---|---|---|
| Nav link data (in Header/Footer) | `Nav` module | ✅ same | All links, social data, package links extracted to `nav.ex` |
| `hooks/use-mobile.tsx` | — | ⚠️ N/A | React media-query hook; Phoenix uses Tailwind `md:` responsive classes |
| `hooks/use-toast.ts` | — | ⚠️ N/A | Radix toast state; Phoenix uses `put_flash` |

---

## 2. Behavioral Parity

| Behavior | React | Phoenix | Match? |
|---|---|---|---|
| **Header scroll shrink** | `useState` + `window.scrollY > 20` → toggles padding/logo size classes | `ScrollShrink` hook in `app.js` → `window.scrollY > 20` → toggles same classes via DOM manipulation | ✅ Same threshold, same class toggles |
| **Theme toggle** | `localStorage.setItem("theme", ...)`, adds/removes `.light` on `<html>` | `ThemeToggle` hook → `localStorage.setItem("theme", ...)`, adds/removes `.light` + `.dark` on `<html>` | ⚠️ Phoenix also toggles `.dark` class (React doesn't). Same `localStorage` key. |
| **Mobile menu** | `useState(false)` toggle, conditional render | `JS.toggle(to: "#mobile-menu")` on click, hidden div with `hidden` class | ✅ Same behavior, different mechanism |
| **Copy to clipboard** | `navigator.clipboard.writeText()` inline | `data-copy-button` delegated click in `app.js` + `CopyCode` hook | ✅ Same behavior. Phoenix adds checkmark icon feedback; React shows "COPIED!" text |
| **Scroll reveal (home)** | framer-motion `whileInView` with staggered delays | `ScrollReveal` hook with IntersectionObserver → adds `animate-fade-in` class | ⚠️ Phoenix lacks per-element stagger delays. Sections appear all-at-once when visible. |
| **Sidebar collapse (docs)** | React `useState` toggle | LiveView `handle_event("toggle_sidebar")` | ✅ Same behavior |
| **ToC active highlight** | `IntersectionObserver` in `DocsRightSidebar` | `ScrollSpy` hook exists but **not wired** to docs right sidebar | ❌ ToC active highlight not working in Phoenix |
| **⌘K search** | Dialog with keyboard nav, fuzzy filter | Static search box UI placeholder (no functionality) | ❌ Search not functional in Phoenix |

---

## 3. CSS Token Parity

### :root (dark mode) — All tokens match exactly

| Token | React (`index.css`) | Phoenix (`app.css`) | Match? |
|---|---|---|---|
| `--background` | `0 0% 4%` | `0 0% 4%` | ✅ |
| `--foreground` | `0 0% 91%` | `0 0% 91%` | ✅ |
| `--surface` | `0 0% 7%` | `0 0% 7%` | ✅ |
| `--elevated` | `0 0% 10%` | `0 0% 10%` | ✅ |
| `--card` | `0 0% 7%` | `0 0% 7%` | ✅ |
| `--primary` | `152 100% 50%` | `152 100% 50%` | ✅ |
| `--primary-foreground` | `0 0% 4%` | `0 0% 4%` | ✅ |
| `--secondary` | `0 0% 10%` | `0 0% 10%` | ✅ |
| `--secondary-foreground` | `0 0% 85%` | `0 0% 85%` | ✅ |
| `--muted` | `0 0% 16%` | `0 0% 16%` | ✅ |
| `--muted-foreground` | `0 0% 40%` | `0 0% 40%` | ✅ |
| `--accent-green` | `152 100% 50%` | `152 100% 50%` | ✅ |
| `--accent-yellow` | `43 100% 50%` | `43 100% 50%` | ✅ |
| `--accent-cyan` | `192 100% 50%` | `192 100% 50%` | ✅ |
| `--accent-red` | `0 73% 71%` | `0 73% 71%` | ✅ |
| `--border` | `0 0% 16%` | `0 0% 16%` | ✅ |
| `--border-strong` | `0 0% 23%` | `0 0% 23%` | ✅ |
| `--ring` | `152 100% 50%` | `152 100% 50%` | ✅ |
| `--radius` | `0.375rem` | `0.375rem` | ✅ |
| `--code-*` (all 7) | _(identical)_ | _(identical)_ | ✅ |
| `--sidebar-*` (all 8) | _(identical)_ | _(identical)_ | ✅ |

### .light mode — All tokens match exactly

| Token | React | Phoenix | Match? |
|---|---|---|---|
| All 30+ light-mode tokens | _(identical values)_ | _(identical values)_ | ✅ |

### Component classes — All match

| Class | React | Phoenix | Match? |
|---|---|---|---|
| `.package-card-*` | ✅ defined | ✅ defined | ✅ |
| `.badge-*` | ✅ defined | ✅ defined | ✅ |
| `.code-block`, `.code-header` | ✅ defined | ✅ defined | ✅ |
| `.metric-card` | ✅ defined | ✅ defined | ✅ |
| `.feature-card` | ✅ defined | ✅ defined | ✅ |
| `.cta-glow` | ✅ defined | ✅ defined | ✅ |
| `.nav-surface` | ✅ defined | ✅ defined | ✅ |
| `.gradient-text` | ✅ defined | ✅ defined | ✅ |
| `.syntax-*` (9 classes) | ✅ defined | ✅ defined | ✅ |
| `.text-accent-*` / `.bg-accent-*` / `.border-accent-*` | ✅ defined | ✅ defined | ✅ |

### Phoenix-only additions (not in React)

| Token/Class | Purpose |
|---|---|
| `.icon-card`, `.numbered-card`, `.quickstart-card` | Extra component classes for docs cards |
| `.neon-glow`, `.neon-border` | Decorative effects |
| `@theme inline` block | Petal Components compat shim (legacy) |
| `--animate-pulse-glow` | Extra animation |

### Tailwind config mechanism

| Aspect | React | Phoenix |
|---|---|---|
| Config format | `tailwind.config.ts` with `extend.colors` | `@theme inline` block in `app.css` mapping `--color-*` to CSS vars |
| Plugin | `tailwindcss-animate` | `@tailwindcss/forms`, `@tailwindcss/typography`, custom heroicons |
| Font | `IBM Plex Mono` in config + CSS | `IBM Plex Mono` in `@theme inline` + CSS |

---

## 4. Missing / Incomplete Ports — Prioritized

| Priority | Component | Impact | Recommendation |
|---|---|---|---|
| **P1** | `DocsSearch` (⌘K dialog) | Users can't search docs. Core UX feature. | Port as LiveView component with `phx-window-keydown` for ⌘K. Build search index server-side. |
| **P1** | `DocsBreadcrumb` | Users lose orientation in deep docs pages. | Port as function component; derive from `@request_path`. |
| **P2** | `DocsPrevNext` | Users can't navigate sequentially through docs. | Port as function component; pass prev/next from `sidebar_nav()` based on current path. |
| **P2** | ToC active highlight | Right sidebar ToC doesn't highlight current section on scroll. | Wire existing `ScrollSpy` hook to `docs_right_sidebar`, or add IntersectionObserver hook. |
| **P3** | `DocsAskAI` | AI question form not ported. | Low priority — the button placeholder exists in `docs_header`. Full form can wait. |
| **P3** | Framer-motion stagger | Home page elements don't stagger-animate in. | Cosmetic. Could add CSS `animation-delay` per element if desired. |
| **P3** | Footer logo parity | React uses `jido-logo.png`; Phoenix uses gradient "J" block. | Intentional — gradient block is consistent with header. No action needed. |
| **P4** | `DocsFooter` (full version) | Phoenix docs footer is minimal vs. React's 4-column footer. | Low priority — marketing footer handles the full version. Docs footer is intentionally lighter. |
| **P4** | shadcn/ui primitives | 49 React UI components not ported. | Not needed — Phoenix uses native HEEx + Tailwind. Only port specific components if new features require them. |
