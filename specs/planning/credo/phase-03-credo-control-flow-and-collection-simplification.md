[Back to index](/Users/Pascal/code/agentjido/jido_run/specs/planning/credo/README.md)

## Relevant Shared APIs / Interfaces

- `mix credo --strict`
- collection-heavy helpers in `content_gen`, `content_ontology`, `pages`, and `content_ops`
- conditional helpers in LiveViews, plugs, and content processing code

## Relevant Assumptions / Defaults

- This phase targets the repetitive small-refactor rules: `cond` to `if`, `Enum.map_join/3`, chained `Enum.filter/2` and `Enum.reject/2`, redundant `with` clauses, negated `if` conditions, and `length/1` emptiness checks.
- The rule families here are numerous but locally scoped; each change should stay reviewable and easy to test.
- This phase should reduce noise before the larger complexity reductions in Phase 4.

[ ] 3 Phase 3 - Control Flow and Collection Simplification
  Remove high-volume micro-refactor findings so the remaining Credo baseline represents real structural work rather than repetitive local cleanup.

  [ ] 3.1 Section - Conditional Simplification
    Normalize conditional expressions so simple branches read like simple branches.

    [ ] 3.1.1 Task - Replace one-branch `cond` expressions with `if`
      Convert the `17` flagged `cond` sites to `if` where there is no real multi-branch decision tree.

      [ ] 3.1.1.1 Subtask - Start with `content_gen`, `content_ontology`, ecosystem, and example taxonomy helpers where the pattern repeats.
      [ ] 3.1.1.2 Subtask - Keep multi-branch `cond` blocks intact when they truly encode more than one meaningful branch.

    [ ] 3.1.2 Task - Remove negated `if` shapes and redundant final `with` clauses
      Make the remaining local control flow direct so the happy path reads first.

      [ ] 3.1.2.1 Subtask - Rewrite the flagged negated `if` sites in GitHub/content-ops code to positive-first logic.
      [ ] 3.1.2.2 Subtask - Remove redundant trailing `with` clauses where the last clause just mirrors the previous pattern.

  [ ] 3.2 Section - Collection Pipeline Simplification
    Reduce repetitive list-processing findings by using the combinators Credo expects for the shapes already present.

    [ ] 3.2.1 Task - Replace `Enum.map |> Enum.join` with `Enum.map_join`
      Collapse the `19` flagged string-building pipelines into the dedicated function built for that shape.

      [ ] 3.2.1.1 Subtask - Prioritize content-generation prompts, writer helpers, and page/menu utilities because those helpers are reused widely.
      [ ] 3.2.1.2 Subtask - Preserve exact output formatting and separators when converting to `Enum.map_join/3`.

    [ ] 3.2.2 Task - Collapse chained `Enum.filter` and `Enum.reject`
      Replace repeated two-pass filtering with the equivalent single-pass forms.

      [ ] 3.2.2.1 Subtask - Start with `content_gen.selection`, `pages`, link-audit helpers, and related tests where the pattern is repeated.
      [ ] 3.2.2.2 Subtask - Re-run local tests around the touched selection logic because these helpers can subtly affect ordering and inclusion.

    [ ] 3.2.3 Task - Replace `length/1` emptiness checks
      Remove the final four warning-level findings by checking list emptiness directly.

      [ ] 3.2.3.1 Subtask - Fix the assistant and simulated-showcase helpers first because they are active UI code.
      [ ] 3.2.3.2 Subtask - Update the showcase test so the warning is removed in both app and test code.

  [ ] 3.3 Section - Phase 3 Integration Tests
    Verify that the small refactors remove the intended findings and do not change observable behavior.

    [ ] 3.3.1 Task - Add Phase 3 verification coverage
      Confirm the micro-refactor families are materially reduced before Phase 4 begins.

      [ ] 3.3.1.1 Subtask - Run `mix test` for the affected helper-heavy subsystems after each batch of collection and control-flow rewrites.
      [ ] 3.3.1.2 Subtask - Run `mix credo --strict` and confirm the `cond`, `map_join`, chained filter/reject, and `length/1` families are removed or nearly removed.
