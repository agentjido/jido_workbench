# Jido BehaviorTree Builder Notes

## Use This Reference For

- Turning branching requirements into explicit tree structures.
- Keeping documented behavior separate from reasonable inference where docs are thin.
- Reviewing whether a tree is clearer than normal Elixir control flow.

## Source Highlights

- Public material for this package is thinner than for core Jido packages.
- The safest builder workflow is to model sequences, selectors, guards, and fallback paths without assuming undocumented node types.
- The tree should orchestrate actions, not replace them.

## Implementation Heuristics

- Keep trees shallow until the need for deeper composition is obvious.
- Name nodes by decision intent, not UI labels.
- Surface branch outcomes through tests or signals.
- Write examples that make each branch easy to reason about.

## Narrowing Rules

- If a behavior depends on undocumented runtime hooks, treat it as unsupported.
- If plain Elixir branching is simpler and equally observable, prefer it.

## Sources

- https://jido.run/ecosystem
- https://hexdocs.pm/jido/readme.html
- https://github.com/agentjido/jido_run/issues/51
