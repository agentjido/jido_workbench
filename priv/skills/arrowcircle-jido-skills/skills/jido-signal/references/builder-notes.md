# Jido Signal Builder Notes

## Use This Reference For

- Designing signal contracts before choosing a transport.
- Reviewing producer and consumer boundaries.
- Translating docs into practical event flow examples.

## Source Highlights

- The package emphasizes simple, safe, standard signal handling in Elixir.
- The docs position signals as structured events rather than generic message maps.
- A builder workflow usually starts with signal shape, then dispatch, then transport adapters.

## Implementation Heuristics

- Treat signals as contracts, not logging blobs.
- Keep compatibility rules visible when multiple consumers exist.
- Prefer a small number of meaningful event types over dozens of near-duplicates.
- Separate dispatch concerns from business logic whenever possible.

## Narrowing Rules

- If the task is about queues, brokers, or external transports, pair with `jido-messaging`.
- If the task is about agent control flow instead of events, switch to `jido`.

## Sources

- https://jido.run/ecosystem
- https://hexdocs.pm/jido_signal/readme.html
- https://hex.pm/packages/jido_signal
- https://hexdocs.pm/jido/readme.html
