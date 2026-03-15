# Jido Browser Builder Notes

## Use This Reference For

- Deciding whether browser automation is the right tool.
- Splitting page work into navigation, observation, and mutation steps.
- Keeping browser workflows small enough to test and debug.

## Source Highlights

- The package is positioned as browser-use inspired AI browser automation for Elixir.
- The builder value is controlled browser interaction inside Jido workflows, not generic scraping advice.
- Browser state is usually the brittle part of the system, so the skill should keep that boundary obvious.

## Implementation Heuristics

- Prefer one page objective per action.
- Treat selectors and waits as explicit assumptions.
- Keep browser setup and teardown outside the business logic when possible.
- Escalate to application-specific code when a site workflow is highly bespoke.

## Narrowing Rules

- If a plain HTTP request or API call can solve the task, do not use browser automation.
- If the docs do not document a browser capability, avoid claiming it is supported.

## Sources

- https://jido.run/ecosystem
- https://hexdocs.pm/jido_browser/readme.html
- https://hex.pm/packages/jido_browser
