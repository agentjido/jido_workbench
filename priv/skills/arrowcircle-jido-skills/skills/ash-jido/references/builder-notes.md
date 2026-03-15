# Ash Jido Builder Notes

## Use This Reference For

- Exposing Ash actions to Jido without breaking domain boundaries.
- Preserving Ash context such as domain, actor, and tenant in generated actions.
- Triggering agents from Ash changes after successful transactions.

## Source Highlights

- `ash_jido` bridges Ash resources with Jido agents and can generate `Jido.Action` modules from Ash actions.
- The docs show exposing selected actions through an Ash DSL and using those actions in signal routes.
- The Ash `domain` context is required for generated action execution.

## Implementation Heuristics

- Expose only the actions that make sense for agent use.
- Keep Ash authorization and validation authoritative.
- Emit signals after successful domain work instead of folding orchestration into resource actions.
- Preserve naming clarity between Ash actions and generated Jido actions.

## Narrowing Rules

- If the request is ordinary Ash modeling with no Jido boundary, this is the wrong skill.
- If the workflow is mostly agent orchestration, pair with `jido`.

## Sources

- https://jido.run/ecosystem
- https://hexdocs.pm/jido/ash-integration.html
- https://hex.pm/packages/ash_jido
