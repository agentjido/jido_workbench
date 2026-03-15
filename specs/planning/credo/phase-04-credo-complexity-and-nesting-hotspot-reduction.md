[Back to index](/Users/Pascal/code/agentjido/jido_run/specs/planning/credo/README.md)

## Relevant Shared APIs / Interfaces

- `mix credo --strict`
- hotspots in `lib/agent_jido/content_ontology/exporter.ex`
- hotspots in `lib/agent_jido/content_gen/**`
- hotspots in `lib/agent_jido_web/live/admin_content_generator_live.ex`
- hotspots in `lib/agent_jido_web/live/chat_ops_live.ex`
- page, ecosystem, OG image, and analytics support modules

## Relevant Assumptions / Defaults

- This is the largest phase because it targets the structural backlog: `44` nested-body findings, `32` cyclomatic-complexity findings, and the single excessive-arity helper.
- The highest-risk files are also product-critical paths, so this work should proceed by hotspot cluster with tests kept close to each batch.
- The goal is not generic “cleanup”; it is to break overgrown functions into defensible helpers with stable behavior.

[ ] 4 Phase 4 - Complexity and Nesting Hotspot Reduction
  Reduce the structural hotspots that keep `credo --strict` noisy even after the high-volume micro-refactors are gone.

  [ ] 4.1 Section - Content Ontology and Content Generation Hotspots
    Break down the densest exporter and generator functions into smaller units with explicit responsibilities.

    [ ] 4.1.1 Task - Decompose `content_ontology/exporter.ex`
      Reduce the current hotspot file first because it carries the highest concentration of nesting and complexity findings.

      [ ] 4.1.1.1 Subtask - Split route normalization, target resolution, safe-local checks, and resource-tag assembly into smaller helpers with tighter contracts.
      [ ] 4.1.1.2 Subtask - Keep exporter behavior snapshot-tested or regression-tested as the helper boundaries move.

    [ ] 4.1.2 Task - Decompose `content_gen/**` hotspots
      Simplify the generator pipeline modules whose orchestration helpers currently exceed the repo’s complexity thresholds.

      [ ] 4.1.2.1 Subtask - Prioritize `contract`, `runic_entry_runner`, `persist_and_finalize`, `audit_and_gate`, and related helper modules.
      [ ] 4.1.2.2 Subtask - Preserve CLI and admin-output behavior while extracting decision trees into named private helpers.

  [ ] 4.2 Section - LiveView and Admin Workflow Hotspots
    Reduce overly deep and overly complex handlers in the workbench’s admin and operational UIs.

    [ ] 4.2.1 Task - Decompose admin content generator and ingestion flows
      Break large event handlers and filter builders into smaller units that preserve the current UX behavior.

      [ ] 4.2.1.1 Subtask - Prioritize `filter_plan_rows`, `filter_runs`, `handle_info`, and command-building helpers in admin content generation.
      [ ] 4.2.1.2 Subtask - Keep LiveView assign semantics stable so no rendering regressions are introduced while extracting helpers.

    [ ] 4.2.2 Task - Decompose assistant, chat-ops, and GitHub LiveView hotspots
      Reduce nesting and complexity in LiveView handlers that currently carry multiple rule families at once.

      [ ] 4.2.2.1 Subtask - Prioritize `chat_ops_live`, `content_ops_github_live`, `content_assistant_live`, and modal component hotspots.
      [ ] 4.2.2.2 Subtask - Back the extractions with focused LiveView tests where state-machine behavior is sensitive to control-flow changes.

  [ ] 4.3 Section - Core Support, Pages, and Reporting Hotspots
    Finish the structural cleanup in pages, OG image generation, analytics export, and Mix task reporting helpers.

    [ ] 4.3.1 Task - Decompose pages, ecosystem, and OG image helpers
      Reduce the nested-body findings in page resolution, ecosystem descriptor generation, and OG rendering support.

      [ ] 4.3.1.1 Subtask - Prioritize `pages.ex`, `livebook_parser.ex`, `jido_ecosystem_package_live.ex`, `og_image.ex`, and `og_image/resolver.ex`.
      [ ] 4.3.1.2 Subtask - Favor extracting intention-revealing helpers over moving logic into generic utility modules.

    [ ] 4.3.2 Task - Reduce excessive arity and report-printer complexity
      Break the remaining oversized reporting helpers into smaller composable functions.

      [ ] 4.3.2.1 Subtask - Start with `Mix.Tasks.Arcana.Health.print_report/16` because it is the only explicit excessive-arity finding.
      [ ] 4.3.2.2 Subtask - Apply the same decomposition standard to other report builders that still exceed the complexity threshold.

  [ ] 4.4 Section - Phase 4 Integration Tests
    Verify that the structural reductions preserve behavior while removing the remaining complexity-heavy Credo findings.

    [ ] 4.4.1 Task - Add Phase 4 verification coverage
      Keep tests close to each hotspot cluster so refactors remain safe and reviewable.

      [ ] 4.4.1.1 Subtask - Run focused subsystem tests after each hotspot batch, especially for exporters, generators, LiveViews, and pages.
      [ ] 4.4.1.2 Subtask - Re-run `mix credo --strict` after each hotspot batch and track the nested-body and complexity counts as the primary exit signal for this phase.
