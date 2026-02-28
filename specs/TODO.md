# Specs Backlog (Open Items Only)

Last updated: 2026-02-28

This file tracks active open spec/documentation work. Completed implementation history belongs in commit history and PRs, not here.

## P0

- [ ] Normalize metadata headers across canonical spec files (`Status`, `Owner`, `Last updated`, `Scope`) so contributors can quickly tell authority and freshness.
- [ ] Remove or label remaining stale path references in research docs (`brainstorms/*`) that still reference retired `priv/documentation/*` locations.

## P1

- [ ] Resolve training visibility policy conflict:
  - `specs/runbooks/release_punchlist.md` assumes training links are hidden.
  - Router/pages currently expose `/training` routes.
  - Decide policy and document it in one canonical place.
- [ ] Reduce duplication between `positioning.md`, `persona-journeys.md`, and `proof.md` by promoting one canonical owner for persona promises and linking out from the other two.
- [ ] Add at least one real audit artifact template under `specs/audits/` (route parity, proof coverage, or link integrity) so contributor audits produce consistent outputs.

## P2

- [ ] Split `docs-manifesto.md` into:
  - concise contributor rules (normative)
  - long-form rationale (reference)
- [ ] Add a lightweight stale-reference lint check for specs (e.g., fail CI on `priv/documentation/` or other retired path patterns in canonical docs).
