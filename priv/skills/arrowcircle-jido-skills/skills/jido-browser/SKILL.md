---
name: jido-browser
description: Builder-oriented guidance for the upstream `jido_browser` package. Use when Codex needs to build browser-backed Jido automations, wrap navigation or extraction flows in actions, turn browser docs into runnable examples, or review `jido_browser` boundaries versus `req_llm` and app-specific scraping code.
---

# Jido Browser

`jido_browser` is the upstream Hex package name.

## Start Here

Use this skill when the workflow needs a browser, page state, or DOM interaction rather than plain HTTP requests.

Good triggers:
- "Build a Jido agent that logs in and gathers data from a website."
- "Wrap a browser step in a `Jido.Action`."
- "Turn the browser package docs into a runnable demo."
- "Review whether this should use browser automation or a simpler HTTP client."

Read [references/builder-notes.md](references/builder-notes.md) before implementing when selectors, navigation state, or safety limits matter.

## Primary Workflows

### Build browser-backed actions

- Separate navigation, observation, and mutation steps.
- Keep selectors and site assumptions explicit so the action can fail predictably when a page changes.
- Prefer small page operations over giant "do everything" browser actions.

### Decide when browser automation is justified

- Use `jido_browser` only when the target behavior depends on rendering, authentication state, or DOM interaction.
- Prefer `req_llm`, Req, or API clients for stable JSON or HTML endpoints.
- Minimize the amount of browser state that leaks into the rest of the agent runtime.

### Turn docs into runnable examples

- Choose one real browsing scenario such as login, extract, click, or form submit.
- Show the browser step inside a broader Jido workflow only after the page-level behavior is clear.
- Add waits, retries, or assertions only when the docs justify them.

### Review boundaries

- Keep DOM and navigation logic in `jido_browser`.
- Keep prompt or reasoning loops in `jido` or `jido_ai`.
- Keep site-specific product logic in the application layer.

## Build Checklist

- Confirm that the target site really requires browser automation.
- Define selectors, navigation transitions, and failure conditions up front.
- Capture only the page data the next step needs.
- Add tests or examples that tolerate timing and rendering variability.

## Boundaries

- Do not use this skill for generic web scraping when plain HTTP is enough.
- Do not hide brittle selectors inside unrelated business logic.
- Do not promise support for site behaviors the docs do not cover.
