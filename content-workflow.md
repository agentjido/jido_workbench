# Content Workflow: Brief -> Docs Page

## Goal
Take one approved content brief, combine it with brand voice and positioning guidance, and produce one high-quality docs page ready for publication.

## Business Outcomes
1. Ship high-quality docs pages faster with a repeatable workflow.
2. Keep messaging consistent with Jido positioning and voice.
3. Reduce factual drift by grounding content in source references from the brief.
4. Improve reader outcomes: faster comprehension, clearer implementation steps, fewer dead ends.
5. Make quality decisions explicit (why a page is ready vs. not ready).

## Workflow Overview
| Step | Business Outcome | LLM Use | Primary Output |
|---|---|---|---|
| 1. Brief Intake | Clear assignment and success criteria | None | `content_request` |
| 2. Context Assembly | Single trusted context package | Optional summarizer | `context_pack` |
| 3. Structure Planning | Strong page structure before drafting | Planner model | `structure_plan` |
| 4. Draft Writing | Complete, useful docs page draft | Writer model | `draft_page` |
| 5. Quality Revision | Better clarity, accuracy, and voice alignment | Critic/Rewriter model | `revised_page` + `quality_report` |
| 6. Final Decision | Binary publish decision with rationale | Optional validator model | `final_page` or `revision_request` |

## Step-by-Step Data Inputs and Outputs

### 1) Brief Intake
Business outcome: The system understands exactly what page to write and what “good” means.

Inputs:
- `brief_file` (title, purpose, audience, learning outcomes, related links, source modules/files, destination route)
- `editorial_intent` (new page vs update)
- `page_type` (concept, guide, reference, tutorial)

Outputs:
- `content_request`
  - `entry_id`
  - `title`
  - `destination_route`
  - `page_type`
  - `audience`
  - `learning_outcomes`
  - `source_references`
  - `success_criteria`

### 2) Context Assembly
Business outcome: All guidance is unified before any generation starts.

Inputs:
- `content_request`
- Brand voice and positioning context
- Documentation style/quality guidance
- Content governance rules
- Relevant source snippets and existing page content (if update mode)

Outputs:
- `context_pack`
  - `brief_summary`
  - `brand_constraints`
  - `voice_rules`
  - `must_include`
  - `must_avoid`
  - `source_evidence_bundle`
  - `link_targets`

### 3) Structure Planning (Pass 1)
Business outcome: The draft follows a useful, complete structure tied to user outcomes.

Inputs:
- `context_pack`
- `content_request`

LLM use:
- Planner model generates structure and section intent, not final prose.

Outputs:
- `structure_plan`
  - `section_order`
  - `section_briefs`
  - `example_strategy` (minimal -> realistic -> production caveats)
  - `citation_plan`
  - `required_links_plan`

Rough planner prompt:
> You are a technical documentation planner. Build the best structure for this page using the brief and brand constraints. Optimize for developer usefulness, scannability, and verifiable claims. Return a section order and section-by-section intent only.

### 4) Draft Writing (Pass 2)
Business outcome: Produce a complete docs page aligned to structure, voice, and evidence.

Inputs:
- `context_pack`
- `structure_plan`
- `content_request`

LLM use:
- Writer model produces full page prose and examples.

Outputs:
- `draft_page`
  - `frontmatter` (title, description, metadata)
  - `body_markdown`
  - `citations`
  - `author_notes`

Rough writer prompt:
> Write the full docs page using this structure plan and context pack. Keep the exact required section headings, include practical examples, and ground all claims in provided source evidence. Write to one developer in a clear staff-engineer voice.

### 5) Quality Revision (Editorial Pass)
Business outcome: Catch weak sections before final decision and improve quality in one pass.

Inputs:
- `draft_page`
- `context_pack`
- `quality_checklist` (accuracy, clarity, completeness, links, examples, voice, actionability)

LLM use:
- Critic/Rewriter model reviews draft and returns targeted improvements.

Outputs:
- `revised_page`
- `quality_report`
  - `strengths`
  - `issues_found`
  - `edits_applied`
  - `remaining_risks`

Rough critic prompt:
> Review this docs draft against the brief, brand voice, and quality checklist. Identify gaps, then rewrite weak sections to improve clarity, specificity, and practical usefulness. Keep claims constrained to cited evidence.

### 6) Final Decision
Business outcome: Explicit “ready / not ready” decision with reason.

Inputs:
- `revised_page`
- `quality_report`
- `success_criteria`

Outputs:
- If ready: `final_page`
- If not ready: `revision_request`
  - `blocking_reasons`
  - `required_changes`

Rough final decision prompt (optional LLM):
> Decide if this page is publish-ready based on success criteria. Return PASS or FAIL. If FAIL, list only blocking changes.

## LLM Role Split (Quality-First)
Use role-specialized models instead of one-model generation. The objective is better structure, better technical correctness, and better final readability.

| Role | Responsibility | Suggested model tier | Primary output |
|---|---|---|---|
| Planner | Page architecture, section flow, learning progression | `claude-opus-4-6` (or strongest frontier reasoning model) | `structure_plan` |
| Primary Writer | Full technical draft from plan + context pack | `gemini-3.1-pro-preview` (or strongest long-context writer) | `draft_page` |
| Technical Critic | Factual/technical challenge pass, claim precision, missing caveats | `gpt-5.2-pro` (or strongest code/analysis model) | `technical_review` |
| Editorial Rewriter | Concision, readability, voice consistency | `claude-sonnet-4-6` (or strongest editorial model) | `revised_page` |
| Livebook Cell Author | Runnable code cells and execution flow | `gpt-5.2-codex` (or strongest code-generation model) | `livebook_cells` |
| Livebook Pedagogy Reviewer | Checkpoint quality and learner flow | `gemini-2.5-pro` (or strong reasoning reviewer) | `livebook_review` |

### Model Policy
1. Prefer cross-provider role split to reduce correlated blind spots.
2. Keep planner and writer separate; do not collapse into one pass for final-quality docs.
3. Run at least one independent critic model before final decision.
4. Treat Livebook cell authoring as a distinct role from prose writing.
5. If a model is unavailable, substitute by capability class (reasoning, writing, coding, editorial) rather than by provider alone.

## Document Length and Complexity Standards
Keep pages scoped to one primary reader job. Split pages when scope expands beyond one clear outcome.

| Page type | Target length | Hard cap | Complexity target |
|---|---|---|---|
| Concept page (`/docs/concepts/*`) | 900-1,300 words | 1,600 words | Mental model + one practical example |
| Guide / how-to (`/docs/guides/*`) | 1,100-1,800 words | 2,200 words | Step-by-step implementation + troubleshooting |
| Reference page (`/docs/reference/*`) | 700-1,200 words | 1,500 words | Highly scannable, contract-focused |

### Complexity Guardrails
1. One primary “job to be done” per page.
2. No section should require prior knowledge not linked in prerequisites.
3. If three or more major concepts are introduced, split into multiple pages.
4. Keep examples progressive: minimal -> realistic -> operational caveat.
5. Prefer tables and short sections over long narrative blocks.

## Livebook Variant Standards
When the page is intended to be runnable as a Livebook (`.livemd`), optimize for guided execution, not long prose.

| Metric | Standard |
|---|---|
| Narrative text | 500-900 words |
| Runnable cells | 8-14 cells |
| Code per cell | 10-30 lines |
| Checkpoint cadence | Every 2-3 cells |
| Total completion time | 20-40 minutes |
| Completion signal | Reader can run from clean session and reach expected outputs |

### Livebook Quality Expectations
1. Each runnable section has an explicit “run this” action.
2. Each checkpoint states expected output or observable state change.
3. Failure hints are included for likely errors.
4. The final section includes next-step links back to docs and training.
5. Livebook content remains consistent with the same brand voice and factual constraints as markdown docs.

## Accept/Reject Rubric (Tightened)
Use a two-layer decision model: hard reject gates first, then weighted quality scoring.

### Layer 1: Hard Reject Gates (all must pass)
1. Required section headings are present exactly as specified in the brief/contract.
2. Required internal links resolve to valid routes.
3. No placeholder content (`TODO`, `TBD`, `coming soon`, lorem ipsum).
4. At least one source file citation is present.
5. Concept/guide pages include module or module/function references where behavior claims are made.
6. Length is within page-type target bounds.
7. Technical critic reports zero `high` severity issues.
8. Output target path matches intended docs page path only.
9. For Livebooks, runnable cells execute successfully in a clean session.

### Layer 2: Weighted Quality Score
| Dimension | Weight | Minimum floor |
|---|---:|---:|
| Technical accuracy | 35 | 80 |
| Completeness vs brief | 20 | 75 |
| Actionability and learner flow | 20 | 75 |
| Structure and scannability | 10 | 75 |
| Voice and positioning alignment | 10 | 75 |
| Concision | 5 | 70 |

Pass criteria:
1. Total weighted score is at least 88.
2. No dimension is below its minimum floor.
3. Medium-severity issue count is 2 or fewer.

### Livebook ExUnit Gate (required for runnable docs)
For pages targeting `.livemd`, acceptance includes the existing Livebook test framework:
1. Generated Livebook test exists for the page under `test/livebooks/docs/`.
2. The tagged ExUnit Livebook test passes via `mix test`.
3. Livebook gate is blocking for final acceptance (no bypass in publish mode).

Recommended execution pattern:
- `INCLUDE_LIVEBOOK_TESTS=1 mix test --include livebook`
- or targeted test file for the specific generated page.

### Decision Contract (for Git-first review)
Each run should emit a compact decision summary so Git diff review is fast and trustworthy.

```json
{
  "status": "PASS|FAIL",
  "target_file": "priv/pages/docs/...",
  "blocking_codes": [],
  "scores": {
    "accuracy": 0,
    "completeness": 0,
    "actionability": 0,
    "structure": 0,
    "voice": 0,
    "concision": 0,
    "total": 0
  },
  "required_fixes": []
}
```

## Minimal Artifact Philosophy
Keep intermediate artifacts lightweight. The only required durable output is:
- `final_page` (the docs page content)

Everything else exists to improve final-page quality and decision clarity.

## Success Definition
A run is successful when:
1. The final page fulfills the brief’s learning outcomes.
2. Voice and positioning align with Jido brand rules.
3. Claims are evidence-backed from provided context.
4. The page is actionable for developers (clear steps, examples, next steps).
5. For Livebooks, runnable cells and checkpoints meet Livebook standards.
6. Final decision is PASS with no blocking issues.

## End-to-End Example (One `/docs` Page)
Scenario: Generate one concepts page for `/docs/concepts/agents`.

### Exact file paths used
Inputs:
- Brief: `priv/content_plan/docs/agents.md`
- Brand context: `JIDO_BRAND_CONTEXT.md`
- Docs writing principles: `specs/docs-manifesto.md`
- Content governance rules: `specs/content-governance.md`
- Existing page baseline (if updating): `priv/pages/docs/concepts/agents.livemd`
- Source evidence files:
  - `/Users/mhostetler/Source/Jido/jido/lib/jido/agent.ex`
  - `/Users/mhostetler/Source/Jido/jido/lib/jido/agent/strategy.ex`
  - `/Users/mhostetler/Source/Jido/jido/lib/jido/agent/strategy/direct.ex`
  - `/Users/mhostetler/Source/Jido/jido/lib/jido/agent/directive.ex`

Final output:
- Generated docs page: `priv/pages/docs/concepts/agents.livemd`

### Step 1: Brief Intake
Input data:
- `priv/content_plan/docs/agents.md`

Output data (`content_request`):
- `entry_id`: `docs/agents`
- `title`: `Agents`
- `destination_route`: `/docs/concepts/agents`
- `page_type`: `guide`
- `audience`: `intermediate`
- `learning_outcomes`: from brief frontmatter
- `source_references`: source modules/files from brief
- `success_criteria`: validation criteria block from brief

### Step 2: Context Assembly
Input data:
- `content_request`
- `JIDO_BRAND_CONTEXT.md`
- `specs/docs-manifesto.md`
- `specs/content-governance.md`
- Source evidence files listed above
- Existing page content from `priv/pages/docs/concepts/agents.livemd`

Output data (`context_pack`):
- `brief_summary`: one-paragraph intent summary
- `brand_constraints`: positioning and non-negotiables
- `voice_rules`: tone, structure, readability rules
- `must_include`: items from brief `prompt_overrides.must_include`
- `must_avoid`: items from brief `prompt_overrides.must_avoid`
- `required_links`: items from brief `prompt_overrides.required_links`
- `source_evidence_bundle`: snippets from the source files

### Step 3: Structure Planning (Planner Pass)
Input data:
- `context_pack`
- `content_request`

Output data (`structure_plan`):
- `section_order`: concrete list of section headings
- `section_briefs`: what each section must teach
- `example_strategy`: minimal -> realistic -> operational caveats
- `citation_plan`: where to cite `Jido.Agent`, strategy, directives
- `required_links_plan`: where each required internal link appears

Rough planner prompt:
> Plan the structure for a `/docs/concepts/agents` page. Use the brief and brand constraints. Return section order and section-by-section intent only. Ensure the structure supports the required links and source-grounded explanations.

### Step 4: Draft Writing (Writer Pass)
Input data:
- `context_pack`
- `structure_plan`
- `content_request`

Output data (`draft_page`):
- `frontmatter`: title/description/category/order
- `body_markdown`: full `.livemd` page body
- `citations`: source files/modules actually used
- `author_notes`: key writing decisions and tradeoffs

Rough writer prompt:
> Write the full `/docs/concepts/agents` page using this structure plan. Keep required section headings, include practical examples, and ground every behavior claim in provided source evidence. Write in a direct staff-engineer voice to one developer.

### Step 5: Quality Revision (Critic/Rewriter Pass)
Input data:
- `draft_page`
- `context_pack`
- `quality_checklist` (accuracy, clarity, examples, links, voice, actionability)

Output data:
- `revised_page`
- `quality_report`:
  - `strengths`
  - `issues_found`
  - `edits_applied`
  - `remaining_risks`

Rough critic prompt:
> Review this `/docs/concepts/agents` draft against the brief and style rules. Fix weak sections, unclear reasoning, missing links, and unsupported claims. Keep edits practical and concise.

### Step 6: Final Decision and Page Output
Input data:
- `revised_page`
- `quality_report`
- brief validation criteria

Output data:
- If pass: write `final_page` to `priv/pages/docs/concepts/agents.livemd`
- If fail: return `revision_request` with blocking reasons only

Rough final decision prompt:
> Is this page publish-ready for `/docs/concepts/agents`? Return PASS or FAIL. If FAIL, list only blocking changes required.
