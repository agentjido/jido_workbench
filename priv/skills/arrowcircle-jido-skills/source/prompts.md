# Jido Ecosystem Skills Generation Prompt

Use this prompt to generate a builder-oriented set of Codex skills for the Jido ecosystem.

```text
Build a starter catalog of Codex skills for the Jido ecosystem.

Goal

Create one skill per Jido ecosystem package so contributors and adopters can build with each package, not just read about it. Use the framing from agentjido/jido_run issue #51 ("Create builder Skills for common Jido ecosystem workflows") as inspiration for workflow shape and acceptance criteria, but keep the deliverable as one skill per ecosystem package.

Authoritative scope

Treat the current Jido ecosystem page as the authoritative package list. Create exactly one skill for each of these packages and do not create extras unless the ecosystem page itself has changed:

- llm_db
- req_llm
- jido_action
- jido_signal
- jido
- jido_browser
- jido_memory
- jido_behaviortree
- ash_jido
- jido_studio
- jido_messaging
- jido_otel

Do not create a separate jido_ai skill unless it appears in the current ecosystem matrix. You may still use jido_ai docs or ecosystem pages as shared reference material if they clarify how a package is built or used.

Source material

Research in this order:

1. Ecosystem scope and package links:
   - https://jido.run/ecosystem
2. Shared Jido baseline:
   - https://hexdocs.pm/jido/readme.html
3. Package-specific docs and source repos:
   - Follow the package links from the ecosystem page to each package's HexDocs, Hex package page, GitHub repo, and any package docs linked from there.
4. Builder-skill inspiration:
   - https://github.com/agentjido/jido_run/issues/51

If a package has thin or missing docs, inspect the package repo and infer carefully from source structure, examples, tests, and README material. Call out unresolved ambiguity in the final report instead of inventing unsupported behavior.

Deliverable layout

Write all output into the local skills directory. Create one folder per package:

- skills/<package>/SKILL.md
- skills/<package>/agents/openai.yaml

Optional:

- skills/<package>/references/... only when a package needs condensed local notes, API summaries, workflow checklists, or architecture guidance that would otherwise make SKILL.md too large or too vague.

Do not add scripts, assets, or extra docs unless they are clearly necessary for deterministic, repeated builder workflows. Do not create filler files such as README.md, CHANGELOG.md, NOTES.md, or placeholder assets.

Skill requirements

Each skill must be builder-oriented. Do not produce generic "overview" skills.

Every SKILL.md must:

- Use YAML frontmatter with only:
  - name
  - description
- Use a description that clearly states what the skill does and when it should trigger.
- Focus on package-native building tasks such as:
  - scaffolding or extending package concepts
  - implementing or integrating adapters, plugins, providers, or tooling around that package
  - turning docs or source material into runnable examples, tutorials, or starter implementations
  - reviewing boundaries, dependencies, and docs gaps for that package
- Include concrete task examples that are specific to the package.
- State boundaries and non-goals so the skill does not over-trigger.
- Include runtime or ecosystem context when relevant, such as Elixir/OTP conventions, Ash integration, messaging boundaries, telemetry concerns, browser automation limits, or storage/runtime assumptions.
- Prefer concise, procedural guidance over long explanations.
- Be written for another Codex instance that will use the skill to do real work.

Each agents/openai.yaml must:

- Match the skill's actual scope.
- Use a clear display name, short description, and default prompt aligned to builder workflows for that package.
- Avoid generic metadata that could apply to any library.

Quality bar

- Keep wording Elixir-first and Jido-specific.
- Reuse shared Jido concepts from the core docs where relevant, but tailor each skill to the package's real responsibilities.
- Avoid copy-paste bodies across packages.
- Keep artifacts ASCII-first unless the source material requires otherwise.
- Do not assume local helper scripts, generators, or scaffolding tools exist unless they are documented in the package you are working from.
- If a package has no reliable support for a workflow, say so and narrow the skill accordingly.

Execution guidance

- Start by mapping all 12 packages to their linked docs/repos.
- For each package, identify:
  - the package purpose
  - the primary builder workflows
  - the core abstractions users extend or integrate with
  - the likely failure modes, boundaries, and docs gaps
- Then write the skill files for that package before moving to the next.
- Keep shared concepts consistent across skills, but do not flatten package differences.

Final report

After generating the files, produce a completion report that includes:

- all 12 packages
- the files created for each package
- the primary source URLs used for each package
- any package with missing docs, weak examples, or unresolved ambiguity
- any package where you intentionally kept the skill narrow because the docs did not justify a broader builder workflow

Success criteria

- Exactly one skill exists for each package in the authoritative ecosystem list.
- Every package has SKILL.md and agents/openai.yaml.
- Skills help a user build, extend, review, or integrate with the package.
- Optional references are present only where they materially improve reuse.
- The final report makes coverage and gaps explicit.
```
