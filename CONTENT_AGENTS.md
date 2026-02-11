# ContentOps Agent Swarm — Brainstorm Brief

> A Jido-native agent system for managing, validating, and maintaining content on agentjido.com against the living source code of the Jido ecosystem.

## Problem

The agentjido.com site publishes documentation, livebooks, blog posts, and ecosystem package pages that reference source code across 17 repositories. Code evolves — modules rename, signatures change, files move, examples rot. Today there is no automated way to detect when site content drifts from the source of truth, or to file issues when it does.

## Design Principles

- **Jido-native exclusively** — every agent uses `Jido.Agent`, actions use `Jido.Action`, composable workflows use `Jido.Skill`, inter-agent communication uses `Jido.Signal`
- **Ecosystem registry as canonical source** — `priv/ecosystem/*.md` (via `AgentJido.Ecosystem`) defines the 17 packages, their repos, versions, and dependency graph
- **Content plan as validation spec** — `priv/content_plan/**/*.md` (via `AgentJido.ContentPlan`) entries carry `source_modules`, `source_files`, `repos` fields that are machine-checkable
- **Signal-driven pipeline** — agents communicate through typed signals, enabling loose coupling and observable pipelines
- **Idempotent and safe** — no destructive actions; GitHub issue filing deduplicates; crawling is local/ethical only

---

## Signal Contracts

All agents communicate through these canonical signal types:

| Signal Type | Payload | Direction |
|---|---|---|
| `contentops.tick` | `run_id`, `scope`, `since` | Scheduler → Orchestrator |
| `ecosystem.registry.loaded` | packages list, dependency graph | Registry → all |
| `repo.sync.requested` | repo, target_ref, force? | Orchestrator → RepoSync |
| `repo.synced` / `repo.sync.failed` | repo, commit_sha, workdir_path | RepoSync → Indexer, Drift |
| `code.index.requested` / `code.index.updated` | repo, ref, index path | Orchestrator → Indexer → Validators |
| `content_plan.validation.requested` / `content_plan.validated` / `content_plan.invalid` | entry errors | Orchestrator → PlanValidator |
| `content.scan.requested` / `content.scanned` | inventory artifact path | Orchestrator → Crawler → Drift |
| `drift.detected` | finding struct (see below) | Drift agents → Triage |
| `drift.triage.requested` / `drift.triaged` | deduplicated findings | Orchestrator → Triage |
| `github.issue.requested` / `github.issue.created` / `github.issue.failed` | issue draft / url | Triage → IssueFiler |
| `contentops.run.completed` | report location, stats | Reporting → Orchestrator |

### Finding Shape

```elixir
%{
  finding_id: "ulid",
  severity: :low | :medium | :high,
  repo: "jido_ai",
  ref: "v2.0.0-rc.4" | "main",
  source_path: "priv/documentation/...",
  kind: :missing_module | :signature_changed | :example_failed
        | :file_missing | :broken_link | :livebook_failed
        | :deprecated_usage | :renamed_module,
  expected: "...",
  observed: "...",
  evidence: %{snippets: [...], locations: [...]},
  suggested_issue: %{title: "...", body: "...", labels: [...]}
}
```

---

## Agents

### 1. ContentOps.OrchestratorAgent

**Responsibility:** Central coordinator for periodic and on-demand content validation runs.

**Primitives:** `Jido.Agent` + `ContentOps.Skill` router + `Jido.Plugin` (cron)

**Actions:**
- `BuildRunContextAction` — generate run_id, determine scope (all repos vs changed)
- `KickoffPipelineAction` — emit sync/index/scan signals with concurrency limits
- `AggregateResultsAction` — collect findings, emit summary

**Signals:**
- Consumes: `contentops.tick`, `contentops.run.requested`
- Emits: `repo.sync.requested`, `code.index.requested`, `content.scan.requested`, `content_plan.validation.requested`, `drift.triage.requested`

**Scheduling (via Plugin cron):**
- Nightly: `scope: :all` — full ecosystem sweep
- Hourly: `scope: :changed_since_last_run` — incremental
- On deploy: sync + index only

---

### 2. Ecosystem.RegistryAgent

**Responsibility:** Load and normalize the canonical package registry from `AgentJido.Ecosystem`.

**Primitives:** `Jido.Agent` + `Jido.Action`

**Actions:**
- `LoadPackagesAction` — call `AgentJido.Ecosystem.all_packages/0`, normalize records
- `BuildDependencyGraphAction` — call `AgentJido.Ecosystem.dependency_graph/0`
- `ResolveGitHubCoordsAction` — ensure every package has org/repo/url derived

**Signals:**
- Emits: `ecosystem.registry.loaded` (packages + dep graph)

**Notes:** This is the first agent invoked in every run. All downstream agents depend on it.

---

### 3. SourceSync.VersionResolverAgent

**Responsibility:** Determine which git ref (tag, branch, SHA) to sync for each repo based on ecosystem version declarations, doc frontmatter overrides, and fallback policy.

**Primitives:** `Jido.Agent` + `Jido.Action`

**Actions:**
- `ParseEcosystemVersionsAction` — map `Package.version` to tag conventions (`v#{version}`)
- `DetectDocRefOverridesAction` — scan content for explicit `ref:` declarations
- `ResolveTargetRefsAction` — apply policy: doc ref → ecosystem tag → `main`

**Signals:**
- Consumes: `ecosystem.registry.loaded`, `contentops.tick`
- Emits: `repo.sync.requested` (per repo, with `target_ref`)

**Notes:** Prevents false-positive drift by ensuring content is validated against the version it was written for.

---

### 4. SourceSync.RepoSyncAgent

**Responsibility:** Clone/fetch/checkout ecosystem repos into a working directory on the production server.

**Primitives:** `Jido.Agent` + `RepoSyncSkill`

**Actions:**
- `EnsureWorkDirAction` — create base directory structure
- `GitCloneOrFetchAction` — clone if missing, fetch if exists
- `GitCheckoutRefAction` — checkout target branch/tag/SHA
- `WriteSyncManifestAction` — record `%{repo => %{ref, sha, synced_at}}`

**Signals:**
- Consumes: `repo.sync.requested`
- Emits: `repo.synced` (commit_sha, workdir_path) / `repo.sync.failed`

**Notes:** Uses `System.cmd("git", ...)` under the hood. Synced workdirs are the foundation for all code analysis.

---

### 5. CodeIntel.ApiIndexerAgent

**Responsibility:** Build a machine-checkable index of public API facts from synced source: modules, functions, arities, deprecations, file paths.

**Primitives:** `Jido.Agent` + `CodeIndexSkill`

**Actions:**
- `DiscoverModulesAction` — parse `lib/**/*.ex` with `Code.string_to_quoted/2`
- `ExtractPublicApiAction` — functions/macros + arities, typespecs
- `ExtractDeprecationsAction` — scan `@deprecated` annotations
- `WriteIndexArtifactAction` — persist to ETS or term file

**Signals:**
- Consumes: `code.index.requested`, `repo.synced`
- Emits: `code.index.updated` (index path + stats) / `code.index.failed`

**Notes:** This index is the shared truth for all validation and drift detection agents.

---

### 6. ContentPlan.ValidatorAgent

**Responsibility:** Machine-check `priv/content_plan` entries against the code index and ecosystem registry.

**Primitives:** `Jido.Agent` + `ContentPlanValidationSkill`

**Actions:**
- `LoadContentPlanAction` — from `AgentJido.ContentPlan.all_entries/0`
- `ValidateRepoRefsAction` — `entry.repos ⊆ ecosystem package ids`
- `ValidateSourceFilesExistAction` — verify files exist in synced workdir
- `ValidateSourceModulesExistAction` — verify modules exist in API index
- `ValidateCrossRefsAction` — prerequisites/related slugs resolve, no cycles
- `ValidateStatusPolicyAction` — published entries must have purpose + learning_outcomes

**Signals:**
- Consumes: `content_plan.validation.requested`, `code.index.updated`, `repo.synced`
- Emits: `content_plan.validated` / `content_plan.invalid` (per-entry errors)

**Validation Rules:**
| Rule | Check |
|---|---|
| Repo validity | every `entry.repos` is a known ecosystem id |
| Module validity | every `source_modules` exists in code index |
| File validity | every `source_files` exists in synced checkout |
| Cross-ref integrity | prerequisites/related resolve to real slugs |
| Status policy | `:published` requires non-empty purpose + learning_outcomes |
| Coverage signal | repos present but no source_modules/files → "low verifiability" |

---

### 7. ContentCrawler.InventoryAgent

**Responsibility:** Crawl local site content (`priv/documentation`, `priv/blog`) and produce a structured inventory of pages, code fences, module references, file references, and links.

**Primitives:** `Jido.Agent` + `Jido.Action`

**Actions:**
- `ListContentFilesAction` — glob `priv/{documentation,blog}/**/*.{md,livemd}`
- `ParseFrontmatterAction` — extract metadata from each file
- `ExtractCodeFencesAction` — extract ```elixir blocks with context
- `ExtractModuleReferencesAction` — regex for `Jido.*`, `AgentJido.*` patterns
- `ExtractLinksAction` — internal routes, GitHub URLs, hexdocs URLs

**Signals:**
- Consumes: `content.scan.requested`
- Emits: `content.scanned` (inventory artifact path) / `content.scan.failed`

---

### 8. Drift.ModuleReferenceDriftAgent

**Responsibility:** Detect when content references modules that no longer exist (renamed, removed) for the intended repo/ref.

**Primitives:** `Jido.Agent` + `DriftDetectionSkill`

**Actions:**
- `CheckModuleExistenceAction` — compare extracted refs against code index
- `SuggestRenameAction` — string similarity to find likely renames

**Signals:**
- Consumes: `content.scanned`, `code.index.updated`
- Emits: `drift.detected` (kind: `:missing_module` / `:renamed_module`)

---

### 9. Drift.SignatureDriftAgent

**Responsibility:** Detect function/macro signature drift — arity changes, renamed functions, changed option keys, deprecated usage.

**Primitives:** `Jido.Agent`

**Actions:**
- `ParseCodeBlockCallsAction` — AST-parse code blocks, extract remote calls (`Mod.fun/arity`)
- `CompareSignaturesAction` — check against code index API facts
- `FlagDeprecatedAction` — detect calls to `@deprecated` functions

**Signals:**
- Consumes: `content.scanned`, `code.index.updated`
- Emits: `drift.detected` (kind: `:signature_changed` / `:deprecated_usage`)

---

### 10. Drift.FilePathDriftAgent

**Responsibility:** Detect referenced source file paths that have moved or vanished.

**Primitives:** `Jido.Agent`

**Actions:**
- `VerifyFilePathsAction` — check content_plan `source_files` and in-doc file references against synced checkout
- `SearchRelocatedFileAction` — heuristic search for same filename elsewhere in repo tree

**Signals:**
- Consumes: `content_plan.validated`, `repo.synced`
- Emits: `drift.detected` (kind: `:file_missing`)

---

### 11. Validation.CodeFenceCompileAgent

**Responsibility:** Validate that Elixir code fences in docs/blog compile against the synced code version.

**Primitives:** `Jido.Agent`

**Actions:**
- `AssembleSnippetContextAction` — wrap snippet in module if needed, add aliases
- `CompileSnippetAction` — `Code.compile_string/2` in controlled environment
- `ExecuteSnippetAction` (optional) — run with strict timeout

**Signals:**
- Consumes: `content.scanned`, `code.index.updated`
- Emits: `drift.detected` (kind: `:example_failed`, includes compiler errors)

---

### 12. Validation.LivebookRunnerAgent

**Responsibility:** Livebook-specific validation — parse `.livemd`, compile cells in order, optionally run safe cells.

**Primitives:** `Jido.Agent` + `LivebookValidationSkill`

**Actions:**
- `ParseLivebookAction` — parse `.livemd` structure
- `ExtractSetupCellsAction` — deps, aliases, Mix.install blocks
- `CompileCellsAction` — compile cells sequentially
- `CheckSkipMarkersAction` — honor `<!-- validation: skip -->` per cell

**Signals:**
- Consumes: `content.scanned`
- Emits: `drift.detected` (kind: `:livebook_failed`, includes failing cell + error)

**Notes:** High value — livebooks rot fastest. Require setup cells compile; allow skip markers for cells needing secrets/network/GPU.

---

### 13. Validation.LinkCheckerAgent

**Responsibility:** Detect broken links — GitHub URLs to moved files, hexdocs links, raw livebook URLs, internal routes.

**Primitives:** `Jido.Agent` + HTTP actions via `Req`/`Finch`

**Actions:**
- `ExtractLinksAction` — from scanned inventory
- `CheckHttpStatusAction` — rate-limited, cached HEAD requests
- `CheckInternalRoutesAction` — verify against Phoenix route helpers

**Signals:**
- Consumes: `content.scanned`
- Emits: `drift.detected` (kind: `:broken_link`)

---

### 14. Drift.ImpactAnalysisAgent

**Responsibility:** When drift is detected in repo X, estimate blast radius using the ecosystem dependency graph and content_plan linkage.

**Primitives:** `Jido.Agent`

**Actions:**
- `ComputeReverseImpactAction` — join finding repo with `AgentJido.Ecosystem.reverse_deps/1`
- `FindAffectedContentAction` — find content_plan entries referencing impacted repo/module/file
- `EscalateSeverityAction` — increase severity if many entries affected

**Signals:**
- Consumes: `drift.detected`, `ecosystem.registry.loaded`, `content_plan.validated`
- Emits: `drift.impact.assessed` (enriched finding)

---

### 15. Triage.DriftTriageAgent

**Responsibility:** Deduplicate, classify, and route findings into actionable GitHub issues.

**Primitives:** `Jido.Agent` + `TriageSkill`

**Actions:**
- `DeduplicateFindingsAction` — hash by repo/ref/kind/location
- `ClassifySeverityAction` — published content + compile failure → high
- `DecideTargetRepoAction` — API break → ecosystem repo; stale docs → agent_jido repo
- `PrepareIssueDraftAction` — format title/body/labels from finding struct

**Signals:**
- Consumes: `drift.triage.requested`, `drift.detected`, `drift.impact.assessed`
- Emits: `github.issue.requested` / `drift.triaged`

**Notes:** Critical for preventing issue spam. Only files when severity warrants it.

---

### 16. GitHub.IssueFilerAgent

**Responsibility:** Create GitHub issues across the 17 ecosystem repos. Idempotent and rate-limited.

**Primitives:** `Jido.Agent` + actions via `Req` (GitHub REST API)

**Actions:**
- `ValidateIssueAuthAction` — token present, repo in allowlist
- `SearchExistingIssuesAction` — search by fingerprint in body to avoid duplicates
- `CreateIssueAction` — POST to `repos/{org}/{repo}/issues`
- `RecordIssueMappingAction` — persist `finding_id → issue_url`

**Signals:**
- Consumes: `github.issue.requested`
- Emits: `github.issue.created` / `github.issue.failed`

**Target Repos (from Ecosystem):**
`jido`, `jido_action`, `jido_signal`, `jido_ai`, `jido_behaviortree`, `jido_browser`, `jido_claude`, `jido_code`, `jido_flame`, `jido_live_dashboard`, `jido_messaging`, `jido_runic`, `jido_sandbox`, `llm_db`, `req_llm`, `ash_jido`, `agent_jido`

---

### 17. Reporting.ContentOpsReportAgent

**Responsibility:** Produce run summaries — counts by repo/status/severity, links to created issues, actionable next steps.

**Primitives:** `Jido.Agent`

**Actions:**
- `AggregateRunEventsAction` — collect all signals for a `run_id`
- `WriteReportArtifactAction` — markdown/JSON saved to disk
- `EmitTelemetryAction` — optional `:telemetry` events for LiveDashboard

**Signals:**
- Consumes: `repo.synced`, `content_plan.*`, `drift.*`, `github.issue.*`
- Emits: `contentops.run.completed` (report location, stats)

---

### 18. Notification.DispatchAgent (optional)

**Responsibility:** Push run summaries and critical failures to email/Slack/Discord.

**Primitives:** `Jido.Agent` + actions via `Swoosh` or webhook

**Actions:**
- `FormatNotificationAction` — render report into channel-appropriate format
- `SendNotificationAction` — dispatch via configured channel

**Signals:**
- Consumes: `contentops.run.completed`, `repo.sync.failed`, `github.issue.failed`
- Emits: `notification.sent` / `notification.failed`

---

## Pipeline Flow

```
Scheduler (cron plugin)
  │
  ▼ contentops.tick
OrchestratorAgent
  │
  ├──▶ RegistryAgent ──▶ ecosystem.registry.loaded
  │
  ├──▶ VersionResolverAgent ──▶ repo.sync.requested (×17)
  │         │
  │         ▼
  │    RepoSyncAgent ──▶ repo.synced (×17)
  │         │
  │         ▼
  │    ApiIndexerAgent ──▶ code.index.updated (×17)
  │
  ├──▶ ContentPlan.ValidatorAgent ──▶ content_plan.validated
  │
  ├──▶ ContentCrawler.InventoryAgent ──▶ content.scanned
  │         │
  │         ▼
  │    ┌─── Drift Agents (parallel) ───┐
  │    │  ModuleReferenceDrift         │
  │    │  SignatureDrift               │
  │    │  FilePathDrift                │
  │    │  CodeFenceCompile             │
  │    │  LivebookRunner               │
  │    │  LinkChecker                  │
  │    └───────────────────────────────┘
  │         │
  │         ▼ drift.detected (×N)
  │    ImpactAnalysisAgent ──▶ drift.impact.assessed
  │         │
  │         ▼
  │    DriftTriageAgent ──▶ github.issue.requested
  │         │
  │         ▼
  │    IssueFilerAgent ──▶ github.issue.created
  │
  └──▶ ReportingAgent ──▶ contentops.run.completed
            │
            ▼
       NotificationAgent ──▶ notification.sent
```

---

## Implementation Phases

### Phase 1 — Foundation (1-3 hours)
- OrchestratorAgent (skeleton + cron tick)
- RegistryAgent (wraps existing `AgentJido.Ecosystem`)
- RepoSyncAgent (git clone/fetch/checkout)
- Basic signal wiring

### Phase 2 — Intelligence (1-2 days)
- ApiIndexerAgent (module/function extraction)
- ContentCrawler.InventoryAgent (markdown/livebook parsing)
- ContentPlan.ValidatorAgent (machine-check entries)
- FilePathDriftAgent

### Phase 3 — Deep Validation (2+ days)
- ModuleReferenceDriftAgent + SignatureDriftAgent
- CodeFenceCompileAgent
- LivebookRunnerAgent
- LinkCheckerAgent

### Phase 4 — Action & Reporting
- DriftTriageAgent (dedup, severity, routing)
- IssueFilerAgent (GitHub API integration)
- ImpactAnalysisAgent
- ReportingAgent
- NotificationAgent

---

## Future Considerations

- **Automated PRs** — instead of just filing issues, generate doc patches with suggested fixes
- **Cross-version validation** — same doc supporting multiple package versions
- **Persistent event store** — findings history, trend analysis, drift velocity metrics
- **LiveDashboard integration** — real-time pipeline visibility via `jido_live_dashboard`
- **RAG feedback loop** — drift findings improve the RAG index (already using Arcana)
