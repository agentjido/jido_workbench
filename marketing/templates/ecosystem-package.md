<!-- 
  TEMPLATE: Ecosystem Package Page
  Use for: Individual package detail pages under /ecosystem/*
  Tone: See marketing/style-voice.md — concept-first, then one code example per capability.
  Rules: content-outline.md §5 (clear claim, architecture explanation, runnable proof,
         training cross-link, docs/reference cross-link, CTA).
-->

# [PACKAGE_NAME]

<!-- One-line description: What does this package do? Be specific.
     E.g., "Typed signal definitions and routing for inter-agent communication." -->

[ONE-LINE DESCRIPTION OF WHAT THIS PACKAGE DOES]

<!-- Status must match one of: Stable | Beta | Experimental | Planned
     Package metadata must match priv/ecosystem/*.md frontmatter (content-governance.md §10). -->

**Status:** [Stable | Beta | Experimental | Planned]

---

## Where This Fits

<!-- Ecosystem layer: core / AI / tools / integrations.
     One sentence explaining how this package relates to the rest of the Jido stack. -->

**Layer:** [core | AI | tools | integrations]

[1-2 SENTENCES ON WHERE THIS SITS IN THE JIDO ARCHITECTURE AND WHY IT EXISTS AS A SEPARATE PACKAGE]

---

## Key Capabilities

<!-- Bullet list of what this package provides. Be specific — name the behaviors,
     not the benefits. "Defines typed signal schemas with validation" not "powerful messaging." -->

- [CAPABILITY 1]
- [CAPABILITY 2]
- [CAPABILITY 3]
- [CAPABILITY 4]

---

## Quick Example

<!-- Copy-paste-run example. Under 30 lines (style-voice.md §Code Example Conventions).
     Use realistic names. Show the output. Must compile against current package version
     (content-governance.md §10 check 2). -->

```elixir
# [WHAT THIS EXAMPLE SHOWS]

[RUNNABLE CODE EXAMPLE]
```

**Output:**

```
[EXPECTED OUTPUT]
```

---

## Works Best With

<!-- Related packages — name the packages and say why they pair well.
     Only reference packages that exist in priv/ecosystem/*.md with visibility: public. -->

| Package | Why |
|---------|-----|
| [PACKAGE_NAME](/ecosystem/[SLUG]) | [ONE SENTENCE — how they work together] |
| [PACKAGE_NAME](/ecosystem/[SLUG]) | [ONE SENTENCE] |

---

## Installation

<!-- Standard Mix installation. Verify version is current. -->

Add `[package_name]` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:[PACKAGE_NAME], "~> [VERSION]"}
  ]
end
```

Then run:

```bash
mix deps.get
```

---

## Links

- [HexDocs](https://hexdocs.pm/[PACKAGE_NAME])
- [hex.pm](https://hex.pm/packages/[PACKAGE_NAME])
- [GitHub](https://github.com/agentjido/[PACKAGE_NAME])

---

## Get Building

<!-- CTA required (content-outline.md §5 rule 6). Link to real destinations. -->

Start using [PACKAGE_NAME] in a project: [Build guide](/build/[RELEVANT-GUIDE]) | [Training module](/training/[RELEVANT-MODULE]) | [API reference](/docs/reference/[PACKAGE_NAME])

---

<!--
  ============================================================
  PUBLISHING CHECKLIST (content-governance.md §10)
  Remove this block before publishing.
  ============================================================

  Before publishing:
  [ ] Package references are real — exists in priv/ecosystem/*.md with visibility: public
  [ ] Code examples compile — real modules, real functions, correct arities
  [ ] Links resolve — all cross-links point to real routes
  [ ] Claims are bounded — no unsubstantiated performance claims
  [ ] CTA is present and routed
  [ ] Voice check — staff engineer tone, not marketing
  [ ] Cross-link chain — forward (build/training/docs) and backward (features/ecosystem)

  Ecosystem-specific checks:
  [ ] Package metadata matches priv/ecosystem/*.md frontmatter
  [ ] Dependency relationships are accurate
  [ ] Version number is current
-->
