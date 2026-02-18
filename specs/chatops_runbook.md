# ChatOps Production Runbook (ST-CHOPS-005)

## Purpose

Run and validate the ContentOps ChatOps subsystem in production with predictable startup and health checks.

## Required Environment Variables

| Variable | Required | Purpose |
|---|---|---|
| `CONTENTOPS_CHAT_ENABLED` | Yes | Enables ChatOps supervisor boot (`true` to run ChatOps). |
| `TELEGRAM_BOT_TOKEN` | Yes when chat is enabled | Telegram bot credential. |
| `DISCORD_BOT_TOKEN` | Yes when chat is enabled | Discord bot credential. |
| `TELEGRAM_CHAT_ID` | Yes | Telegram room identifier for the shared ChatOps room binding. |
| `DISCORD_CHANNEL_ID` | Yes | Discord channel identifier for the shared ChatOps room binding. |
| `CONTENTOPS_ROOM_ID` | Optional | Internal room ID (default: `contentops:lobby`). |
| `CONTENTOPS_ROOM_NAME` | Optional | Internal room display name (default: `ContentOps Lobby`). |

Notes:

- `TELEGRAM_CHAT_ID` and `DISCORD_CHANNEL_ID` are used together to define the shared room/channel mapping.
- If both are present, runtime config overwrites static bindings with env-provided mapping.

## Room/Channel Mapping

Default mapping (or env override) creates one shared logical room:

| Internal room | Telegram binding | Discord binding |
|---|---|---|
| `CONTENTOPS_ROOM_ID` (default `contentops:lobby`) | `TELEGRAM_CHAT_ID` | `DISCORD_CHANNEL_ID` |

The room name shown in ChatOps UI is `CONTENTOPS_ROOM_NAME` (default `ContentOps Lobby`).

## Startup Procedure

1. Export required variables in the release environment with `CONTENTOPS_CHAT_ENABLED=true`.
2. Boot application (`mix phx.server` in non-release local prod simulation or release command in deployment platform).
3. Confirm process boot from logs:
- no missing token errors
- no binding conflict errors from `AgentJido.ContentOps.Chat.BindingBootstrapper`
- no repeated subscription warnings from `AgentJido.ContentOps.Chat.Bridge`
4. Open `/dashboard/chatops` as an authenticated admin and confirm the page renders.

## Health Validation Checklist

1. Verify runtime config and enabled flag:
- `AgentJido.ContentOps.Chat.Config.load!()` returns `enabled: true`.

2. Verify room and binding inventory:
- `AgentJido.ContentOps.Messaging.list_rooms(limit: 10)` contains the expected room.
- `AgentJido.ContentOps.Messaging.list_room_bindings("<room_id>")` returns Telegram and Discord bindings.

3. Validate channel bridge path:
- Send a test message from Telegram room; confirm relay appears in Discord.
- Send a test message from Discord channel; confirm relay appears in Telegram.

4. Validate ChatOps command path:
- Send `/ops status` in an approved channel/user context.
- Confirm reply is delivered and recent activity appears in `/dashboard/chatops`.

5. Validate guardrail visibility:
- In `/dashboard/chatops`, confirm mutation-enabled indicator and authz counters are visible.
- Confirm blocked/unauthorized actions are visibly distinct from successful runs.

## Failure Triage

- `CONTENTOPS_CHAT_ENABLED=true` with missing `TELEGRAM_BOT_TOKEN` or `DISCORD_BOT_TOKEN` causes boot-time configuration failure.
- If room inventory is empty, validate `TELEGRAM_CHAT_ID`, `DISCORD_CHANNEL_ID`, and optional `CONTENTOPS_ROOM_ID`/`CONTENTOPS_ROOM_NAME`.
- If bridging fails one direction, validate bot permissions in external channel and confirm matching binding IDs.

## Related Docs

- Durability decision: `specs/chatops_durability_decision.md`
- Story definition: `specs/stories/03_chatops_console.md` (`ST-CHOPS-005`)
