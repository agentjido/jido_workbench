# ContentOps Agent System v2 — Refreshed Brainstorm

> A Jido-native content factory: agents that **create**, **validate**, and **ship** site content via pull requests.

Last updated: 2026-02-12

---

## What changed from v1

The v1 brainstorm (`CONTENT_AGENTS.md`) designed 18 agents — almost all focused on drift detection and validation. The site's actual bottleneck is **zero published reference docs, zero operational demos, zero architecture diagrams** (per `marketing/proof.md`). Validation of content that doesn't exist yet is premature optimization.

v2 flips the ratio: **6 creation agents, 1 consolidated validation agent, 1 PR delivery agent, 1 reporting agent**, all coordinated by a single orchestrator. Content creation is the primary loop; maintenance is the secondary loop.

### Design changes

| Dimension | v1 | v2 |
|---|---|---|
| Agent count | 18 | 10–11 |
| Primary focus | Drift detection | Content creation + maintenance |
| Content authoring | None | 4 specialized writing agents + 1 proof asset agent |
| Drift/validation | 8 separate agents | 1 consolidated agent with subflows |
| Output mechanism | GitHub issues | GitHub PRs only |
| LLM usage | Not specified | Model-per-task assignment (Opus 4.6, Gemini Pro 3, GLM-5) |
| Workflow engine | Implicit | Explicit jido_runic runbooks |
| Work intake | Cron only | Cron schedule + GitHub issue-driven triggers |

---

## Architecture overview

Two intake channels, two loops, one orchestrator:

```
  ┌──────────────┐     ┌──────────────────────────────┐
  │ Cron Plugin  │     │ GitHub.IssueIntakeAgent       │
  │ (scheduled)  │     │ (webhook-driven)              │
  │              │     │                               │
  │ hourly       │     │ issue labeled content:*   ──┐ │
  │ nightly      │     │ issue labeled bug:content ─┐│ │
  │ weekly       │     │ cross-repo release closed ─┤│ │
  │ monthly      │     │ PR review comment request ─┤│ │
  └──────┬───────┘     └──────────────┬─────────────┘│
         │ contentops.tick            │ contentops    │
         │                            │ .work         │
         │                            │ .requested    │
         └──────────┬─────────────────┘               │
                    │                                  │
  ┌─────────────────▼─────────────────────────────────┐
  │                  ContentOps.OrchestratorAgent      │
  │  intake: schedule + github issues                 │
  │  primitives: Jido.Agent + Jido.Skill + jido_runic │
  └──────────┬──────────────────────────────┬─────────┘
             │                              │
      ┌──────▼──────┐               ┌──────▼──────┐
      │ CREATION    │               │ MAINTENANCE │
      │ LOOP        │               │ LOOP        │
      │             │               │             │
      │ Backlog     │               │ Quality     │
      │ Triage      │               │ Drift &     │
      │   ↓         │               │ Validation  │
      │ DocsAuthor  │               │             │
      │ BlogAuthor  │               └──────┬──────┘
      │ Training    │                      │
      │ Builder     │                      │
      │ Ecosystem   │                      │
      │ Curator     │                      │
      │ ProofStudio │                      │
      └──────┬──────┘                      │
             │                             │
             └──────────┬──────────────────┘
                        │
                ┌───────▼────────┐
                │ content.change │
                │ _request       │
                └───────┬────────┘
                        │
                ┌───────▼────────┐        ┌──────────────┐
                │ Policy.Context │───────▶│ Delivery     │
                │ Agent          │ gates  │ GitHubPR     │
                │ (validates     │        │ Agent        │
                │  against specs)│        │              │
                └────────────────┘        │ branch →     │
                                          │ commit →     │
                                          │ PR           │
                                          └──────┬───────┘
                                                 │
                                          ┌──────▼───────┐
                                          │ Reporting    │
                                          │ PulseAgent   │
                                          └──────────────┘
```

**Hard rule:** No agent writes to the repo directly. All changes flow through `content.change_request` signals to the `Delivery.GitHubPRAgent`, which is the only agent that touches the filesystem and GitHub API.

---

## Agent roster

### 1. ContentOps.OrchestratorAgent

**Purpose:** Single coordinator. Runs on a schedule, creates run contexts, delegates work to specialized agents, enforces concurrency limits, and ensures every output ends in a PR.

**Primitives:** `Jido.Agent` + `Jido.Skill` (routing) + `jido_runic` (runbooks) + cron plugin

**Schedule:**

| Cadence | Mode | Work dispatched |
|---|---|---|
| Hourly | `maintenance_lite` | Freshness checks on recently changed content, frontmatter/schema validation |
| Nightly | `maintenance_full` | Repo sync + code index, full drift detection + compile checks + link checks |
| Weekly | `creation_sprint` | Pull from content_plan backlog, generate 1–3 content pieces + 1 proof asset |
| Monthly | `ecosystem_sweep` | Update all ecosystem package pages, generate "what changed" blog post |

**Workflow (jido_runic runbook):**

```elixir
# Simplified runbook structure
1. BuildRunContextAction        → run_id, scope, budget, deadlines
2. LoadPolicyBundleAction       → call Policy.ContextAgent, cache result
3. SelectWorkAction             → call Backlog.TriageAgent (creation modes only)
4. parallel do
     CreationBranch             → delegate to Create.* agents
     MaintenanceBranch          → delegate to Quality.DriftAndValidationAgent
   end
5. CollectChangeRequestsAction  → aggregate all content.change_request signals
6. PRGateAction                 → delegate to Delivery.GitHubPRAgent
7. PublishRunReportAction       → delegate to Reporting.PulseAgent
8. emit contentops.run.completed
```

**Signals consumed:** `contentops.tick`, `contentops.run.requested`, `contentops.work.requested` (from issue intake)
**Signals emitted:** `contentops.run.completed`, all delegation signals

**LLM model:** None (pure coordination logic)

---

### 2. GitHub.IssueIntakeAgent

**Purpose:** Convert GitHub issue and release events into work signals for the orchestrator. This gives humans a natural way to request content work ("write docs for X", "this example is broken") and enables cross-repo release triggers across the 17 ecosystem repos.

**Primitives:** `Jido.Agent` + `Jido.Action` + Phoenix webhook endpoint

**Intake:** Webhook-driven (not scheduled). A Phoenix endpoint at `/webhooks/github` receives GitHub webhook payloads and forwards them to this agent.

**Trigger events:**

| GitHub event | Label / condition | Resulting work |
|---|---|---|
| Issue opened/labeled | `content:docs` | Route to DocsAuthor — write or update a doc page |
| Issue opened/labeled | `content:blog` | Route to BlogAuthor — write a blog post |
| Issue opened/labeled | `content:training` | Route to TrainingBuilder — create/update training module |
| Issue opened/labeled | `content:ecosystem` | Route to EcosystemCurator — update package page |
| Issue opened/labeled | `content:proof` | Route to ProofStudio — create proof asset |
| Issue opened/labeled | `bug:content` | Route to Quality agent — triage and fix broken content |
| Release published | Any of the 17 ecosystem repos | Trigger EcosystemCurator + optional BlogAuthor release post |
| Issue comment | `@jido-bot run` command | Re-trigger work on an existing issue |

**Workflow:**

1. `ReceiveWebhookAction` — parse GitHub webhook payload, verify signature
2. `ClassifyEventAction` — determine event type and extract:
   - For issues: title, body, labels, repo, referenced files/modules
   - For releases: repo, tag, release notes, breaking changes
   - For commands: parse `@jido-bot` command syntax
3. `ExtractWorkContextAction` — use LLM to extract structured work intent from issue body:
   - What content type is requested? (docs, blog, training, proof)
   - What slug/topic does it map to in `priv/content_plan/`?
   - What ecosystem packages are involved?
   - What's the urgency? (label-based or keyword-based)
4. `EmitWorkRequestAction` — emit `contentops.work.requested` signal
5. `AcknowledgeIssueAction` — post a comment on the issue: "🤖 Picked up by ContentOps. Tracking as run `<run_id>`. Will open a PR when ready."

**Cross-repo release handling:**

When a release is published in any of the 17 ecosystem repos:
1. Check if the package's `priv/ecosystem/<id>.md` has a stale `version` field → emit ecosystem update work
2. Check if any `priv/content_plan/` entries reference this repo with `status: :published` → emit drift check work
3. Optionally emit a blog work order for a release announcement (only for major/minor releases, not patches)

**Issue lifecycle integration:**

| Agent event | Issue action |
|---|---|
| Work request acknowledged | Bot comments with run_id |
| PR opened | Bot comments with PR link, references the issue |
| PR merged | Bot closes the issue (if issue was the sole trigger) |
| Work failed | Bot comments with error summary, keeps issue open |

**Signals consumed:** GitHub webhook payloads (via Phoenix endpoint)
**Signals emitted:** `contentops.work.requested`, `github.issue.acknowledged`

**LLM model:** **Gemini Pro 3**
Why: Fast classification of issue intent from unstructured text. Needs to be responsive — webhook handling should be quick.

---

### 3. Policy.ContextAgent

**Purpose:** Load the marketing/ spec files and produce a normalized "policy bundle" that every writing agent must follow. This makes positioning, voice, governance, and proof requirements machine-enforceable at content generation time.

**Primitives:** `Jido.Agent` + `Jido.Action`

**Schedule:** Every orchestrator run (cached daily, invalidated on spec file changes)

**Workflow:**

1. `LoadSpecsAction` — read marketing/ files:
   - `positioning.md` → claims policy, pillar requirements, persona coverage
   - `style-voice.md` → tone constraints, terminology rules, avoided phrases, code conventions
   - `content-governance.md` → publish gates, severity model, validation pipeline
   - `proof.md` → proof requirements per pillar, gap inventory
   - `docs-manifesto.md` → writing principles, README formula, example hierarchy
   - `templates/*.md` → structural requirements per content type
2. `NormalizePolicyAction` — produce structured artifact:
   - `allowed_claims` — what can be said, what requires proof
   - `voice_constraints` — tone, terminology, forbidden phrases
   - `required_sections` — per content type (feature page needs X, blog needs Y)
   - `proof_gates` — which claims require linked proof assets
   - `link_conventions` — internal cross-link rules
   - `frontmatter_requirements` — per content directory
3. `EmitPolicyAction` — emit `policy.bundle.ready`

**Signals emitted:** `policy.bundle.ready`

**LLM model:** **GLM-5**
Why: Structured extraction from long documents. Output must be consistent and schema-like — GLM-5 excels at deterministic structured output.

---

### 4. Backlog.TriageAgent

**Purpose:** Turn `priv/content_plan/` into an executable work queue. Score entries by positioning impact, proof gap coverage, and verifiability. Select batches for the creation agents.

**Primitives:** `Jido.Agent` + `Jido.Action`

**Schedule:** Weekly (creation sprint), optionally daily for quick wins

**Workflow:**

1. `LoadContentPlanAction` — `AgentJido.ContentPlan.all_entries/0`
2. `LoadProofInventoryAction` — parse `marketing/proof.md` gap inventory
3. `ScoreEntriesAction` — rank each entry:
   - Proof gap impact: does this fill a ❌ in proof.md? (+high)
   - Positioning priority: does the content_plan brief have `priority: :critical | :high`? (+)
   - Verifiability: does the brief have `source_modules/source_files/repos`? (+)
   - Dependencies satisfied: are prerequisites already published? (+)
   - Freshness debt: is existing content stale beyond `stale_after_days`? (+)
4. `SelectBatchAction` — choose work for this sprint:
   - 1 reference doc or conceptual doc
   - 1 blog post
   - 1 proof asset (demo, diagram, or example)
   - Optional: 1 training module update
5. `EmitWorkOrdersAction` — emit `content.work.selected` with structured work orders

**Signals consumed:** `contentops.tick` (weekly mode)
**Signals emitted:** `content.work.selected`

**LLM model:** **Gemini Pro 3**
Why: Fast analysis across many briefs. Good at scanning, ranking, and summarizing with low latency.

---

### 5. Create.DocsAuthorAgent

**Purpose:** Write reference docs and conceptual docs in `priv/documentation/`. Fills the biggest content gap: the 7 missing docs pages listed in `content-system.md`.

**Target outputs:** `priv/documentation/docs/*.md`, `priv/documentation/cookbook/*.md`

**Primitives:** `Jido.Agent` + `Jido.Skill` + `jido_runic`

**Schedule:** Weekly (creation sprint), ad-hoc on major releases

**Workflow:**

1. `ReceiveWorkOrderAction` — get docs work order from Backlog.Triage
2. `GatherSourceContextAction` — pull required context:
   - Policy bundle (voice, claims, governance)
   - Content plan brief (`source_modules`, `source_files`, `repos`)
   - Relevant source code from synced repo checkouts
   - Existing related docs (for cross-linking)
   - Template from `marketing/templates/docs-concept.md` or `docs-reference.md`
3. `BuildOutlineAction` — create section outline following template structure
4. `DraftContentAction` — write full doc with:
   - Elixir map frontmatter (matching `AgentJido.Documentation.Document` schema)
   - Verified code examples (or explicitly marked pseudo-code)
   - Cross-links to ecosystem pages, training modules, related docs
   - "What's next" link at bottom (per style guide)
5. `SelfValidateAction` — check against policy bundle:
   - Claims bounded? (no unsupported performance claims)
   - Voice check passes? (no forbidden phrases)
   - Required sections present?
   - CTA present and routed?
6. `EmitChangeRequestAction` — emit `content.change_request`

**Signals consumed:** `content.work.order`
**Signals emitted:** `content.change_request`

**LLM model:** **Opus 4.6**
Why: Best long-form technical writing. Deep reasoning about architecture. Consistent voice when guided by policy bundle. This is the highest-leverage writing work.

---

### 6. Create.BlogAuthorAgent

**Purpose:** Produce blog posts in `priv/blog/` — release announcements, deep dives, ecosystem narratives, "dogfooding with Jido" posts, and positioning-driven content.

**Target outputs:** `priv/blog/YYYY/MM-DD-slug.md`

**Primitives:** `Jido.Agent` + `Jido.Skill` + `jido_runic`

**Schedule:** Biweekly or weekly

**Workflow:**

1. `ReceiveWorkOrderAction` — get blog work order from Backlog.Triage
2. `GatherNarrativeContextAction` — pull:
   - Policy bundle
   - Content plan brief
   - Positioning pillars and persona coverage (from positioning.md)
   - Recent ecosystem changes (new releases, PRs merged) if available
   - Proof assets to reference
3. `BuildNarrativeOutlineAction` — create story arc:
   - Hook (problem/opportunity)
   - Substance (architecture explanation + code example)
   - Proof (link to demo/example/training)
   - CTA (Get Building / Start Training / etc.)
4. `DraftPostAction` — write post with:
   - Elixir map frontmatter (matching `AgentJido.Blog.Post` schema)
   - `post_type`, `audience`, `tags`, `validation` fields
   - Cross-links to docs, training, ecosystem
5. `SelfValidateAction` — policy compliance check
6. `EmitChangeRequestAction` — emit `content.change_request`

**Signals consumed:** `content.work.order`
**Signals emitted:** `content.change_request`

**LLM model:** **Opus 4.6**
Why: Narrative + persuasive but precise writing. Less template-y output than other models. Blog posts need personality within the voice constraints.

---

### 7. Create.TrainingBuilderAgent

**Purpose:** Create and update training modules in `priv/training/` and optional Livebook-based learning materials.

**Target outputs:** `priv/training/*.md`, `priv/documentation/cookbook/*.livemd`

**Primitives:** `Jido.Agent` + `Jido.Skill` + `jido_runic`

**Schedule:** Monthly for large modules, weekly for updates/fixes

**Workflow:**

1. `ReceiveWorkOrderAction` — get training work order
2. `GatherPedagogicalContextAction` — pull:
   - Policy bundle
   - Content plan brief (learning_outcomes, prerequisites, difficulty)
   - Source code for exercises
   - Existing training modules (for prev/next navigation coherence)
   - Template from `marketing/templates/training-module.md`
3. `DesignModuleStructureAction` — define:
   - Prerequisites list
   - Learning outcomes (specific, testable)
   - Section progression (build concepts incrementally per docs-manifesto)
   - Exercise design
4. `DraftModuleAction` — write training module with:
   - Elixir map frontmatter (matching `AgentJido.Training.Module` schema)
   - Track, difficulty, duration_minutes, order
   - All code blocks runnable in sequence
   - Progressive complexity (quickstart → common case → edge case → advanced)
5. `ValidateExamplesAction` — compile-check all code fences
6. `EmitChangeRequestAction` — emit `content.change_request`

**Signals consumed:** `content.work.order`
**Signals emitted:** `content.change_request`, optionally `proof.asset.requested` (to ProofStudio)

**LLM model:** **Opus 4.6** (pedagogy + narrative), with **Gemini Pro 3** as secondary for code understanding/iteration
Why: Training modules require the deepest pedagogical reasoning — building concepts incrementally while keeping code correct. Opus handles this best.

---

### 8. Create.EcosystemCuratorAgent

**Purpose:** Maintain the 19 ecosystem package pages in `priv/ecosystem/`. Keep metadata current, enrich landing content, verify links, and detect when packages need page updates after releases.

**Target outputs:** `priv/ecosystem/*.md`

**Primitives:** `Jido.Agent` + `Jido.Action`

**Schedule:** Monthly sweep; triggered on release detection

**Workflow:**

1. `LoadRegistryAction` — `AgentJido.Ecosystem.all_packages/0`
2. `AuditPackagePagesAction` — for each of 19 packages:
   - Does the page exist and meet template requirements?
   - Is the version field current?
   - Are `hex_url`, `hexdocs_url`, `github_url` links valid?
   - Is `landing_summary` present and useful?
   - Are `landing_cliff_notes` present (recommended max: 6)?
   - Are `landing_major_components` populated?
   - Is dependency graph (`ecosystem_deps`) accurate?
3. `EnrichPagesAction` — for packages with thin pages:
   - Generate `landing_summary` from README/source analysis
   - Generate `landing_cliff_notes` from key features
   - Suggest `landing_major_components` from module analysis
4. `ProposeUpdatesAction` — emit change requests for pages needing updates
5. Optionally: generate "ecosystem update" blog outline for BlogAuthor

**Signals consumed:** `content.work.order`, `ecosystem.release.detected`
**Signals emitted:** `content.change_request`

**LLM model:** **Gemini Pro 3**
Why: Repetitive analysis across many packages. Fast, good at summarizing codebase metadata. Doesn't need deep narrative reasoning.

---

### 9. Create.ProofStudioAgent

**Purpose:** Generate the **proof assets** that are missing across all four positioning pillars. This is the highest-leverage agent — every ❌ in `marketing/proof.md` is a positioning claim without evidence.

**Target outputs:** `priv/examples/*.md`, diagrams in `priv/documentation/`, code snippets, reference implementations

**Priority proof gaps (from proof.md):**
1. Failure drill demo (Pillar 1 — reliability)
2. Signal routing multi-agent demo (Pillar 2 — coordination)
3. Dashboard instrumentation walkthrough (Pillar 3 — operations)
4. Package matrix (Pillar 4 — composability)
5. Minimal-stack quickstart (Pillar 4 — incremental adoption)
6. Why BEAM comparison (cross-cutting)
7. End-to-end tool-calling example (Pillar 2)

**Primitives:** `Jido.Agent` + `Jido.Skill` + `jido_runic`

**Schedule:** Weekly until proof gaps are closed, then monthly

**Workflow:**

1. `ReceiveProofWorkOrderAction` — get proof work order (or detect gaps from proof.md)
2. `ClassifyArtifactTypeAction` — determine what to build:
   - **Operational demo:** runnable example + walkthrough page
   - **Architecture diagram:** Mermaid diagram embedded in docs
   - **Code snippet:** copy-pasteable, compilable snippet
   - **Reference example:** multi-agent workflow built with Jido
3. `GatherSourceMaterialAction` — pull:
   - Relevant source code from ecosystem repos
   - Existing examples for style reference
   - Policy bundle for claims governance
4. `BuildArtifactAction` — create the proof asset:
   - For examples: Elixir map frontmatter + source_files + live_view_module
   - For diagrams: Mermaid code blocks in markdown
   - For snippets: verified compilable code
5. `ValidateArtifactAction` — compile/run checks where safe
6. `EmitChangeRequestAction` — emit `content.change_request` + `proof.asset.created`

**Signals consumed:** `content.work.order`, `proof.asset.requested`
**Signals emitted:** `content.change_request`, `proof.asset.created`

**LLM model:** **Opus 4.6**
Why: Highest reasoning load in the system. Must align code behavior with system design with narrative. Proof assets are the hardest and highest-leverage work.

---

### 10. Quality.DriftAndValidationAgent

**Purpose:** Consolidated replacement for v1's 8 drift/validation micro-agents. Runs multiple validation subflows and emits findings or auto-fix suggestions.

**Primitives:** `Jido.Agent` + `Jido.Skill` (one skill per validation type) + `jido_runic`

**Schedule:** Hourly (lite) + Nightly (full)

**Validation subflows (implemented as Jido Skills):**

| Subflow | What it checks | Hourly | Nightly |
|---|---|---|---|
| `SchemaValidation` | Frontmatter matches Zoi schema for each content type | ✅ | ✅ |
| `ContentPlanIntegrity` | `source_modules`, `source_files`, `repos` exist; cross-refs resolve | | ✅ |
| `ModuleReferenceDrift` | Content references modules that still exist in code index | | ✅ |
| `SignatureDrift` | Function calls in code fences match current signatures/arities | | ✅ |
| `FilePathDrift` | Referenced source files exist in synced checkouts | | ✅ |
| `CodeFenceCompile` | Elixir code fences compile (sandboxed, with timeout) | | ✅ |
| `LivebookValidation` | .livemd files parse and setup cells compile | | ✅ |
| `LinkCheck` | Internal routes resolve; external URLs return 2xx/3xx (rate-limited, cached) | ✅ | ✅ |
| `FreshnessCheck` | Published content not past `stale_after_days` threshold | ✅ | ✅ |

**Workflow (nightly full):**

1. `SyncReposAction` — clone/fetch/checkout all ecosystem repos to working directory
2. `BuildCodeIndexAction` — parse `lib/**/*.ex`, extract modules/functions/arities/deprecations
3. `CrawlContentInventoryAction` — glob all published content, extract code fences, module refs, links
4. `RunValidationsAction` — execute all subflows in parallel where possible
5. `ClassifyFindingsAction` — for each finding:
   - **Auto-fixable** (simple link update, small signature change) → emit `content.fix.suggested`
   - **Needs human review** (missing module, broken example, structural issue) → emit `quality.finding.detected`
6. `EmitSummaryAction` — aggregate stats for reporting

**Finding shape:**

```elixir
%{
  finding_id: ulid(),
  severity: :low | :medium | :high,
  kind: :schema_invalid | :missing_module | :signature_changed
        | :example_failed | :file_missing | :broken_link
        | :livebook_failed | :deprecated_usage | :renamed_module
        | :stale_content | :cross_ref_broken,
  path: "priv/documentation/docs/getting-started.livemd",
  repo: "jido_ai" | nil,
  expected: "Jido.AI.ChatAction.run/2",
  observed: "Module not found in code index",
  evidence: %{snippets: [...], locations: [...]},
  auto_fixable: boolean(),
  suggested_fix: "..." | nil
}
```

**Signals consumed:** `contentops.tick`, `repo.synced`, `code.index.updated`
**Signals emitted:** `quality.finding.detected`, `content.fix.suggested`, `quality.sweep.completed`

**LLM model:** **Gemini Pro 3**
Why: Fast analysis across large codebases and content inventories. Keep this agent deterministic where possible — use LLM mainly for classification of ambiguous findings and generating human-readable fix suggestions.

---

### 11. Delivery.GitHubPRAgent

**Purpose:** The only agent allowed to write to the repo and interact with the GitHub API. Receives change requests, creates branches, commits, opens PRs, and deduplicates.

**Primitives:** `Jido.Agent` + `Jido.Action` + `Req` (GitHub REST API)

**Schedule:** On-demand (triggered by change requests)

**Workflow:**

1. `ReceiveChangeRequestsAction` — collect all `content.change_request` signals for this run
2. `GroupBySlugAction` — batch related changes into logical PRs
3. `CreateBranchAction` — `bot/contentops/<run_id>/<slug>`
4. `ApplyChangesAction` — write files to working tree
5. `RunLocalChecksAction` — fast validation:
   - `mix format --check-formatted` on changed .ex files
   - Frontmatter schema validation on changed .md files
   - Compile check on changed code examples (where safe)
6. `CommitAction` — conventional commit prefix:
   - `docs:` / `blog:` / `training:` / `ecosystem:` / `proof:` / `chore:`
7. `OpenPRAction` — create PR via GitHub API:
   - **Draft** for creation work (needs human review)
   - **Ready for review** for maintenance fixes (auto-fixable drift)
   - PR body includes:
     - Summary of changes
     - Which `content_plan` entry it fulfills (if any)
     - Proof references used (or explicit "NO PROOF — claims bounded to...")
     - Validation output snippet
   - Labels: `content:docs`, `content:blog`, `content:training`, `content:ecosystem`, `proof`, `maintenance`, `bot`
   - Request CODEOWNERS as reviewers
8. `DeduplicateAction` — if open bot PR exists for same slug, update it instead of creating new

**Guardrails:**
- PR size limit: ≤ 8 files / ≤ 800 lines of diff. Split if larger.
- Rate limit: respect GitHub API limits, batch where possible
- Never force-push or merge — humans merge

**Signals consumed:** `content.change_request`, `content.fix.suggested`
**Signals emitted:** `github.pr.opened`, `github.pr.updated`, `github.pr.failed`

**LLM model:** **GLM-5**
Why: Structured patch planning + deterministic PR metadata generation. PR assembly should be consistent and formulaic, not creative.

---

### 12. Reporting.PulseAgent

**Purpose:** Produce run summaries and weekly content operations pulse reports.

**Primitives:** `Jido.Agent` + `Jido.Action`

**Schedule:** After every orchestrator run; weekly rollup

**Workflow:**

1. `CollectRunArtifactsAction` — gather all signals from this run_id
2. `ComputeMetricsAction` — calculate:
   - PRs opened / updated / merged (query GitHub API)
   - Proof assets shipped (from `proof.asset.created` signals)
   - Drift findings by severity and kind
   - Content plan backlog health (by status distribution)
   - Freshness debt (stale content count)
3. `GenerateReportAction` — write markdown report:
   - Per-run summary (what happened this run)
   - Weekly rollup (trends, velocity, gap closure)
   - Backlog burndown by positioning pillar
4. `EmitPulseAction` — emit `contentops.pulse.ready`

**Signals consumed:** `contentops.run.completed`, `github.pr.*`, `quality.*`, `proof.asset.created`
**Signals emitted:** `contentops.pulse.ready`

**LLM model:** **GLM-5**
Why: Structured summarization + tables + consistent reporting format. Reports should be formulaic and data-driven.

---

## Signal contracts

### Run lifecycle

```elixir
# Orchestrator triggers (scheduled)
%{type: "contentops.tick", run_id: ulid(), mode: :hourly | :nightly | :weekly | :monthly, since: datetime() | nil}
%{type: "contentops.run.completed", run_id: ulid(), stats: %{prs_opened: n, findings: n, proofs_shipped: n}, report_path: "..."}

# Policy
%{type: "policy.bundle.ready", run_id: ulid(), bundle: %{allowed_claims: [...], voice_constraints: [...], ...}}
```

### Issue intake (webhook-driven)

```elixir
# Issue intake → orchestrator
%{
  type: "contentops.work.requested",
  source: :github_issue | :github_release | :github_command,
  github_issue: %{number: 42, url: "...", title: "...", body: "...", labels: ["content:docs"], repo: "agent_jido"} | nil,
  github_release: %{repo: "jido_ai", tag: "v2.1.0", release_notes: "...", prerelease: false} | nil,
  extracted_intent: %{
    content_kind: :docs | :blog | :training | :ecosystem | :proof | :fix,
    target_slug: "docs/core-concepts" | nil,
    ecosystem_packages: ["jido_ai"] | [],
    urgency: :normal | :high
  }
}

# Issue lifecycle feedback
%{type: "github.issue.acknowledged", issue_number: 42, issue_url: "...", run_id: ulid(), comment_id: 123}
%{type: "github.issue.linked_pr", issue_number: 42, pr_number: 87, pr_url: "..."}
%{type: "github.issue.resolved", issue_number: 42, resolution: :pr_merged | :work_failed, detail: "..."}
```

### Work selection

```elixir
# Backlog triage output
%{type: "content.work.selected", run_id: ulid(), work_orders: [
  %{id: ulid(), kind: :docs | :blog | :training | :ecosystem | :proof, slug: "...", plan_entry_path: "...", priority_score: float()}
]}

# Individual work order dispatched to a creation agent
%{type: "content.work.order", run_id: ulid(), order: %{id: ulid(), kind: atom(), slug: "...", plan_entry_path: "...", policy_bundle_ref: "..."}}
```

### Content changes (PR-only pipeline)

```elixir
# Any creation or fix agent emits this — never writes directly
%{
  type: "content.change_request",
  run_id: ulid(),
  authoring_agent: "Create.DocsAuthorAgent",
  changes: [
    %{op: :create | :update, path: "priv/documentation/docs/core-concepts.md", content: "...full file...", rationale: "Fills content plan brief docs/core-concepts-hub"}
  ],
  validations_required: [:schema, :compile_snippets, :links],
  related_plan_slug: "docs/core-concepts-hub" | nil
}

# PR delivery
%{type: "github.pr.opened", run_id: ulid(), pr_url: "...", pr_number: 123, branch: "bot/contentops/..."}
%{type: "github.pr.updated", run_id: ulid(), pr_url: "...", pr_number: 123}
%{type: "github.pr.failed", run_id: ulid(), error: "...", context: %{}}
```

### Quality and drift

```elixir
%{type: "quality.finding.detected", run_id: ulid(), finding: %{finding_id: ulid(), severity: atom(), kind: atom(), path: "...", evidence: %{}, auto_fixable: boolean()}}

%{type: "content.fix.suggested", run_id: ulid(), changes: [...same shape as content.change_request...]}

%{type: "quality.sweep.completed", run_id: ulid(), stats: %{total: n, high: n, medium: n, low: n, auto_fixed: n}}
```

### Proof assets

```elixir
%{type: "proof.asset.requested", run_id: ulid(), pillar: 1..4, kind: :demo | :diagram | :snippet | :example, target_path: "..."}
%{type: "proof.asset.created", run_id: ulid(), pillar: 1..4, kind: atom(), path: "...", proof_md_entry: "..."}
```

---

## Model assignment summary

| Agent | Primary model | Why |
|---|---|---|
| OrchestratorAgent | None | Pure coordination, no LLM needed |
| GitHub.IssueIntakeAgent | **Gemini Pro 3** | Fast classification of issue intent from unstructured text |
| Policy.ContextAgent | **GLM-5** | Structured extraction from spec documents |
| Backlog.TriageAgent | **Gemini Pro 3** | Fast scanning and ranking across many briefs |
| Create.DocsAuthorAgent | **Opus 4.6** | Deep technical writing + architecture reasoning |
| Create.BlogAuthorAgent | **Opus 4.6** | Narrative writing with personality within voice constraints |
| Create.TrainingBuilderAgent | **Opus 4.6** + Gemini Pro 3 | Pedagogical reasoning (Opus) + code iteration (Gemini) |
| Create.EcosystemCuratorAgent | **Gemini Pro 3** | Repetitive analysis across 19 packages |
| Create.ProofStudioAgent | **Opus 4.6** | Highest reasoning load — code + design + narrative alignment |
| Quality.DriftAndValidationAgent | **Gemini Pro 3** | Fast broad analysis, mostly deterministic checks |
| Delivery.GitHubPRAgent | **GLM-5** | Structured PR metadata + deterministic formatting |
| Reporting.PulseAgent | **GLM-5** | Structured reporting + consistent tables |

**Model philosophy:**
- **Opus 4.6** → anything that must be excellent writing + deep reasoning + coherent long-form
- **Gemini Pro 3** → fast broad analysis across code/content, summarization, triage
- **GLM-5** → structured extraction, deterministic formatting, metadata, reporting

---

## Guardrails

1. **Schema gate first.** Every change request must pass frontmatter/Zoi validation before becoming a PR.
2. **Proof governance enforcement.** Claims requiring proof must either link to a shipped proof asset or be rewritten to remove unsupported claims.
3. **PR size limits.** Cap bot PRs at ≤ 8 files / ≤ 800 lines of diff. Split larger work across multiple PRs.
4. **Sandboxed code execution.** Compile snippets with timeouts. Default to compile-only unless explicitly marked safe to run.
5. **Rate-limited external calls.** Cache link check results and GitHub API responses per run. Don't flood hexdocs/GitHub.
6. **Draft PRs for creation; ready PRs for maintenance.** Humans always review new content. Small auto-fixes can go ready-for-review.
7. **No destructive actions.** Agents never delete content, force-push, or merge PRs.

---

## Implementation phases

### Phase 1 — Foundation (1–2 days)
- OrchestratorAgent (skeleton + cron tick + run context)
- Policy.ContextAgent (load specs, produce bundle)
- Delivery.GitHubPRAgent (branch + commit + PR workflow)
- Basic signal wiring between the three

**Milestone:** Orchestrator can create an empty PR on a schedule.

### Phase 2 — First content (3–5 days)
- Backlog.TriageAgent (score and select from content_plan)
- Create.DocsAuthorAgent (write one real doc page end-to-end)
- Create.ProofStudioAgent (generate one proof asset)

**Milestone:** Weekly sprint produces a draft PR with a real docs page + proof asset.

### Phase 3 — Full creation loop (1–2 weeks)
- Create.BlogAuthorAgent
- Create.TrainingBuilderAgent
- Create.EcosystemCuratorAgent

**Milestone:** Weekly sprint produces docs + blog + training + ecosystem updates.

### Phase 4 — Maintenance + issue intake (1 week)
- Quality.DriftAndValidationAgent (all subflows)
- Reporting.PulseAgent
- GitHub.IssueIntakeAgent (webhook endpoint + event classification + issue lifecycle)
- Connect auto-fix suggestions to PR pipeline

**Milestone:** Nightly sweeps detect drift and file fix PRs. GitHub issues with `content:*` labels trigger agent work. Weekly pulse report generated.

---

## Dogfooding value

This system is itself a multi-agent Jido application — it demonstrates:
- Structured workflows via `jido_runic`
- Signal-driven coordination between specialized agents
- Fault isolation (one agent failing doesn't crash the pipeline)
- Practical LLM integration via `jido_ai` + `req_llm`
- Production operation patterns (scheduling, reporting, observability)

Every positioning pillar gets proven by the system that maintains the site:
- **Pillar 1 (Reliability):** Agent failures are supervised and contained
- **Pillar 2 (Coordination):** Agents communicate through typed signals
- **Pillar 3 (Operations):** Run reports provide observability
- **Pillar 4 (Composability):** Each agent uses only the packages it needs
