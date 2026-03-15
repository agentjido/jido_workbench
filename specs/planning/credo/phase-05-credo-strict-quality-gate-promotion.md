[Back to index](/Users/Pascal/code/agentjido/jido_run/specs/planning/credo/README.md)

## Relevant Shared APIs / Interfaces

- `mix credo --strict`
- `mix quality`
- managed git hooks in `config/config.exs`
- CI and local contributor workflows

## Relevant Assumptions / Defaults

- This phase should only promote Credo into an enforced gate once the repo-wide strict baseline is at or near zero.
- The Dialyzer remediation already proved the pattern: do not gate on a tool until the baseline is actually clean.
- If residual Credo findings remain by design, they must be documented explicitly rather than silently tolerated.

[ ] 5 Phase 5 - Credo Strict Quality Gate Promotion
  Turn the cleaned Credo baseline into an enforced repository guardrail only after the earlier phases have made that gate practical.

  [ ] 5.1 Section - Final Credo Baseline Audit
    Re-run the strict linter at the end of the cleanup sequence and confirm what, if anything, still remains.

    [ ] 5.1.1 Task - Produce a final zero-or-near-zero Credo baseline
      Ensure the remaining output is intentional and documented before promoting the gate.

      [ ] 5.1.1.1 Subtask - Run `mix credo --strict` after Phase 4 and capture the remaining findings, if any, into a fresh audit note.
      [ ] 5.1.1.2 Subtask - Resolve or document any residual non-zero baseline before turning the hook or CI gate on.

  [ ] 5.2 Section - Promote Credo to an Enforced Quality Gate
    Add `credo --strict` to the repo’s supported quality path once developers can run it locally without inheriting unrelated baseline failures.

    [ ] 5.2.1 Task - Wire Credo into the practical enforcement path
      Choose the lightest enforcement point that still blocks regressions without making normal development unworkable.

      [ ] 5.2.1.1 Subtask - Add `mix credo --strict` to the managed hook or quality alias only after the baseline is demonstrably clean.
      [ ] 5.2.1.2 Subtask - Verify that the chosen gate works in this repo’s ASDF-dependent local workflow and does not fail for non-Credo reasons.

  [ ] 5.3 Section - Phase 5 Integration Tests
    Verify that the new gate is both effective and practical for everyday contributor workflows.

    [ ] 5.3.1 Task - Add Phase 5 verification coverage
      Confirm the final gate catches regressions and still allows ordinary clean changes to be committed and pushed.

      [ ] 5.3.1.1 Subtask - Run the managed hook path end-to-end after promotion and confirm a clean branch passes locally.
      [ ] 5.3.1.2 Subtask - Update any contributor-facing docs or runbooks that mention local quality expectations once the gate is live.
