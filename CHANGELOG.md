# Changelog

## Front-End Review — Phase 1–3 (Steps 1–9)

Systematic cleanup of the front-end after porting the new design from the React/Vite prototype (`jido-dev-relaunch/`) into Phoenix LiveView.

### Changed
- **Theme system unified** — single canonical toggle using `localStorage.theme` with `.light`/`.dark` classes on `<html>`. Removed legacy `ColorSchemeHook`, AlpineJS and js-cookie CDN scripts.
- **Fonts consolidated** — removed unused Google Fonts (Inter, VT323, JetBrains Mono). IBM Plex Mono is the sole mono/body font via `app.css`.
- **Shared Nav module** (`Jido.Nav`) — extracted logo, social icons, and link constants from MarketingLayouts and DocsComponents into a single source of truth.
- **CSS architecture documented** — added inline architecture comment to `app.css` explaining the two coexisting CSS systems (new custom properties vs legacy Petal shim) and their migration path. Fixed stale JetBrains Mono reference in `syntax.css`.

### Removed
- **Dead LiveViews** — `JidoLive`, `PageLive`, `FormLive`, `SettingsLive` (commented-out or unused routes).
- **Dead components** — `ChatComponents`, `PageHTML`, unused `Jido.UI` module (210 lines).
- **Dead JS hooks** — `scroll-bottom.js`, `message-history.js`, `color-scheme-hook.js`.
- **Dead routes** — `/settings`, commented-out `/jido`, `/live`, `/form` routes removed from router.
- **~1,600 lines** of dead code removed total across Elixir, JS, and HEEx.

### Still To Do
- Migrate `/blog`, `/cookbook`, `/catalog` from `workbench_layout` + `dark:` variants to new design system.
- Delete `WorkbenchLayout`, `Menu`, `MenuItems`, `menu.css` once all consumers are migrated.
- Remove Petal `default.css` import and `@theme inline` compat shim.
- React prototype parity check (Step 12).
