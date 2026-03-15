# Jido Memory Builder Notes

## Use This Reference For

- Choosing what an agent should remember and why.
- Separating memory policy from storage backend details.
- Building examples where memory changes agent behavior in an observable way.

## Source Highlights

- The ecosystem positions memory as a distinct concern instead of hiding it in agent state alone.
- Memory workflows depend on clear write/read timing and scope.
- `jido_ai` can inform AI-facing memory behavior, but storage and recall boundaries must stay explicit.

## Implementation Heuristics

- Store only the data a later step can actually use.
- Prefer explicit memory scopes such as run, conversation, or long-lived knowledge.
- Keep recall criteria deterministic enough to test.
- Treat summarization or embedding steps as separate concerns from persistence.

## Narrowing Rules

- If the task is generic persistence with no agent recall behavior, this is the wrong skill.
- If the chosen backend imposes limits the docs do not cover, document the assumption instead of inventing features.

## Sources

- https://jido.run/ecosystem
- https://hexdocs.pm/jido/readme.html
- https://hexdocs.pm/jido_ai/readme.html
