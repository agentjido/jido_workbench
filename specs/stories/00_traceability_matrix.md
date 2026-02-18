# Story Traceability Matrix

Last updated: 2026-02-18

This matrix is the source of truth for `ralph_wiggum_loop.sh` traceability lookups.

| Story ID | Epic | Story Title | Story File | Depends On | Public Interfaces / Routes | Primary Validation |
| --- | --- | --- | --- | --- | --- | --- |
| ST-ADM-001 | Epic 1 | Production-safe admin routing scaffold | `specs/stories/01_admin_control_plane.md` | None | `/dev/mailbox` remains dev-only, admin app routes moved to production-safe scope | Router and auth access tests |
| ST-ADM-002 | Epic 1 | Add `/dashboard` admin landing LiveView with links to admin tools | `specs/stories/01_admin_control_plane.md` | ST-ADM-001 | `/dashboard` | LiveView render and authorization tests |
| ST-ADM-003 | Epic 1 | Admin-aware post-login redirect policy | `specs/stories/01_admin_control_plane.md` | ST-ADM-002 | login redirect to `/dashboard` for admins | Session controller and auth tests |
| ST-ADM-004 | Epic 1 | Auth/admin regression tests and admin bootstrap runbook | `specs/stories/01_admin_control_plane.md` | ST-ADM-003 | `ADMIN_EMAIL`, `mix accounts.promote_admin <email>` docs | Test suite updates + runbook review |
| ST-SRCH-001 | Epic 2 | Arcana site search context and normalized result model | `specs/stories/02_arcana_search.md` | None | `AgentJido.Search` API | Unit tests for search context |
| ST-SRCH-002 | Epic 2 | Build public `/search` LiveView | `specs/stories/02_arcana_search.md` | ST-SRCH-001 | `/search` | LiveView tests for query/result states |
| ST-SRCH-003 | Epic 2 | Add telemetry, failure fallback, nav entry, and full tests | `specs/stories/02_arcana_search.md` | ST-SRCH-002 | search nav entry + telemetry events | Integration tests and telemetry assertions |
| ST-CHOPS-001 | Epic 3 | Add authenticated admin ChatOps LiveView route under `/dashboard/...` | `specs/stories/03_chatops_console.md` | ST-ADM-002 | `/dashboard/chatops` | Router + auth gating tests |
| ST-CHOPS-002 | Epic 3 | Room and binding inventory panel wired to messaging services | `specs/stories/03_chatops_console.md` | ST-CHOPS-001 | ChatOps room inventory UI | LiveView tests with messaging fixtures |
| ST-CHOPS-003 | Epic 3 | Recent message timeline panel | `specs/stories/03_chatops_console.md` | ST-CHOPS-001 | ChatOps message timeline UI | LiveView tests for message rendering |
| ST-CHOPS-004 | Epic 3 | Action/run timeline with guardrail indicators | `specs/stories/03_chatops_console.md` | ST-CHOPS-002, ST-CHOPS-003 | authz status and mutation-enabled indicators | Timeline and policy visualization tests |
| ST-CHOPS-005 | Epic 3 | Test determinism hardening, durability decision note, and ChatOps runbook | `specs/stories/03_chatops_console.md` | ST-CHOPS-004 | deterministic test boot controls + ops docs | Chat tests pass with stable env behavior |
| ST-CONT-001 | Epic 4 | Content publish definition-of-done and freshness cadence checklist | `specs/stories/04_content_infra.md` | None | content governance checklist contract | Documentation and checklist validation |
| ST-CONT-002 | Epic 4 | Add missing docs IA stub pages from `specs/TODO.md` | `specs/stories/04_content_infra.md` | ST-CONT-001 | new docs routes/pages | Route and page compile tests |
| ST-CONT-003 | Epic 4 | Add `/ecosystem/package-matrix` page without slug collision | `specs/stories/04_content_infra.md` | ST-CONT-001 | `/ecosystem/package-matrix` | Route collision and render tests |
| ST-CONT-004 | Epic 4 | Features content wave A (first 3 pages) | `specs/stories/05_content_features.md` | ST-CONT-001 | `/features/*` content pages | Content quality and draft-flag checks |
| ST-CONT-005 | Epic 4 | Features content wave B (remaining 4 pages) | `specs/stories/05_content_features.md` | ST-CONT-004 | `/features/*` completion | Content quality and draft-flag checks |
| ST-CONT-006 | Epic 4 | Build content wave A (`index` and first quickstart pages) | `specs/stories/06_content_build_community.md` | ST-CONT-001 | `/build/*` wave A pages | Content quality and route tests |
| ST-CONT-007 | Epic 4 | Build content wave B (remaining build pages) | `specs/stories/06_content_build_community.md` | ST-CONT-006 | `/build/*` completion | Content quality and draft-flag checks |
| ST-CONT-008 | Epic 4 | Community content wave and section final draft-flag pass | `specs/stories/06_content_build_community.md` | ST-CONT-001 | `/community/*` | Content quality and draft-flag checks |
