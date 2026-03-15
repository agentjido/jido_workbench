[← Back to specs](/Users/Pascal/code/agentjido/jido_run/specs/README.md)

# Credo Strict Remediation Plan

This planning set tracks the current `mix credo --strict` remediation effort for the workbench codebase.

The baseline was captured on March 14, 2026 with:

```bash
ASDF_ELIXIR_VERSION=1.18.4-otp-27 \
ASDF_ERLANG_VERSION=27.3 \
CONTENTOPS_CHAT_ENABLED=false \
mix credo --strict
```

The captured baseline includes:

- `38` software design suggestions
- `78` code readability issues
- `127` refactoring opportunities
- `4` warnings

The heaviest rule families in the current baseline are:

- nested function bodies: `44`
- nested module alias suggestions: `38`
- cyclomatic complexity: `32`
- line length: `19`
- `Enum.map_join/3` simplifications: `19`
- `cond` to `if` simplifications: `17`
- single-clause `with` to `case`: `15`
- alias ordering: `11`
- missing `@moduledoc`: `9`

The hottest files in the current baseline are:

- `lib/agent_jido/content_ontology/exporter.ex`
- `lib/agent_jido_web/live/admin_content_generator_live.ex`
- `lib/agent_jido_web/live/chat_ops_live.ex`
- `lib/agent_jido/pages.ex`
- `lib/agent_jido/content_assistant.ex`
- `lib/agent_jido/content_gen/*`

## Numbering and Tracking

- Every phase, section, task, and subtask uses explicit numbered checkboxes.
- Every phase, section, and task starts with a short description paragraph.
- Every phase ends with an integration-testing section.
- This plan groups work by Credo rule family and hotspot cluster, not by GitHub issue number.

## Phases

- [Phase 1 - Alias and Module Hygiene](/Users/Pascal/code/agentjido/jido_run/specs/planning/credo/phase-01-credo-alias-and-module-hygiene.md)
- [Phase 2 - Readability and Documentation Hygiene](/Users/Pascal/code/agentjido/jido_run/specs/planning/credo/phase-02-credo-readability-and-documentation-hygiene.md)
- [Phase 3 - Control Flow and Collection Simplification](/Users/Pascal/code/agentjido/jido_run/specs/planning/credo/phase-03-credo-control-flow-and-collection-simplification.md)
- [Phase 4 - Complexity and Nesting Hotspot Reduction](/Users/Pascal/code/agentjido/jido_run/specs/planning/credo/phase-04-credo-complexity-and-nesting-hotspot-reduction.md)
- [Phase 5 - Credo Strict Quality Gate Promotion](/Users/Pascal/code/agentjido/jido_run/specs/planning/credo/phase-05-credo-strict-quality-gate-promotion.md)

## Related Local Planning

- [Open Issue Remediation Status](/Users/Pascal/code/agentjido/jido_run/specs/planning/open-issue-remediation-status.md)
