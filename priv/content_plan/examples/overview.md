%{
  title: "Examples Inventory Stub",
  order: 1,
  purpose: "Map the current `/examples` catalog into the content plan before adding per-example briefs",
  audience: :beginner,
  content_type: :reference,
  learning_outcomes: [
    "See which example slugs currently exist in priv/examples",
    "Use one canonical inventory as the source for future per-example briefs"
  ],
  repos: ["agent_jido"],
  source_modules: ["AgentJido.Examples", "AgentJidoWeb.JidoExamplesLive"],
  source_files: [
    "priv/examples/address-normalization-agent.md",
    "priv/examples/async-payment-retry-orchestrator.md",
    "priv/examples/budget-guardrail-agent.md",
    "priv/examples/capacity-quota-tracker-agent.md",
    "priv/examples/cart-value-calculator-agent.md",
    "priv/examples/catalog-variant-consistency-agent.md",
    "priv/examples/changelog-entry-linter-agent.md",
    "priv/examples/counter-agent.md",
    "priv/examples/csv-import-validator-agent.md",
    "priv/examples/dead-letter-reprocessor-workflow.md",
    "priv/examples/demand-tracker-agent.md",
    "priv/examples/dependency-license-classifier-agent.md",
    "priv/examples/document-grounded-policy-qna-agent.md",
    "priv/examples/feature-flag-audit-agent.md",
    "priv/examples/incident-timeline-narrator-agent.md",
    "priv/examples/liveview-checkout-recovery-coach.md",
    "priv/examples/meeting-prep-briefing-console.md",
    "priv/examples/order-approval-to-fulfillment-chain.md",
    "priv/examples/pr-review-suggestion-agent.md",
    "priv/examples/release-notes-drafting-agent.md",
    "priv/examples/telemetry-slo-budget-sentinel.md",
    "priv/examples/ticket-triage-swarm-coordinator.md"
  ],
  status: :outline,
  priority: :high,
  prerequisites: ["build/quickstarts-by-persona"],
  related: ["build/counter-agent", "features/overview", "docs/getting-started"],
  ecosystem_packages: ["agent_jido", "jido", "jido_action", "jido_signal", "jido_ai", "jido_browser"],
  destination_route: "/examples",
  destination_collection: :pages,
  tags: [:examples, :inventory, :stub]
}
---
## Content Brief

This is a planning stub aligned to the example files that already exist in `priv/examples`.

### Current Inventory (matches `priv/examples`)

- address-normalization-agent
- async-payment-retry-orchestrator
- budget-guardrail-agent
- capacity-quota-tracker-agent
- cart-value-calculator-agent
- catalog-variant-consistency-agent
- changelog-entry-linter-agent
- counter-agent
- csv-import-validator-agent
- dead-letter-reprocessor-workflow
- demand-tracker-agent
- dependency-license-classifier-agent
- document-grounded-policy-qna-agent
- feature-flag-audit-agent
- incident-timeline-narrator-agent
- liveview-checkout-recovery-coach
- meeting-prep-briefing-console
- order-approval-to-fulfillment-chain
- pr-review-suggestion-agent
- release-notes-drafting-agent
- telemetry-slo-budget-sentinel
- ticket-triage-swarm-coordinator

### Not Included Yet

- Per-example content-plan briefs
- Coverage tiering or wave planning for each example
- Example-specific governance and validation gates
