# Jido Builder Notes

## Use This Reference For

- Mapping a request onto the right Jido concept: agent, directive, action, signal, or extension package.
- Designing end-to-end examples that stay small enough to understand.
- Reviewing whether orchestration belongs in core Jido or in a package-specific extension.

## Source Highlights

- The core docs center the framework around agents, actions, directives, and signals.
- Jido favors explicit orchestration and composable units over opaque agent magic.
- The package is the place to compose other ecosystem packages, not to duplicate them.

## Implementation Heuristics

- Start from lifecycle and boundaries, then pick the supporting packages.
- Prefer one clear runtime loop over many implicit callbacks.
- Keep examples observable through tests, signals, or telemetry.
- Reuse existing package abstractions before inventing new core concepts.

## Narrowing Rules

- If the task is mostly a package-specific adapter, switch to that package skill.
- If the proposed runtime feature is not documented, keep the skill guidance conservative and call out the gap.

## Sources

- https://jido.run/ecosystem
- https://hexdocs.pm/jido/readme.html
- https://github.com/agentjido/jido_run/issues/51
