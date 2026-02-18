# Epic 4 - Content Rollout and Landing Execution (Infrastructure First)

### ST-CONT-001 Define content publish DoD and freshness checklist cadence
#### Epic
Epic 4 - Content Rollout and Landing Execution
#### Dependencies
- None
#### Scope
- Add a canonical "definition of done" for publishing content pages, including:
  - proof alignment requirement
  - placeholder prohibition
  - route/content sync requirement
  - draft-flag removal gate criteria
- Define freshness checklist and release cadence process in `specs/`.
- Specify minimum checks before changing `draft: true` to `draft: false`.
#### Out of Scope
- Writing the full content bodies for all sections.
#### Acceptance Criteria
- DoD and freshness checklist are documented and discoverable.
- Story cards for later content waves can reference this as a hard gate.
#### Test Cases
- Documentation review against existing `specs` governance files.

### ST-CONT-002 Add missing docs IA stub pages from `specs/TODO.md`
#### Epic
Epic 4 - Content Rollout and Landing Execution
#### Dependencies
- ST-CONT-001
#### Scope
- Add missing docs files under `priv/pages/docs/` as stubs with valid frontmatter:
  - `core-concepts.md`
  - `guides.md` or `guides/index.md`
  - `reference.md` or `reference/index.md`
  - `architecture.md`
  - `production-readiness-checklist.md`
  - `security-and-governance.md`
  - `incident-playbooks.md`
- Ensure pages compile and are routable via the existing Pages pipeline.
#### Out of Scope
- Full production copy for these docs pages.
#### Acceptance Criteria
- All missing docs IA entries exist as valid pages in the docs pipeline.
- New routes resolve without breaking existing docs behavior.
#### Test Cases
- Pages compile/load tests.
- Route smoke tests for each added docs path.

### ST-CONT-003 Add `/ecosystem/package-matrix` route and page without slug collision
#### Epic
Epic 4 - Content Rollout and Landing Execution
#### Dependencies
- ST-CONT-001
#### Scope
- Add a dedicated package matrix experience at `/ecosystem/package-matrix`.
- Ensure no collision with existing `/ecosystem/:id` package detail routing.
- Implement as explicit route/page strategy that is robust against package id overlap.
#### Out of Scope
- Rebuilding ecosystem detail pages.
- Advanced filtering UX beyond initial matrix.
#### Acceptance Criteria
- `/ecosystem/package-matrix` resolves reliably.
- Existing package detail pages still resolve via `/ecosystem/:id`.
- Collision behavior is explicitly tested.
#### Test Cases
- Route precedence tests for static path vs dynamic `:id`.
- Render tests for matrix page and representative package detail pages.
