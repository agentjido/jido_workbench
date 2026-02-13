# Content Governance Strategy

Version: 2.0  
Last updated: 2026-02-12  
Scope: Keep site content accurate as the Jido ecosystem evolves.

## 1) Problem Statement

Site content can drift from source code as packages, modules, signatures, and examples change.  
Governance needs to detect drift early and route fixes consistently.

## 2) Governance Principles

- Source-of-truth first: ecosystem metadata and package repos drive factual claims.
- Validation before promotion: published content must pass machine-checkable gates.
- Signal-driven workflow: drift checks should be composable and observable.
- Safe automation: no destructive actions; issue filing and notifications must deduplicate.
- Proof-backed claims: feature/capability copy must link to runnable examples and references.

## 3) Canonical Sources

- `priv/ecosystem/*.md` via `AgentJido.Ecosystem`
- `priv/content_plan/**/*.md` via `AgentJido.ContentPlan`
- Package repositories declared in ecosystem metadata
- Site routes/pages under `lib/agent_jido_web/`

## 4) Validation Pipeline (High-Level)

1. Load ecosystem registry
- Normalize package IDs, repos, versions, and dependency edges.

2. Resolve source refs
- Determine target tag/branch/SHA using content ref overrides and package version policy.

3. Sync repositories
- Clone/fetch and checkout refs in a deterministic working directory.

4. Build code intelligence index
- Index modules, public functions/arities, deprecations, and source paths.

5. Validate content plan
- Verify module references, file references, cross-links, and publication policy fields.

6. Crawl markdown/livebook content
- Inventory code fences, module mentions, links, and metadata.

7. Detect drift
- Module rename/removal.
- Signature change.
- File path drift.
- Broken links or stale examples.

8. Triage and action
- Deduplicate findings, assign severity, and generate actionable issue drafts.

9. Report and notify
- Publish run summary and route alerts to owners.

## 5) Finding Severity Model

- High: broken published paths, invalid examples, missing core module references.
- Medium: signature mismatch, outdated API usage, unresolved cross-link.
- Low: minor copy inconsistencies, optional metadata gaps.

Each finding should include:

- `kind`
- `expected`
- `observed`
- `evidence`
- `suggested_fix`
- `owner_scope`

## 6) Publish Gates (Recommended)

Required for published content:

- Valid package/repo reference.
- Valid source module or source file mapping.
- Resolved prerequisites/related links.
- Defined purpose and learning outcomes.
- At least one example/training/ops-reference cross-link in strategic pages.

## 7) Operating Cadence

- Hourly incremental checks (changed scope).
- Nightly full sweep (all packages/content).
- On deploy: quick validation for touched pages and routes.

## 8) Ownership Model

- Marketing/content owner: message clarity, narrative consistency.
- Technical docs owner: API and implementation correctness.
- Platform owner: validation jobs and observability health.
- Reviewer gate: no major page publish without proof links.

## 9) Implementation Phases

1. Foundation
- Registry load, repo sync, and content-plan validation baseline.

2. Drift intelligence
- Code index + module/signature/path drift detection.

3. Deep validation
- Code-fence checks, livebook execution checks, link verification.

4. Action loop
- Automated triage, issue filing, and recurring report delivery.

## 10) Day-One Content Checklist

Use this manual checklist for every page before publishing. This is the minimum viable governance gate while the automated pipeline (§4) is under development.

### Before publishing any page

1. **Package references are real.** Every package named on the page exists in `priv/ecosystem/*.md` with `visibility: public`. Do not reference packages that are stubs, private, or not yet released.
2. **Code examples compile.** Every code fence with Elixir code must reference real modules, real functions, and correct arities. Run the example or verify against current source.
3. **Links resolve.** Every internal cross-link points to a route that exists in `lib/agent_jido_web/router.ex` or a published content path. No links to planned-but-unbuilt pages.
4. **Claims are bounded.** No performance, scale, or reliability claims without a concrete reference (benchmark, example, architecture explanation). Apply positioning.md §13 (Claim Discipline).
5. **CTA is present and routed.** Every strategic page includes `Get Building` or section-appropriate CTA that links to a real destination.
6. **Voice check.** Page reads like a staff engineer explaining to a peer, not marketing copy. Apply positioning.md §19 (Voice and Tone Guide).
7. **Cross-link chain exists.** Page links forward to at least one next-step page (training, docs, build, or community) and backward to at least one context page (features, ecosystem).

### Section-specific checks

- **Features pages:** Include at least one code example demonstrating the capability. Link to relevant ecosystem package and training module.
- **Ecosystem pages:** Package metadata matches `priv/ecosystem/*.md` frontmatter. Dependency relationships are accurate.
- **Build pages:** All setup steps are tested against current package versions. Prerequisites are listed.
- **Training pages:** Learning outcomes are stated. Code is runnable in sequence. Links to prerequisite and next training module.
- **Docs pages:** API references match current module signatures. Configuration keys are valid.
- **Community pages:** Claims about adoption or usage are attributed. Case studies have explicit permission.
