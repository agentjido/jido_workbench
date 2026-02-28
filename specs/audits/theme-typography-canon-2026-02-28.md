# Theme + Typography Canon (2026-02-28)

This document defines the canonical color and text layout system for Agent Jido and records the current consistency audit baseline.

## 1) Canonical Theme Foundation

Source of truth: `assets/css/app.css` (`:root` for dark, `.light` for light).

### Core semantic tokens

| Token | Dark | Light |
|---|---|---|
| `--background` | `0 0% 4%` | `40 33% 98%` |
| `--foreground` | `0 0% 91%` | `24 10% 10%` |
| `--surface` | `0 0% 7%` | `0 0% 100%` |
| `--elevated` | `0 0% 10%` | `40 20% 96%` |
| `--muted-foreground` | `0 0% 40%` | `24 8% 45%` |
| `--border` | `0 0% 16%` | `24 6% 91%` |
| `--primary` | `152 100% 50%` | `160 84% 39%` |

### Accent/intent tokens

| Intent | Token | Dark | Light |
|---|---|---|---|
| Success | `--accent-green` | `152 100% 50%` | `160 84% 39%` |
| Warning | `--accent-yellow` | `43 100% 50%` | `32 95% 44%` |
| Info | `--accent-cyan` | `192 100% 50%` | `189 94% 43%` |
| Danger | `--accent-red` | `0 73% 71%` | `0 72% 51%` |

## 2) Canonical Color Usage Rules

1. Use semantic tokens/classes only (`text-foreground`, `text-muted-foreground`, `bg-card`, `border-border`, `text-accent-*`).
2. Do not use hardcoded palette classes in LiveViews/components (`text-red-400`, `bg-amber-500/10`, `text-zinc-700`, etc.).
3. Status chips/badges must map to intent tokens:
   - success: `accent-green`
   - warning: `accent-yellow`
   - info: `accent-cyan`
   - danger/error: `accent-red`
4. Keep non-status body copy on `foreground`/`muted-foreground`; reserve accent colors for signal, state, and emphasis.

## 3) Canonical Text Layout Rules

These rules address copy that appears visually under-filled or inconsistent across pages.

1. **Page shell width**: keep top-level marketing containers aligned to nav width (`max-w-[1000px]`).
2. **Reading measure**:
   - long-form body copy target: `66ch` to `78ch`
   - short supporting copy target: `52ch` to `64ch`
   - avoid very narrow body copy (`< 45ch`) on desktop unless intentionally callout-style
3. **Alignment**:
   - default body copy: left-aligned
   - center alignment only for hero/intro blocks and short blurbs
4. **Justification policy**:
   - default: no full justification for UI copy
   - only use `text-justify` for long-form docs prose when paired with `hyphens-auto`
5. **Vertical rhythm**:
   - section spacing: `py-12` baseline, `md:py-16` for major sections
   - paragraph leading: `leading-relaxed` for long copy
6. **Consistency rule**:
   - if two pages share the same template type (marketing index/detail/docs), keep text measure + alignment policy consistent unless a clear content reason exists.

## 4) Audit Snapshot (2026-02-28)

### Browser verification

Routes sampled in browser for both modes: `/`, `/features`, `/ecosystem`, `/ecosystem/matrix`, `/examples`, `/community`, `/docs`, `/about`, `/getting-started`, `/blog`.

- Theme switching correctly applies token sets for dark and light mode.
- Nav/content shell width is generally aligned at `1000px` on marketing pages.
- Docs shell intentionally uses a different structure (sidebar + content rails).

### Code consistency verification

Search baseline after normalization:

- `lib/agent_jido_web/live/**` and `lib/agent_jido_web/components/**` contain **no hardcoded Tailwind palette classes** for text/bg/border (`zinc-*`, `red-*`, `amber-*`, `green-*`, `cyan-*`, etc.).
- Status color usage is now token-based (`accent-*`) across LiveViews and shared components.

## 5) Follow-up Tightening Opportunities

1. Standardize intro paragraph measure classes across marketing pages (several use mixed `max-w-*` tokens).
2. Add shared utility classes for copy measure/alignment in `app.css` to avoid repeating per-view decisions.
3. Add regression tests asserting semantic classes for status badges and alerts in key LiveViews.
