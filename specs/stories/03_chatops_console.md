# Epic 3 - Messaging and Admin ChatOps Console

### ST-CHOPS-001 Add authenticated admin ChatOps LiveView route under `/dashboard/...`
#### Epic
Epic 3 - Messaging and Admin ChatOps Console
#### Dependencies
- ST-ADM-002
#### Scope
- Add admin-only ChatOps page route at `/dashboard/chatops`.
- Place route in authenticated admin routing scope and live session.
- Add initial ChatOps shell LiveView (`AgentJidoWeb.ChatOpsLive` or equivalent) with page structure placeholders for:
  - room list
  - messages
  - action/run timeline
  - guardrails
#### Out of Scope
- Wiring live data from chat services.
#### Acceptance Criteria
- Admin users can access `/dashboard/chatops`.
- Unauthenticated and non-admin users are blocked.
- ChatOps shell loads with expected section scaffolding.
#### Test Cases
- Router/auth matrix tests for `/dashboard/chatops`.
- LiveView render sanity test.

### ST-CHOPS-002 Add room and binding inventory panel wired to messaging services
#### Epic
Epic 3 - Messaging and Admin ChatOps Console
#### Dependencies
- ST-CHOPS-001
#### Scope
- Load room and binding metadata into ChatOps LiveView from `JidoMessaging` / `AgentJido.ContentOps.Messaging`.
- Render inventory with:
  - room id/name
  - bound platform channels (Telegram/Discord identifiers)
  - instance identifiers where available
- Include refresh mechanism suitable for admin monitoring.
#### Out of Scope
- Message timeline rendering.
- Run/action timeline.
#### Acceptance Criteria
- Admin can view current room-to-channel bindings in the web console.
- Missing/empty binding data is handled without crashes.
#### Test Cases
- LiveView tests with mocked/stubbed room and binding data.
- Empty-state rendering test.

### ST-CHOPS-003 Add recent message timeline panel
#### Epic
Epic 3 - Messaging and Admin ChatOps Console
#### Dependencies
- ST-CHOPS-001
#### Scope
- Render recent chat messages in ChatOps UI using existing messaging stores/services.
- Include message metadata in timeline rows:
  - timestamp
  - room id
  - actor/username
  - channel/source
  - text snippet
- Ensure timeline handles high-volume truncation sensibly.
#### Out of Scope
- Action/run timeline.
- Policy guardrail status indicators.
#### Acceptance Criteria
- Admin can inspect recent incoming platform messages from the web console.
- Timeline display is stable with empty and populated datasets.
#### Test Cases
- LiveView tests for empty and populated message timeline.
- Message metadata formatting assertions.

### ST-CHOPS-004 Add action/run timeline and guardrail indicators
#### Epic
Epic 3 - Messaging and Admin ChatOps Console
#### Dependencies
- ST-CHOPS-002
- ST-CHOPS-003
#### Scope
- Add timeline for ContentOps actions/runs using RunStore/notifier/router metadata.
- Display policy guardrails in UI:
  - actor authz status outcome
  - mutation-enabled status indicator
- Make blocked/unauthorized events visibly distinct from successful runs.
#### Out of Scope
- Persistent storage migration.
#### Acceptance Criteria
- Admin can see runs/actions triggered by chat commands.
- Unauthorized/blocked actions are clearly visible and labeled.
- Mutation-enabled state is clearly surfaced in the console.
#### Test Cases
- LiveView tests for successful vs blocked run entries.
- Guardrail indicator rendering tests.

### ST-CHOPS-005 Test determinism hardening plus durability decision note and runbook
#### Epic
Epic 3 - Messaging and Admin ChatOps Console
#### Dependencies
- ST-CHOPS-004
#### Scope
- Stabilize chat test environment boot behavior to avoid env-leak race conditions.
- Document production storage durability decision for messaging history (e.g. ETS vs durable adapter path).
- Add operational runbook for ChatOps:
  - required env vars
  - room/channel ID mapping
  - startup and health validation checks
#### Out of Scope
- Implementing full durable storage migration if deferred by decision.
#### Acceptance Criteria
- Chat integration tests are deterministic under standard test env settings.
- Durability decision is explicit and documented.
- Runbook is complete enough for production operator handoff.
#### Test Cases
- Repeatable targeted chat test runs with consistent outcomes.
- Documentation verification for env var and run validation steps.
