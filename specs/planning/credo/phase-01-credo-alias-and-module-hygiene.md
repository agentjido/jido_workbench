[Back to index](/Users/Pascal/code/agentjido/jido_run/specs/planning/credo/README.md)

## Relevant Shared APIs / Interfaces

- `mix credo --strict`
- `use Jido.Agent`
- Phoenix LiveView modules under `lib/agent_jido_web/live/**`
- demo agents and tests under `lib/agent_jido/demos/**` and `test/**`

## Relevant Assumptions / Defaults

- This phase targets the `38` repeated “nested modules could be aliased” suggestions and the alias-ordering readability findings.
- Behavior must remain unchanged; this is import/alias surface cleanup only.
- The goal is to make the namespace usage consistent before deeper refactors touch the same files.

[ ] 1 Phase 1 - Alias and Module Hygiene
  Normalize alias declarations and nested module references so the codebase stops paying repeated namespace-hygiene penalties in Credo.

  [ ] 1.1 Section - Nested Module Alias Cleanup
    Remove repeated inline nested-module references by lifting them into explicit alias blocks at the top of each module.

    [ ] 1.1.1 Task - Clean nested module references in application code
      Resolve the repeated “nested modules could be aliased” findings in product code without changing runtime behavior.

      [ ] 1.1.1.1 Subtask - Normalize the hot-path modules first, including `content_ops`, `content_gen`, `github`, and LiveView rendering modules.
      [ ] 1.1.1.2 Subtask - Keep alias groups readable and stable so follow-on phases do not reintroduce inline nested references.

    [ ] 1.1.2 Task - Clean nested module references in tests and support helpers
      Bring test helpers and Mix task tests into the same alias style so the rule family is removed consistently across app and test code.

      [ ] 1.1.2.1 Subtask - Normalize `test/support/**` and repeated Mix task test modules first because they produce multiple identical findings.
      [ ] 1.1.2.2 Subtask - Preserve test readability by grouping aliases around the modules actually exercised in each test.

  [ ] 1.2 Section - Alias Ordering Cleanup
    Fix alphabetic alias ordering findings so grouped aliases stop drifting and future diffs stay smaller.

    [ ] 1.2.1 Task - Reorder alias groups in app code
      Apply consistent alphabetical ordering inside grouped aliases across content, demos, and web modules.

      [ ] 1.2.1.1 Subtask - Normalize the repeated demo-agent alias groups first because they overlap with other cleanup phases.
      [ ] 1.2.1.2 Subtask - Keep grouped aliases semantically clustered while still satisfying Credo ordering rules.

    [ ] 1.2.2 Task - Reorder alias groups in tests
      Remove alias-order drift in test modules so CI-facing helper code follows the same standard as app code.

      [ ] 1.2.2.1 Subtask - Fix repeated ordering findings in content-ops, assistant, page, and demo tests.
      [ ] 1.2.2.2 Subtask - Re-run Credo on the touched test files to ensure no local reordering issues remain.

  [ ] 1.3 Section - Phase 1 Integration Tests
    Verify that namespace cleanup removes the targeted design/readability findings without altering behavior.

    [ ] 1.3.1 Task - Add Phase 1 verification coverage
      Confirm the alias hygiene cleanup is complete and does not introduce compile or test regressions.

      [ ] 1.3.1.1 Subtask - Run `mix format --check-formatted` and `mix compile --warnings-as-errors` after each cleanup batch.
      [ ] 1.3.1.2 Subtask - Run `mix credo --strict` and confirm the nested-module and alias-ordering counts have dropped as expected.
