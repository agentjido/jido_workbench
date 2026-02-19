# Jido Examples Backlog (Top 20 LiveView-Backed)

This backlog is trimmed to the **top 20** examples and every entry includes a required LiveView companion, aligned to the metadata shape used by `priv/examples/counter-agent.md`.

## Selection Rules

- Source: highest-ranked items from the prior curated `keep` set
- Ordering: original global rank, preserving complexity -> ROI -> risk sorting
- Constraint: `live_view_required=true` for all 20 entries

## Counter-Agent Alignment

Each top-20 item includes the same critical wiring fields used by `counter-agent.md`:

- `live_view_module` (using `AgentJidoWeb.Examples.<Name>Live`)
- `live_view_source_file` (included in `proposed_source_files`)
- `example_markdown_path` (`priv/examples/<slug>.md`)
- `proposed_source_files` including agent, actions, and LiveView files

## Validation Snapshot

- Total items: **20**
- LiveView required: **20/20**
- Unique slugs: **20**

Category mix:
- `:core`: **13**
- `:ai`: **6**
- `:production`: **1**

Complexity mix:
- `L1`: **12**
- `L2`: **8**
- `L3`: **0**
- `L4`: **0**
- `L5`: **0**

Bucket mix:
- AI + tool-use workflows: **4**
- Foundations: state/actions/schemas: **9**
- LiveView + product integration: **2**
- Production ops/governance: **1**
- Signals/directives/coordination: **4**

## Top 20 Table

| Top20 Rank | Global Rank | Title | Slug | Category | Complexity | LiveView Module | LiveView Source | Example Markdown |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 1 | Address Normalization Agent | `address-normalization-agent` | `:core` | L1 | `AgentJidoWeb.Examples.AddressNormalizationAgentLive` | `lib/agent_jido_web/examples/address_normalization_agent_live.ex` | `priv/examples/address-normalization-agent.md` |
| 2 | 2 | Budget Guardrail Agent | `budget-guardrail-agent` | `:core` | L1 | `AgentJidoWeb.Examples.BudgetGuardrailAgentLive` | `lib/agent_jido_web/examples/budget_guardrail_agent_live.ex` | `priv/examples/budget-guardrail-agent.md` |
| 3 | 3 | Capacity Quota Tracker Agent | `capacity-quota-tracker-agent` | `:core` | L1 | `AgentJidoWeb.Examples.CapacityQuotaTrackerAgentLive` | `lib/agent_jido_web/examples/capacity_quota_tracker_agent_live.ex` | `priv/examples/capacity-quota-tracker-agent.md` |
| 4 | 4 | Cart Value Calculator Agent | `cart-value-calculator-agent` | `:core` | L1 | `AgentJidoWeb.Examples.CartValueCalculatorAgentLive` | `lib/agent_jido_web/examples/cart_value_calculator_agent_live.ex` | `priv/examples/cart-value-calculator-agent.md` |
| 5 | 5 | Feature Flag Audit Agent | `feature-flag-audit-agent` | `:core` | L1 | `AgentJidoWeb.Examples.FeatureFlagAuditAgentLive` | `lib/agent_jido_web/examples/feature_flag_audit_agent_live.ex` | `priv/examples/feature-flag-audit-agent.md` |
| 6 | 16 | LiveView Checkout Recovery Coach | `liveview-checkout-recovery-coach` | `:ai` | L1 | `AgentJidoWeb.Examples.LiveviewCheckoutRecoveryCoachLive` | `lib/agent_jido_web/examples/liveview_checkout_recovery_coach_live.ex` | `priv/examples/liveview-checkout-recovery-coach.md` |
| 7 | 17 | Meeting Prep Briefing Console | `meeting-prep-briefing-console` | `:ai` | L1 | `AgentJidoWeb.Examples.MeetingPrepBriefingConsoleLive` | `lib/agent_jido_web/examples/meeting_prep_briefing_console_live.ex` | `priv/examples/meeting-prep-briefing-console.md` |
| 8 | 18 | Order Approval to Fulfillment Chain | `order-approval-to-fulfillment-chain` | `:core` | L1 | `AgentJidoWeb.Examples.OrderApprovalToFulfillmentChainLive` | `lib/agent_jido_web/examples/order_approval_to_fulfillment_chain_live.ex` | `priv/examples/order-approval-to-fulfillment-chain.md` |
| 9 | 20 | Ticket Triage Swarm Coordinator | `ticket-triage-swarm-coordinator` | `:core` | L1 | `AgentJidoWeb.Examples.TicketTriageSwarmCoordinatorLive` | `lib/agent_jido_web/examples/ticket_triage_swarm_coordinator_live.ex` | `priv/examples/ticket-triage-swarm-coordinator.md` |
| 10 | 21 | Document-Grounded Policy QnA Agent | `document-grounded-policy-qna-agent` | `:ai` | L1 | `AgentJidoWeb.Examples.DocumentGroundedPolicyQnaAgentLive` | `lib/agent_jido_web/examples/document_grounded_policy_qna_agent_live.ex` | `priv/examples/document-grounded-policy-qna-agent.md` |
| 11 | 22 | PR Review Suggestion Agent | `pr-review-suggestion-agent` | `:ai` | L1 | `AgentJidoWeb.Examples.PrReviewSuggestionAgentLive` | `lib/agent_jido_web/examples/pr_review_suggestion_agent_live.ex` | `priv/examples/pr-review-suggestion-agent.md` |
| 12 | 24 | Telemetry SLO Budget Sentinel | `telemetry-slo-budget-sentinel` | `:production` | L1 | `AgentJidoWeb.Examples.TelemetrySloBudgetSentinelLive` | `lib/agent_jido_web/examples/telemetry_slo_budget_sentinel_live.ex` | `priv/examples/telemetry-slo-budget-sentinel.md` |
| 13 | 26 | CSV Import Validator Agent | `csv-import-validator-agent` | `:core` | L2 | `AgentJidoWeb.Examples.CsvImportValidatorAgentLive` | `lib/agent_jido_web/examples/csv_import_validator_agent_live.ex` | `priv/examples/csv-import-validator-agent.md` |
| 14 | 27 | Catalog Variant Consistency Agent | `catalog-variant-consistency-agent` | `:core` | L2 | `AgentJidoWeb.Examples.CatalogVariantConsistencyAgentLive` | `lib/agent_jido_web/examples/catalog_variant_consistency_agent_live.ex` | `priv/examples/catalog-variant-consistency-agent.md` |
| 15 | 28 | Changelog Entry Linter Agent | `changelog-entry-linter-agent` | `:core` | L2 | `AgentJidoWeb.Examples.ChangelogEntryLinterAgentLive` | `lib/agent_jido_web/examples/changelog_entry_linter_agent_live.ex` | `priv/examples/changelog-entry-linter-agent.md` |
| 16 | 30 | Dependency License Classifier Agent | `dependency-license-classifier-agent` | `:core` | L2 | `AgentJidoWeb.Examples.DependencyLicenseClassifierAgentLive` | `lib/agent_jido_web/examples/dependency_license_classifier_agent_live.ex` | `priv/examples/dependency-license-classifier-agent.md` |
| 17 | 36 | Incident Timeline Narrator Agent | `incident-timeline-narrator-agent` | `:ai` | L2 | `AgentJidoWeb.Examples.IncidentTimelineNarratorAgentLive` | `lib/agent_jido_web/examples/incident_timeline_narrator_agent_live.ex` | `priv/examples/incident-timeline-narrator-agent.md` |
| 18 | 37 | Release Notes Drafting Agent | `release-notes-drafting-agent` | `:ai` | L2 | `AgentJidoWeb.Examples.ReleaseNotesDraftingAgentLive` | `lib/agent_jido_web/examples/release_notes_drafting_agent_live.ex` | `priv/examples/release-notes-drafting-agent.md` |
| 19 | 38 | Async Payment Retry Orchestrator | `async-payment-retry-orchestrator` | `:core` | L2 | `AgentJidoWeb.Examples.AsyncPaymentRetryOrchestratorLive` | `lib/agent_jido_web/examples/async_payment_retry_orchestrator_live.ex` | `priv/examples/async-payment-retry-orchestrator.md` |
| 20 | 41 | Dead Letter Reprocessor Workflow | `dead-letter-reprocessor-workflow` | `:core` | L2 | `AgentJidoWeb.Examples.DeadLetterReprocessorWorkflowLive` | `lib/agent_jido_web/examples/dead_letter_reprocessor_workflow_live.ex` | `priv/examples/dead-letter-reprocessor-workflow.md` |

## Example Frontmatter Stub

Use this skeleton per item when creating the actual `priv/examples/<slug>.md` file:

```elixir
%{
  title: "<Title>",
  description: "<Short description>",
  tags: ["<tag1>", "<tag2>"],
  category: :core | :ai | :production,
  icon: "core|ai|production",
  source_files: [
    "<agent_source_file>",
    "<action_source_file_1>",
    "<action_source_file_2>",
    "<live_view_source_file>"
  ],
  live_view_module: "AgentJidoWeb.Examples.<ExampleName>Live",
  difficulty: :beginner | :intermediate | :advanced,
  sort_order: <integer>
}
```

## Top 20 Detail

### 1. Address Normalization Agent

- `slug`: `address-normalization-agent`
- `category`: `:core`
- `domain_cluster`: core mechanics
- `primary_learning_goal`: Action contracts and validation
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.AddressNormalizationAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/address_normalization_agent_live.ex`
- `example_markdown_path`: `priv/examples/address-normalization-agent.md`
- `agent_module`: `AgentJido.Demos.AddressNormalizationAgent`
- `proposed_source_files`: `lib/agent_jido/demos/address_normalization/address_normalization_agent.ex; lib/agent_jido/demos/address_normalization/actions/execute_action.ex; lib/agent_jido/demos/address_normalization/actions/reset_action.ex; lib/agent_jido_web/examples/address_normalization_agent_live.ex`
- `learning_roi_score`: 5
- `build_risk_score`: 1
- `why_it_matters`: Builds action contract discipline that prevents invalid mutations and improves confidence.

### 2. Budget Guardrail Agent

- `slug`: `budget-guardrail-agent`
- `category`: `:core`
- `domain_cluster`: core mechanics
- `primary_learning_goal`: Action contracts and validation
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.BudgetGuardrailAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/budget_guardrail_agent_live.ex`
- `example_markdown_path`: `priv/examples/budget-guardrail-agent.md`
- `agent_module`: `AgentJido.Demos.BudgetGuardrailAgent`
- `proposed_source_files`: `lib/agent_jido/demos/budget_guardrail/budget_guardrail_agent.ex; lib/agent_jido/demos/budget_guardrail/actions/execute_action.ex; lib/agent_jido/demos/budget_guardrail/actions/reset_action.ex; lib/agent_jido_web/examples/budget_guardrail_agent_live.ex`
- `learning_roi_score`: 5
- `build_risk_score`: 1
- `why_it_matters`: Builds action contract discipline that prevents invalid mutations and improves confidence.

### 3. Capacity Quota Tracker Agent

- `slug`: `capacity-quota-tracker-agent`
- `category`: `:core`
- `domain_cluster`: core mechanics
- `primary_learning_goal`: Action contracts and validation
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.CapacityQuotaTrackerAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/capacity_quota_tracker_agent_live.ex`
- `example_markdown_path`: `priv/examples/capacity-quota-tracker-agent.md`
- `agent_module`: `AgentJido.Demos.CapacityQuotaTrackerAgent`
- `proposed_source_files`: `lib/agent_jido/demos/capacity_quota_tracker/capacity_quota_tracker_agent.ex; lib/agent_jido/demos/capacity_quota_tracker/actions/execute_action.ex; lib/agent_jido/demos/capacity_quota_tracker/actions/reset_action.ex; lib/agent_jido_web/examples/capacity_quota_tracker_agent_live.ex`
- `learning_roi_score`: 5
- `build_risk_score`: 1
- `why_it_matters`: Builds action contract discipline that prevents invalid mutations and improves confidence.

### 4. Cart Value Calculator Agent

- `slug`: `cart-value-calculator-agent`
- `category`: `:core`
- `domain_cluster`: core mechanics
- `primary_learning_goal`: Action contracts and validation
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.CartValueCalculatorAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/cart_value_calculator_agent_live.ex`
- `example_markdown_path`: `priv/examples/cart-value-calculator-agent.md`
- `agent_module`: `AgentJido.Demos.CartValueCalculatorAgent`
- `proposed_source_files`: `lib/agent_jido/demos/cart_value_calculator/cart_value_calculator_agent.ex; lib/agent_jido/demos/cart_value_calculator/actions/execute_action.ex; lib/agent_jido/demos/cart_value_calculator/actions/reset_action.ex; lib/agent_jido_web/examples/cart_value_calculator_agent_live.ex`
- `learning_roi_score`: 5
- `build_risk_score`: 1
- `why_it_matters`: Builds action contract discipline that prevents invalid mutations and improves confidence.

### 5. Feature Flag Audit Agent

- `slug`: `feature-flag-audit-agent`
- `category`: `:core`
- `domain_cluster`: core mechanics
- `primary_learning_goal`: Action contracts and validation
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.FeatureFlagAuditAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/feature_flag_audit_agent_live.ex`
- `example_markdown_path`: `priv/examples/feature-flag-audit-agent.md`
- `agent_module`: `AgentJido.Demos.FeatureFlagAuditAgent`
- `proposed_source_files`: `lib/agent_jido/demos/feature_flag_audit/feature_flag_audit_agent.ex; lib/agent_jido/demos/feature_flag_audit/actions/execute_action.ex; lib/agent_jido/demos/feature_flag_audit/actions/reset_action.ex; lib/agent_jido_web/examples/feature_flag_audit_agent_live.ex`
- `learning_roi_score`: 5
- `build_risk_score`: 1
- `why_it_matters`: Builds action contract discipline that prevents invalid mutations and improves confidence.

### 6. LiveView Checkout Recovery Coach

- `slug`: `liveview-checkout-recovery-coach`
- `category`: `:ai`
- `domain_cluster`: product UX/mixed-stack
- `primary_learning_goal`: LiveView interaction patterns
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.LiveviewCheckoutRecoveryCoachLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/liveview_checkout_recovery_coach_live.ex`
- `example_markdown_path`: `priv/examples/liveview-checkout-recovery-coach.md`
- `agent_module`: `AgentJido.Demos.LiveviewCheckoutRecoveryCoachAgent`
- `proposed_source_files`: `lib/agent_jido/demos/liveview_checkout_recovery_coach/liveview_checkout_recovery_coach_agent.ex; lib/agent_jido/demos/liveview_checkout_recovery_coach/actions/execute_action.ex; lib/agent_jido/demos/liveview_checkout_recovery_coach/actions/reset_action.ex; lib/agent_jido_web/examples/liveview_checkout_recovery_coach_live.ex`
- `learning_roi_score`: 4
- `build_risk_score`: 1
- `why_it_matters`: Bridges UI events to agent commands so product interactions remain deterministic and debuggable.

### 7. Meeting Prep Briefing Console

- `slug`: `meeting-prep-briefing-console`
- `category`: `:ai`
- `domain_cluster`: product UX/mixed-stack
- `primary_learning_goal`: AI/tool-use integration
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.MeetingPrepBriefingConsoleLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/meeting_prep_briefing_console_live.ex`
- `example_markdown_path`: `priv/examples/meeting-prep-briefing-console.md`
- `agent_module`: `AgentJido.Demos.MeetingPrepBriefingConsoleAgent`
- `proposed_source_files`: `lib/agent_jido/demos/meeting_prep_briefing_console/meeting_prep_briefing_console_agent.ex; lib/agent_jido/demos/meeting_prep_briefing_console/actions/execute_action.ex; lib/agent_jido/demos/meeting_prep_briefing_console/actions/reset_action.ex; lib/agent_jido_web/examples/meeting_prep_briefing_console_live.ex`
- `learning_roi_score`: 4
- `build_risk_score`: 1
- `why_it_matters`: Connects LLM/tool loops to deterministic action execution patterns used in production.

### 8. Order Approval to Fulfillment Chain

- `slug`: `order-approval-to-fulfillment-chain`
- `category`: `:core`
- `domain_cluster`: coordination/directives/time
- `primary_learning_goal`: Signals and routing
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.OrderApprovalToFulfillmentChainLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/order_approval_to_fulfillment_chain_live.ex`
- `example_markdown_path`: `priv/examples/order-approval-to-fulfillment-chain.md`
- `agent_module`: `AgentJido.Demos.OrderApprovalToFulfillmentChainAgent`
- `proposed_source_files`: `lib/agent_jido/demos/order_approval_to_fulfillment_chain/order_approval_to_fulfillment_chain_agent.ex; lib/agent_jido/demos/order_approval_to_fulfillment_chain/actions/execute_action.ex; lib/agent_jido/demos/order_approval_to_fulfillment_chain/actions/reset_action.ex; lib/agent_jido_web/examples/order_approval_to_fulfillment_chain_live.ex`
- `learning_roi_score`: 4
- `build_risk_score`: 1
- `why_it_matters`: Shows how explicit signal contracts reduce coupling across workflows and teams.

### 9. Ticket Triage Swarm Coordinator

- `slug`: `ticket-triage-swarm-coordinator`
- `category`: `:core`
- `domain_cluster`: coordination/directives/time
- `primary_learning_goal`: Directives (emit/schedule)
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.TicketTriageSwarmCoordinatorLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/ticket_triage_swarm_coordinator_live.ex`
- `example_markdown_path`: `priv/examples/ticket-triage-swarm-coordinator.md`
- `agent_module`: `AgentJido.Demos.TicketTriageSwarmCoordinatorAgent`
- `proposed_source_files`: `lib/agent_jido/demos/ticket_triage_swarm_coordinator/ticket_triage_swarm_coordinator_agent.ex; lib/agent_jido/demos/ticket_triage_swarm_coordinator/actions/execute_action.ex; lib/agent_jido/demos/ticket_triage_swarm_coordinator/actions/reset_action.ex; lib/agent_jido_web/examples/ticket_triage_swarm_coordinator_live.ex`
- `learning_roi_score`: 4
- `build_risk_score`: 1
- `why_it_matters`: Demonstrates directive-driven side effects so delayed work stays testable and predictable.

### 10. Document-Grounded Policy QnA Agent

- `slug`: `document-grounded-policy-qna-agent`
- `category`: `:ai`
- `domain_cluster`: AI/tool-use
- `primary_learning_goal`: Action contracts and validation
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.DocumentGroundedPolicyQnaAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/document_grounded_policy_qna_agent_live.ex`
- `example_markdown_path`: `priv/examples/document-grounded-policy-qna-agent.md`
- `agent_module`: `AgentJido.Demos.DocumentGroundedPolicyQnaAgent`
- `proposed_source_files`: `lib/agent_jido/demos/document_grounded_policy_qna/document_grounded_policy_qna_agent.ex; lib/agent_jido/demos/document_grounded_policy_qna/actions/execute_action.ex; lib/agent_jido/demos/document_grounded_policy_qna/actions/reset_action.ex; lib/agent_jido_web/examples/document_grounded_policy_qna_agent_live.ex`
- `learning_roi_score`: 4
- `build_risk_score`: 2
- `why_it_matters`: Builds action contract discipline that prevents invalid mutations and improves confidence.

### 11. PR Review Suggestion Agent

- `slug`: `pr-review-suggestion-agent`
- `category`: `:ai`
- `domain_cluster`: AI/tool-use
- `primary_learning_goal`: AI/tool-use integration
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.PrReviewSuggestionAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/pr_review_suggestion_agent_live.ex`
- `example_markdown_path`: `priv/examples/pr-review-suggestion-agent.md`
- `agent_module`: `AgentJido.Demos.PrReviewSuggestionAgent`
- `proposed_source_files`: `lib/agent_jido/demos/pr_review_suggestion/pr_review_suggestion_agent.ex; lib/agent_jido/demos/pr_review_suggestion/actions/execute_action.ex; lib/agent_jido/demos/pr_review_suggestion/actions/reset_action.ex; lib/agent_jido_web/examples/pr_review_suggestion_agent_live.ex`
- `learning_roi_score`: 4
- `build_risk_score`: 2
- `why_it_matters`: Connects LLM/tool loops to deterministic action execution patterns used in production.

### 12. Telemetry SLO Budget Sentinel

- `slug`: `telemetry-slo-budget-sentinel`
- `category`: `:production`
- `domain_cluster`: production ops/governance
- `primary_learning_goal`: Telemetry/observability
- `complexity`: L1 (2-4 hours)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.TelemetrySloBudgetSentinelLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/telemetry_slo_budget_sentinel_live.ex`
- `example_markdown_path`: `priv/examples/telemetry-slo-budget-sentinel.md`
- `agent_module`: `AgentJido.Demos.TelemetrySloBudgetSentinelAgent`
- `proposed_source_files`: `lib/agent_jido/demos/telemetry_slo_budget_sentinel/telemetry_slo_budget_sentinel_agent.ex; lib/agent_jido/demos/telemetry_slo_budget_sentinel/actions/execute_action.ex; lib/agent_jido/demos/telemetry_slo_budget_sentinel/actions/reset_action.ex; lib/agent_jido_web/examples/telemetry_slo_budget_sentinel_live.ex`
- `learning_roi_score`: 4
- `build_risk_score`: 2
- `why_it_matters`: Builds operational literacy around telemetry, latency, and failure signals before launch.

### 13. CSV Import Validator Agent

- `slug`: `csv-import-validator-agent`
- `category`: `:core`
- `domain_cluster`: core mechanics
- `primary_learning_goal`: Action contracts and validation
- `complexity`: L2 (0.5-1 day)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.CsvImportValidatorAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/csv_import_validator_agent_live.ex`
- `example_markdown_path`: `priv/examples/csv-import-validator-agent.md`
- `agent_module`: `AgentJido.Demos.CsvImportValidatorAgent`
- `proposed_source_files`: `lib/agent_jido/demos/csv_import_validator/csv_import_validator_agent.ex; lib/agent_jido/demos/csv_import_validator/actions/execute_action.ex; lib/agent_jido/demos/csv_import_validator/actions/reset_action.ex; lib/agent_jido_web/examples/csv_import_validator_agent_live.ex`
- `learning_roi_score`: 5
- `build_risk_score`: 2
- `why_it_matters`: Builds action contract discipline that prevents invalid mutations and improves confidence.

### 14. Catalog Variant Consistency Agent

- `slug`: `catalog-variant-consistency-agent`
- `category`: `:core`
- `domain_cluster`: core mechanics
- `primary_learning_goal`: Action contracts and validation
- `complexity`: L2 (0.5-1 day)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.CatalogVariantConsistencyAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/catalog_variant_consistency_agent_live.ex`
- `example_markdown_path`: `priv/examples/catalog-variant-consistency-agent.md`
- `agent_module`: `AgentJido.Demos.CatalogVariantConsistencyAgent`
- `proposed_source_files`: `lib/agent_jido/demos/catalog_variant_consistency/catalog_variant_consistency_agent.ex; lib/agent_jido/demos/catalog_variant_consistency/actions/execute_action.ex; lib/agent_jido/demos/catalog_variant_consistency/actions/reset_action.ex; lib/agent_jido_web/examples/catalog_variant_consistency_agent_live.ex`
- `learning_roi_score`: 5
- `build_risk_score`: 2
- `why_it_matters`: Builds action contract discipline that prevents invalid mutations and improves confidence.

### 15. Changelog Entry Linter Agent

- `slug`: `changelog-entry-linter-agent`
- `category`: `:core`
- `domain_cluster`: core mechanics
- `primary_learning_goal`: Action contracts and validation
- `complexity`: L2 (0.5-1 day)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.ChangelogEntryLinterAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/changelog_entry_linter_agent_live.ex`
- `example_markdown_path`: `priv/examples/changelog-entry-linter-agent.md`
- `agent_module`: `AgentJido.Demos.ChangelogEntryLinterAgent`
- `proposed_source_files`: `lib/agent_jido/demos/changelog_entry_linter/changelog_entry_linter_agent.ex; lib/agent_jido/demos/changelog_entry_linter/actions/execute_action.ex; lib/agent_jido/demos/changelog_entry_linter/actions/reset_action.ex; lib/agent_jido_web/examples/changelog_entry_linter_agent_live.ex`
- `learning_roi_score`: 5
- `build_risk_score`: 2
- `why_it_matters`: Builds action contract discipline that prevents invalid mutations and improves confidence.

### 16. Dependency License Classifier Agent

- `slug`: `dependency-license-classifier-agent`
- `category`: `:core`
- `domain_cluster`: core mechanics
- `primary_learning_goal`: Agent state/schema fundamentals
- `complexity`: L2 (0.5-1 day)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.DependencyLicenseClassifierAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/dependency_license_classifier_agent_live.ex`
- `example_markdown_path`: `priv/examples/dependency-license-classifier-agent.md`
- `agent_module`: `AgentJido.Demos.DependencyLicenseClassifierAgent`
- `proposed_source_files`: `lib/agent_jido/demos/dependency_license_classifier/dependency_license_classifier_agent.ex; lib/agent_jido/demos/dependency_license_classifier/actions/execute_action.ex; lib/agent_jido/demos/dependency_license_classifier/actions/reset_action.ex; lib/agent_jido_web/examples/dependency_license_classifier_agent_live.ex`
- `learning_roi_score`: 5
- `build_risk_score`: 2
- `why_it_matters`: Teaches schema-first agent modeling so learners reason about state before side effects.

### 17. Incident Timeline Narrator Agent

- `slug`: `incident-timeline-narrator-agent`
- `category`: `:ai`
- `domain_cluster`: AI/tool-use
- `primary_learning_goal`: Telemetry/observability
- `complexity`: L2 (0.5-1 day)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.IncidentTimelineNarratorAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/incident_timeline_narrator_agent_live.ex`
- `example_markdown_path`: `priv/examples/incident-timeline-narrator-agent.md`
- `agent_module`: `AgentJido.Demos.IncidentTimelineNarratorAgent`
- `proposed_source_files`: `lib/agent_jido/demos/incident_timeline_narrator/incident_timeline_narrator_agent.ex; lib/agent_jido/demos/incident_timeline_narrator/actions/execute_action.ex; lib/agent_jido/demos/incident_timeline_narrator/actions/reset_action.ex; lib/agent_jido_web/examples/incident_timeline_narrator_agent_live.ex`
- `learning_roi_score`: 5
- `build_risk_score`: 3
- `why_it_matters`: Builds operational literacy around telemetry, latency, and failure signals before launch.

### 18. Release Notes Drafting Agent

- `slug`: `release-notes-drafting-agent`
- `category`: `:ai`
- `domain_cluster`: AI/tool-use
- `primary_learning_goal`: Telemetry/observability
- `complexity`: L2 (0.5-1 day)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.ReleaseNotesDraftingAgentLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/release_notes_drafting_agent_live.ex`
- `example_markdown_path`: `priv/examples/release-notes-drafting-agent.md`
- `agent_module`: `AgentJido.Demos.ReleaseNotesDraftingAgent`
- `proposed_source_files`: `lib/agent_jido/demos/release_notes_drafting/release_notes_drafting_agent.ex; lib/agent_jido/demos/release_notes_drafting/actions/execute_action.ex; lib/agent_jido/demos/release_notes_drafting/actions/reset_action.ex; lib/agent_jido_web/examples/release_notes_drafting_agent_live.ex`
- `learning_roi_score`: 5
- `build_risk_score`: 3
- `why_it_matters`: Builds operational literacy around telemetry, latency, and failure signals before launch.

### 19. Async Payment Retry Orchestrator

- `slug`: `async-payment-retry-orchestrator`
- `category`: `:core`
- `domain_cluster`: coordination/directives/time
- `primary_learning_goal`: Signals and routing
- `complexity`: L2 (0.5-1 day)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.AsyncPaymentRetryOrchestratorLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/async_payment_retry_orchestrator_live.ex`
- `example_markdown_path`: `priv/examples/async-payment-retry-orchestrator.md`
- `agent_module`: `AgentJido.Demos.AsyncPaymentRetryOrchestratorAgent`
- `proposed_source_files`: `lib/agent_jido/demos/async_payment_retry_orchestrator/async_payment_retry_orchestrator_agent.ex; lib/agent_jido/demos/async_payment_retry_orchestrator/actions/execute_action.ex; lib/agent_jido/demos/async_payment_retry_orchestrator/actions/reset_action.ex; lib/agent_jido_web/examples/async_payment_retry_orchestrator_live.ex`
- `learning_roi_score`: 4
- `build_risk_score`: 2
- `why_it_matters`: Shows how explicit signal contracts reduce coupling across workflows and teams.

### 20. Dead Letter Reprocessor Workflow

- `slug`: `dead-letter-reprocessor-workflow`
- `category`: `:core`
- `domain_cluster`: coordination/directives/time
- `primary_learning_goal`: Signals and routing
- `complexity`: L2 (0.5-1 day)
- `difficulty`: `:beginner`
- `live_view_module`: `AgentJidoWeb.Examples.DeadLetterReprocessorWorkflowLive`
- `live_view_source_file`: `lib/agent_jido_web/examples/dead_letter_reprocessor_workflow_live.ex`
- `example_markdown_path`: `priv/examples/dead-letter-reprocessor-workflow.md`
- `agent_module`: `AgentJido.Demos.DeadLetterReprocessorWorkflowAgent`
- `proposed_source_files`: `lib/agent_jido/demos/dead_letter_reprocessor_workflow/dead_letter_reprocessor_workflow_agent.ex; lib/agent_jido/demos/dead_letter_reprocessor_workflow/actions/execute_action.ex; lib/agent_jido/demos/dead_letter_reprocessor_workflow/actions/reset_action.ex; lib/agent_jido_web/examples/dead_letter_reprocessor_workflow_live.ex`
- `learning_roi_score`: 4
- `build_risk_score`: 2
- `why_it_matters`: Shows how explicit signal contracts reduce coupling across workflows and teams.

