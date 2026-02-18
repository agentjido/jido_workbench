# Admin Bootstrap Runbook (Single Admin)

## Purpose

Bootstrap exactly one admin user for production control-plane access.

This runbook covers:

- `ADMIN_EMAIL` seed bootstrap
- `mix accounts.promote_admin <email>`
- Production verification checks for auth and admin routing

## Path A: Seed-time bootstrap with `ADMIN_EMAIL`

Use this when provisioning a new environment or re-running seeds.

1. Set `ADMIN_EMAIL` to the target admin address in the shell where seeds run.
2. Run `mix run priv/repo/seeds.exs`.
3. Confirm seed output:
- `Created admin user: <email>` when the user does not exist yet
- `Promoted existing user to admin: <email>` when the user already exists

Notes:

- `ADMIN_EMAIL` is read in `priv/repo/seeds.exs`.
- If `ADMIN_EMAIL` is unset or blank, no admin promotion happens.

## Path B: Promote an existing account with Mix task

Use this when the user already exists and you want to grant admin access directly.

1. Run `mix accounts.promote_admin <email>`.
2. Confirm task output:
- `Promoted <email> to admin.` on success
- `No user found with email: <email>` when no matching account exists

If the user does not exist yet, create/login the user first, then rerun `mix accounts.promote_admin <email>`.

## Production Verification Checklist

After bootstrap, verify these behaviors:

1. Admin login default redirect:
- Log in as admin without `user_return_to`.
- Confirm redirect lands on `/dashboard`.

2. Route access matrix:
- Unauthenticated request to `/dashboard` redirects to `/users/log-in`.
- Authenticated non-admin request to `/dashboard` redirects to `/`.
- Authenticated admin request to `/dashboard` renders the admin control plane.
- Authenticated admin can access `/arcana`, `/dev/jido`, `/dev/contentops`, `/dev/contentops/github`.

3. Registration remains disabled:
- `GET /users/register` returns `404`.

4. Dev-only mailbox remains dev-only:
- `/dev/mailbox` should not be relied on in production workflows.

## Source of truth

- Seed bootstrap logic: `priv/repo/seeds.exs`
- Admin promotion task: `lib/mix/tasks/accounts.promote_admin.ex`
- Admin routing and auth plugs: `lib/agent_jido_web/router.ex`
