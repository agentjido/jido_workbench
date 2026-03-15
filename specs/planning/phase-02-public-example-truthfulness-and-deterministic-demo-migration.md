# Phase 2 - Public Example Truthfulness and Deterministic Demo Migration

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `AgentJido.Examples`
- `AgentJido.Examples.Example`
- `AgentJidoWeb.JidoExampleLive`
- `AgentJidoWeb.Examples.SimulatedShowcaseLive`
- `lib/agent_jido/demos/**`
- `lib/agent_jido_web/examples/**`
- `priv/examples/*.md`
- `test/agent_jido_web/live/jido_example_live_test.exs`

## Relevant Assumptions / Defaults
- Public example slugs remain stable unless a section explicitly redefines the slug as an overview or reference surface.
- A public page presented as runnable must point to real deterministic code, not the shared simulator.
- Deterministic local fixtures are preferred over network calls, API keys, browser binaries, or live write operations.
- Issue `#40` is treated as validate-and-close work because the browser docs scout implementation already exists in the repo.
- Issue `#67` keeps its slug but becomes a truthful comparison or reference surface with dedicated source and UI.
- Issue `#68` keeps its slug as an operational overview or index and points to concrete deterministic operational examples rather than acting as one runnable demo.

[ ] 2 Phase 2 - Public Example Truthfulness and Deterministic Demo Migration
  Replace misleading public simulated examples with truthful deterministic surfaces and preserve clear user expectations.

  [ ] 2.1 Section - Issue #58 Tracker for replacing remaining public simulated examples
    Use the tracker issue as the rollup authority for migration scope, closure criteria, and sequencing.

    [ ] 2.1.1 Task - Define migration standards and rollup completion criteria
      Make the tracker the canonical source for what done means across all child example issues.

      [ ] 2.1.1.1 Subtask - Require every public runnable example to stop using `SimulatedShowcaseLive` as its primary implementation surface.
      [ ] 2.1.1.2 Subtask - Require every migrated example to expose truthful `source_files`, deterministic behavior, and regression tests before the tracker can close.

  [ ] 2.2 Section - Issue #40 Browser workflow example
    Treat the browser example as implemented-but-open and plan a closeout audit instead of rebuilding it.

    [ ] 2.2.1 Task - Validate current browser example against the issue acceptance criteria
      Confirm the existing browser docs scout implementation fully satisfies the original scope.

      [ ] 2.2.1.1 Subtask - Audit the current slug, explanation tab, source tab, demo tab, and deterministic browser flow against the issue requirements.
      [ ] 2.2.1.2 Subtask - Capture any remaining docs or regression-test gaps as closeout work only rather than net-new feature work.

  [ ] 2.3 Section - Issue #59 `jido-ai-actions-runtime-demos`
    Replace the simulator page with a deterministic real runtime demo centered on actual runtime calls.

    [ ] 2.3.1 Task - Plan the real runtime demo migration for the existing slug
      Keep the slug and convert the page to real deterministic runtime code with dedicated source and demo surfaces.

      [ ] 2.3.1.1 Subtask - Define dedicated demo modules and a dedicated LiveView that exercise real local runtime flows without network access or API keys.
      [ ] 2.3.1.2 Subtask - Require source-tab truthfulness and deterministic demo tests before closure.

  [ ] 2.4 Section - Issue #60 `jido-ai-task-execution-workflow`
    Replace the simulator page with a deterministic task lifecycle workflow example.

    [ ] 2.4.1 Task - Plan the task workflow migration for the existing slug
      Convert the page into a real local task-state example with lifecycle visibility.

      [ ] 2.4.1.1 Subtask - Define deterministic task seeding, start, completion, and terminal-state flows backed by real local modules.
      [ ] 2.4.1.2 Subtask - Require a dedicated LiveView and lifecycle regression tests.

  [ ] 2.5 Section - Issue #61 `jido-ai-skills-runtime-foundations`
    Replace the simulator page with a deterministic skills runtime example using checked-in skill fixtures.

    [ ] 2.5.1 Task - Plan the real skills-foundation migration for the existing slug
      Build around real manifest loading, registry behavior, and prompt rendering with file-backed skill assets.

      [ ] 2.5.1.1 Subtask - Define checked-in fixture skill directories and `SKILL.md` assets as the deterministic backend for the demo.
      [ ] 2.5.1.2 Subtask - Require source-tab truthfulness, loader coverage, and dedicated LiveView regression tests.

  [ ] 2.6 Section - Issue #62 `jido-ai-skills-multi-agent-orchestration`
    Replace the simulator page with a deterministic orchestration example built on the real skills foundation.

    [ ] 2.6.1 Task - Plan the multi-skill orchestration migration for the existing slug
      Keep the slug and convert it into a deterministic specialist-routing example.

      [ ] 2.6.1.1 Subtask - Define local specialist skills and routing decisions for arithmetic, conversion, and one compound request.
      [ ] 2.6.1.2 Subtask - Require a dedicated LiveView plus routing and output regression tests.

  [ ] 2.7 Section - Issue #63 `runic-ai-research-studio` and `runic-ai-research-studio-step-mode`
    Replace both simulator pages with one shared deterministic Runic backend and two explicit surfaced modes.

    [ ] 2.7.1 Task - Plan the shared Runic studio backend and dual-surface rollout
      Preserve both slugs while reusing one deterministic workflow implementation.

      [ ] 2.7.1.1 Subtask - Define a shared local workflow backend with separate auto or studio and step-mode UI surfaces.
      [ ] 2.7.1.2 Subtask - Require real step pause or resume coverage and truthful source tabs for both slugs.

  [ ] 2.8 Section - Issue #64 `runic-structured-llm-branching` and `runic-adaptive-researcher`
    Replace both simulator pages with deterministic branching and adaptive workflow examples.

    [ ] 2.8.1 Task - Plan the branching and adaptive Runic migrations for the existing slugs
      Keep both slugs and convert each into a real local routing or workflow-selection surface.

      [ ] 2.8.1.1 Subtask - Define deterministic branch-selection or phase-selection backends and dedicated surfaced results for each slug.
      [ ] 2.8.1.2 Subtask - Require branch-path regression coverage and truthful source tabs.

  [ ] 2.9 Section - Issue #65 `runic-delegating-orchestrator`
    Replace the simulator page with a deterministic delegation example.

    [ ] 2.9.1 Task - Plan the real delegation migration for the existing slug
      Convert the page into a local parent or child orchestration example with explicit handoff visibility.

      [ ] 2.9.1.1 Subtask - Define deterministic child-worker outputs and handoff state transitions in real demo modules.
      [ ] 2.9.1.2 Subtask - Require dedicated demo UI and delegation-path regression tests.

  [ ] 2.10 Section - Issue #66 `jido-ai-weather-multi-turn-context`
    Replace the simulator page with a deterministic multi-turn weather assistant example.

    [ ] 2.10.1 Task - Plan the real multi-turn weather migration for the existing slug
      Convert the page into a local context-carryover and retry or backoff example.

      [ ] 2.10.1.1 Subtask - Define at least three deterministic turns with preserved location context and local retry behavior.
      [ ] 2.10.1.2 Subtask - Require dedicated demo UI and multi-turn regression coverage.

  [ ] 2.11 Section - Issue #67 `jido-ai-weather-reasoning-strategy-suite`
    Keep the slug but stop presenting the page as a fake runnable example.

    [ ] 2.11.1 Task - Reframe the page as a truthful comparison or reference surface
      Preserve the comparison value while removing misleading runnable-example semantics.

      [ ] 2.11.1.1 Subtask - Replace the shared simulator dependency with a dedicated comparison harness or UI that explicitly presents strategy comparison rather than copy-pasteable runtime code.
      [ ] 2.11.1.2 Subtask - Update page metadata, source surface, and tests so the product framing matches the actual behavior.

  [ ] 2.12 Section - Issue #68 `jido-ai-operational-agents-pack`
    Keep the slug as an operational overview or index and move runnable proof into concrete deterministic operational examples.

    [ ] 2.12.1 Task - Re-scope the pack page into an honest index surface
      Stop treating one broad simulator page as a runnable example and anchor it to concrete example pages.

      [ ] 2.12.1.1 Subtask - Plan the pack page as an overview that links to deterministic operational examples already present or to be finalized in this repo.
      [ ] 2.12.1.2 Subtask - Remove simulator-backed source or demo expectations from the pack page and require regression coverage for the revised framing.

  [ ] 2.13 Section - Phase 2 Integration Tests
    Validate that every touched public example slug is truthful, deterministic, and no longer backed by the shared simulator unless explicitly non-runnable by design.

    [ ] 2.13.1 Task - Add Phase 2 example-surface regression coverage
      Ensure migration standards are enforced consistently across all example slugs in scope.

      [ ] 2.13.1.1 Subtask - Require a repo-wide check that no targeted public slug resolves to `SimulatedShowcaseLive` as its primary implementation.
      [ ] 2.13.1.2 Subtask - Require explanation, source, and demo or reference-surface regression tests for every touched slug.
