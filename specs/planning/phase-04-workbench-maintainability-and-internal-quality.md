# Phase 4 - Workbench Maintainability and Internal Quality

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `AgentJidoWeb.ContentAssistantLive`
- `AgentJidoWeb.Live.Components.ContentAssistantModalComponent`
- `AgentJido.ContentGen.Actions.*`
- `AgentJido.ContentGen.Verify`
- `AgentJido.ContentOps.Chat.*`
- `AgentJidoWeb.Examples.SimulatedShowcaseLive`
- `test/agent_jido_web/live/**`
- `mix ex_dna --literal-mode abstract`

## Relevant Assumptions / Defaults
- Phase 4 is maintainability work only and should not change public behavior unless required to preserve correctness.
- The ExDNA report is the authority for clone-priority discussion, but closure requires repo-specific regression evidence as well.
- Shared logic extraction is preferred over introducing new abstractions that obscure behavior or testability.

[ ] 4 Phase 4 - Workbench Maintainability and Internal Quality
  Reduce the highest-value structural duplication in the workbench without changing public behavior.

  [ ] 4.1 Section - Issue #50 ExDNA clone reduction
    Use the ExDNA report as the authority for refactoring priorities and measurable clone-reduction outcomes.

    [ ] 4.1.1 Task - Plan the highest-value clone reduction sequence
      Focus on the duplicated paths that carry the most maintenance and correctness risk.

      [ ] 4.1.1.1 Subtask - Prioritize shared logic extraction for the content assistant, content-generation verification flow, chat plumbing, simulated-showcase scenario tables, and repeated example LiveView setup paths.
      [ ] 4.1.1.2 Subtask - Require a post-refactor ExDNA rerun and captured before or after evidence in the closure criteria.

  [ ] 4.2 Section - Phase 4 Integration Tests
    Validate that refactoring reduces duplication without changing externally visible behavior.

    [ ] 4.2.1 Task - Add Phase 4 regression and measurement coverage
      Ensure functional behavior remains stable and clone-reduction claims are measurable.

      [ ] 4.2.1.1 Subtask - Require regression coverage for every refactored assistant, example, content-generation, or chat path touched by the clone work.
      [ ] 4.2.1.2 Subtask - Require ExDNA rerun evidence as part of phase completion.
