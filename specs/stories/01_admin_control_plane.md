# Epic 1 - Production Auth and Admin Control Plane

### ST-ADM-001 Production-safe admin routing scaffold
#### Epic
Epic 1 - Production Auth and Admin Control Plane
#### Dependencies
- None
#### Scope
- Move protected admin app routes out of compile-time `:dev_routes` gating.
- Keep `/dev/mailbox` inside `if Application.compile_env(:agent_jido, :dev_routes)` only.
- Place protected admin routes in a production-safe scope using:
  - pipeline: `[:browser, :require_authenticated_user, :require_admin_user]`
  - authenticated LiveView session + admin `on_mount` enforcement
- Keep route placement aligned with `phx.gen.auth` session constraints:
  - do not duplicate `live_session` names
  - ensure `@current_scope.user` remains the auth source for templates/live views
#### Out of Scope
- Building the new admin landing UI.
- Changing login redirect behavior.
#### Acceptance Criteria
- Admin-only tools are available without relying on compile-time `:dev_routes`.
- `/dev/mailbox` remains dev-only.
- Unauthenticated and non-admin users cannot access admin app surfaces.
- Router structure clearly separates dev-only and production-safe admin surfaces.
#### Test Cases
- Unauthenticated request to protected admin route redirects to `/users/log-in`.
- Authenticated non-admin request to protected admin route is blocked.
- Authenticated admin request succeeds.

### ST-ADM-002 Add `/dashboard` admin landing LiveView with admin tool links
#### Epic
Epic 1 - Production Auth and Admin Control Plane
#### Dependencies
- ST-ADM-001
#### Scope
- Add `AgentJidoWeb.AdminDashboardLive` (or equivalently named module) rendered at `/dashboard`.
- Route must be in an authenticated + admin-protected scope and live session.
- Dashboard includes link entry points for:
  - Arcana dashboard
  - Jido Studio
  - ContentOps dashboards
- Dashboard should present clear "admin control plane" context.
#### Out of Scope
- Deep redesign of Arcana/Jido/ContentOps pages.
- Search or ChatOps-specific UX.
#### Acceptance Criteria
- `/dashboard` renders successfully for authenticated admins.
- `/dashboard` is blocked for unauthenticated and authenticated non-admin users.
- All expected admin links are visible and route correctly.
#### Test Cases
- LiveView auth matrix for `/dashboard`.
- Link presence assertions for all required admin tools.

### ST-ADM-003 Admin-aware post-login redirect policy
#### Epic
Epic 1 - Production Auth and Admin Control Plane
#### Dependencies
- ST-ADM-002
#### Scope
- Update sign-in redirect behavior:
  - admin users default to `/dashboard`
  - non-admin users keep existing default policy
- Apply behavior consistently for password and magic-link flows.
- Ensure existing `user_return_to` behavior still takes precedence when set.
#### Out of Scope
- User role model changes.
- Registration flow changes.
#### Acceptance Criteria
- Admin login lands on `/dashboard` when no return path is set.
- Non-admin login retains existing destination.
- Existing return-to behavior is unchanged for both roles.
#### Test Cases
- Controller tests for admin and non-admin redirect outcomes.
- Return-to session override tests.

### ST-ADM-004 Auth/admin regression tests plus admin bootstrap runbook
#### Epic
Epic 1 - Production Auth and Admin Control Plane
#### Dependencies
- ST-ADM-003
#### Scope
- Update and extend auth/admin tests to cover production-safe control-plane routing.
- Add a runbook doc in `specs/` describing single-admin bootstrap:
  - `ADMIN_EMAIL` seeding path
  - `mix accounts.promote_admin <email>`
  - production verification checklist
- Align tests that still assume prior `/dev/*` access patterns.
#### Out of Scope
- Infrastructure automation outside repository docs.
- Multi-admin role management enhancements.
#### Acceptance Criteria
- Regression tests cover auth matrix and redirect behavior for control-plane routes.
- Runbook includes concrete bootstrap and validation steps.
- Existing registration-disabled behavior remains intact.
#### Test Cases
- `mix test` targeted auth/router/live tests for admin and non-admin flows.
- Manual runbook sanity check against current commands and config names.
