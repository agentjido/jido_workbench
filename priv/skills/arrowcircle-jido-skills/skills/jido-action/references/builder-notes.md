# Jido Action Builder Notes

## Use This Reference For

- Designing action contracts before writing code.
- Reviewing whether a module is truly one action or actually orchestration.
- Mapping action composition to the right higher-level Jido package.

## Source Highlights

- `Jido.Action` is the package's central abstraction for executable units of work.
- The docs emphasize explicit params, validation, and predictable execution.
- Builder tasks usually fall into three buckets: new action scaffolds, adapter wrappers, and action reviews.

## Implementation Heuristics

- Keep actions small, typed, and composable.
- Prefer deterministic outputs that other actions or agents can consume.
- Push branching, planning, and scheduling up into agent/runtime layers.
- Name actions after the business operation, not the calling screen or job queue.

## Narrowing Rules

- If the user is really building an agent loop, switch to `jido`.
- If the main problem is event shape or dispatch, switch to `jido-signal`.

## Sources

- https://jido.run/ecosystem
- https://hexdocs.pm/jido_action/readme.html
- https://hex.pm/packages/jido_action
- https://hexdocs.pm/jido/readme.html
