# Epic 4 - Build and Community Content Waves

### ST-CONT-006 Build content wave A (`index` and first quickstart pages)
#### Epic
Epic 4 - Content Rollout and Landing Execution
#### Dependencies
- ST-CONT-001
#### Scope
- Replace placeholder content for initial build wave:
  - `priv/pages/build/index.md`
  - `priv/pages/build/quickstarts-by-persona.md`
  - `priv/pages/build/reference-architectures.md`
- Apply ST-CONT-001 DoD and draft-flag gate for each page.
#### Out of Scope
- Remaining build pages and community pages.
#### Acceptance Criteria
- Wave A build pages have non-placeholder content.
- Draft flags reflect DoD status per page.
- `/build` index is no longer placeholder copy.
#### Test Cases
- Route smoke tests for wave A pages.
- Content checks for placeholder removal.

### ST-CONT-007 Build content wave B (remaining build pages)
#### Epic
Epic 4 - Content Rollout and Landing Execution
#### Dependencies
- ST-CONT-006
#### Scope
- Replace placeholder content for remaining build pages:
  - `priv/pages/build/mixed-stack-integration.md`
  - `priv/pages/build/product-feature-blueprints.md`
- Ensure section consistency with wave A.
- Apply ST-CONT-001 DoD before removing draft flags.
#### Out of Scope
- Community section writing.
#### Acceptance Criteria
- Remaining build pages are non-placeholder.
- Build section pages consistently follow DoD and draft policy.
#### Test Cases
- Route smoke tests for both pages.
- Content checks for placeholder removal and correct draft-state.

### ST-CONT-008 Community content wave plus section final draft-flag pass
#### Epic
Epic 4 - Content Rollout and Landing Execution
#### Dependencies
- ST-CONT-001
#### Scope
- Replace placeholder content for community pages:
  - `priv/pages/community/index.md`
  - `priv/pages/community/learning-paths.md`
  - `priv/pages/community/adoption-playbooks.md`
  - `priv/pages/community/case-studies.md`
- Perform section-level final draft-flag pass using ST-CONT-001 DoD.
#### Out of Scope
- New community route architecture beyond existing pages.
#### Acceptance Criteria
- Community section has no placeholder body text.
- Draft flags reflect DoD criteria for all community pages.
- `/community` section feels launch-ready relative to the current roadmap.
#### Test Cases
- Route smoke tests for all four community pages.
- Content checks for placeholder removal and draft-state accuracy.
