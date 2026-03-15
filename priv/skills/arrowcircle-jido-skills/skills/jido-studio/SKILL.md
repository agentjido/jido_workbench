---
name: jido-studio
description: Builder-oriented guidance for the upstream `jido_studio` package. Use when Codex needs to plan or review Jido operator tooling, workbench pages, demos, or Studio-facing integrations, especially when turning ecosystem package material into concrete examples without over-claiming undocumented UI capabilities.
---

# Jido Studio

`jido_studio` is the upstream Hex package name.

## Start Here

Use this skill for workbench, operator, and demo-facing tasks around the Jido ecosystem.

Good triggers:
- "Add or update a Studio page for this ecosystem package."
- "Plan an operator-facing workflow for agents."
- "Turn package source material into a Studio demo."
- "Review whether this feature belongs in Studio or in a package repo."

The public documentation is thinner here than for the core libraries. Keep proposals narrow and grounded in the ecosystem page, issue #51, and any package-specific examples you can verify.

## Primary Workflows

### Build or update ecosystem-facing pages

- Start from the package boundary and the user workflow the page should support.
- Prefer concrete demos, examples, or inspection surfaces over generic marketing copy.
- Reuse existing package terminology so Studio and package docs stay aligned.

### Plan operator tooling

- Make agent state, signals, or traces visible without coupling Studio to private app internals.
- Keep operational controls explicit and reversible.
- Document which runtime data the Studio feature depends on.

### Turn source material into demos

- Build examples that prove one builder workflow end to end.
- Keep the demo small enough to run or explain without hidden infrastructure.
- Call out assumptions when package docs do not define a Studio integration contract.

## Build Checklist

- Identify the operator or contributor workflow first.
- Name the package or runtime data the Studio surface depends on.
- Keep demos aligned with documented package behavior.
- Mark inferred Studio behavior as inferred.

## Boundaries

- Do not invent undocumented Studio APIs or page contracts.
- Do not move package-specific implementation details into Studio unless the user explicitly wants that coupling.
- Do not treat thin ecosystem descriptions as proof of a full product feature.
