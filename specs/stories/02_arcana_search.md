# Epic 2 - Site-wide Arcana Search LiveView

### ST-SRCH-001 Add Arcana site search context and normalized result model
#### Epic
Epic 2 - Site-wide Arcana Search LiveView
#### Dependencies
- None
#### Scope
- Add `AgentJido.Search` context module for Arcana-backed site search.
- Implement query API targeting collections:
  - `site_docs`
  - `site_blog`
  - `site_ecosystem`
- Default to `mode: :hybrid` with safe fallbacks on backend errors.
- Normalize result shape to include:
  - `title`
  - `snippet`
  - `url` or canonical route
  - `source_type` (docs/blog/ecosystem)
  - optional `score`
#### Out of Scope
- LiveView UI and routing.
- Navigation/header updates.
#### Acceptance Criteria
- Search context returns normalized cross-collection results.
- Result shape is stable and testable independent of UI layer.
- Context provides deterministic fallback behavior for Arcana failures.
#### Test Cases
- Unit tests for empty query handling, populated results, no results, and backend error fallback.

### ST-SRCH-002 Build public `/search` LiveView with query/result rendering
#### Epic
Epic 2 - Site-wide Arcana Search LiveView
#### Dependencies
- ST-SRCH-001
#### Scope
- Add a public route at `/search`.
- Implement LiveView for search input and result rendering using `AgentJido.Search`.
- Include states:
  - no query
  - loading
  - query with results
  - query with no results
- Result cards must include source-type label and destination link.
#### Out of Scope
- Telemetry and nav integration.
- Advanced ranking controls.
#### Acceptance Criteria
- `/search` works without authentication.
- Querying displays cross-collection results with valid links.
- Empty and no-result states render with clear UX.
#### Test Cases
- LiveView tests for each primary UI state.
- Route availability test for `/search`.

### ST-SRCH-003 Add telemetry, failure fallback UX, nav entry, and full tests
#### Epic
Epic 2 - Site-wide Arcana Search LiveView
#### Dependencies
- ST-SRCH-002
#### Scope
- Instrument search query lifecycle telemetry:
  - query issued
  - success/failure
  - latency measurement
- Add explicit error fallback messaging in the UI when backend search fails.
- Add search entry point in site navigation/header.
- Expand tests to include telemetry assertions and failure rendering.
#### Out of Scope
- Relevance model tuning and A/B experimentation.
#### Acceptance Criteria
- Search telemetry emits consistently for success/failure flows.
- Users see graceful fallback UI on Arcana failures.
- `/search` is discoverable via primary navigation.
#### Test Cases
- Telemetry event assertions.
- Failure-path UI assertions.
- End-to-end LiveView behavior regression checks.
