# Jido Run Open-Issue Execution Plan Index

This directory contains a phased execution plan for resolving the current open issues in `agentjido/jido_run`.

The plan aligns to:
- the current GitHub open issue tracker for `agentjido/jido_run`
- `specs/content-system.md`
- `specs/content-governance.md`
- the public content and example surfaces under `priv/`

## Phase Files
1. [Phase 1 - Published Docs and Tutorial Corrections](./phase-01-published-docs-and-tutorial-corrections.md): resolve correctness, broken-link, and tutorial-API drift in published docs content.
2. [Phase 2 - Public Example Truthfulness and Deterministic Demo Migration](./phase-02-public-example-truthfulness-and-deterministic-demo-migration.md): replace misleading public simulated examples with truthful deterministic surfaces.
3. [Phase 3 - Workbench Capability Expansion and Adoption](./phase-03-workbench-capability-expansion-and-adoption.md): add MCP retrieval and builder-skill capabilities to the workbench.
4. [Phase 4 - Workbench Maintainability and Internal Quality](./phase-04-workbench-maintainability-and-internal-quality.md): reduce high-value duplication and stabilize internal implementation seams.
5. [Phase 5 - Community Showcase Validation and Closeout](./phase-05-community-showcase-validation-and-closeout.md): validate the already-landed showcase implementation and close the remaining issue with evidence.

## Shared Conventions
- Numbering:
  - Phases: `N`
  - Sections: `N.M`
  - Tasks: `N.M.K`
  - Subtasks: `N.M.K.L`
- Tracking:
  - Every phase, section, task, and subtask uses Markdown checkboxes (`[ ]`).
- Description requirement:
  - Every phase, section, and task starts with a short description paragraph.
- Integration-test requirement:
  - Each phase ends with a final integration-testing section.

## Shared Assumptions and Defaults
- Phase numbering starts at `1` for this repo and does not inherit numbering from `../../epic/jido_os/specs/planning`.
- Every currently open issue appears exactly once as a section in this plan set.
- Issues `#32` and `#40` are treated as validate-and-close sections because substantial implementation already exists in the repo.
- Example slugs in scope remain stable unless a section explicitly redefines the page as an overview or reference surface.
- Issue `#49` plans both `stdio` and HTTP transports in v1 while remaining strictly read-only.
- Issue `#51` plans workbench-first checked-in `SKILL.md` assets under `priv/skills/`.

## Related Planning
- [Credo Strict Remediation Plan](./credo/README.md)
- [Open Issue Remediation Status](./open-issue-remediation-status.md)
