# Epic 4 - Feature Content Waves

### ST-CONT-004 Features content wave A (first 3 pages)
#### Epic
Epic 4 - Content Rollout and Landing Execution
#### Dependencies
- ST-CONT-001
#### Scope
- Replace placeholder content for these first three feature pages:
  - `priv/pages/features/reliability-by-architecture.md`
  - `priv/pages/features/multi-agent-coordination.md`
  - `priv/pages/features/operations-observability.md`
- Remove `draft: true` only if each page meets ST-CONT-001 DoD.
- Keep messaging aligned to positioning/proof docs in `specs/`.
#### Out of Scope
- Editing the remaining four feature pages.
#### Acceptance Criteria
- Selected pages contain non-placeholder, publishable content.
- Each page either passes DoD and has `draft: false`, or remains draft with rationale.
- Routes render with coherent copy and no "Content coming soon." text.
#### Test Cases
- Route smoke tests for the three pages.
- Content checks confirming placeholder text removal.

### ST-CONT-005 Features content wave B (remaining 4 pages)
#### Epic
Epic 4 - Content Rollout and Landing Execution
#### Dependencies
- ST-CONT-004
#### Scope
- Replace placeholder content for remaining feature pages:
  - `priv/pages/features/incremental-adoption.md`
  - `priv/pages/features/beam-for-ai-builders.md`
  - `priv/pages/features/jido-vs-framework-first-stacks.md`
  - `priv/pages/features/executive-brief.md`
- Apply ST-CONT-001 DoD before draft flag removal.
- Keep section-level consistency with wave A tone and structure.
#### Out of Scope
- Build and community section writing.
#### Acceptance Criteria
- All four remaining feature pages are non-placeholder.
- Draft flags are removed only when DoD is met per page.
- `/features` section no longer presents draft placeholder pages.
#### Test Cases
- Route smoke tests for all four pages.
- Content checks for placeholder removal and draft-flag correctness.
