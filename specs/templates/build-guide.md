<!-- 
  TEMPLATE: Build Guide
  Use for: /build/* pages (e.g., /build/mixed-stack-integration)
  Tone: See specs/style-voice.md — code-first, then explain why it works that way.
  Rules: content-outline.md §5 (clear claim, architecture explanation, runnable proof,
         training cross-link, docs/reference cross-link, CTA).
-->

# [GUIDE TITLE]

## What You'll Build

<!-- Outcome statement: What does the reader have at the end of this guide?
     Be concrete: "A running agent that processes webhooks and routes them to specialized handlers"
     not "Learn how to use Jido for integrations." -->

[ONE PARAGRAPH DESCRIBING THE CONCRETE OUTCOME. What will be running when they finish? What does it do?]

---

## Prerequisites

<!-- List what the reader needs before starting. Be specific about versions.
     All setup steps must be tested against current package versions (content-governance.md §10). -->

- Elixir [VERSION]+ and OTP [VERSION]+
- [PACKAGE_NAME] `~> [VERSION]` — [why this package is needed]
- [PACKAGE_NAME] `~> [VERSION]` — [why]
- [ANY OTHER PREREQUISITES — API keys, running services, prior guides completed]

---

## Architecture Overview

<!-- What packages are involved and how they connect. This is the "map" before the "directions."
     Include a diagram showing the components and data flow. -->

[2-3 SENTENCES EXPLAINING THE ARCHITECTURE OF WHAT YOU'RE BUILDING]

```mermaid
graph LR
    A[COMPONENT] -->|SIGNAL/DATA| B[COMPONENT]
    B --> C[COMPONENT]
```

---

## Implementation

<!-- Code-first, explain after (style-voice.md §Technical Depth by Section).
     Each step should have runnable code. Build incrementally — each step should
     work on its own before moving to the next. -->

### Step 1: [ACTION VERB — e.g., "Define the Agent"]

```elixir
[RUNNABLE CODE]
```

<!-- Explain what the code does and why it's structured this way. Keep it brief — 
     the code should be mostly self-explanatory. -->

[1-3 SENTENCES EXPLAINING THE CODE]

### Step 2: [ACTION VERB]

```elixir
[RUNNABLE CODE]
```

[EXPLANATION]

### Step 3: [ACTION VERB]

```elixir
[RUNNABLE CODE]
```

[EXPLANATION]

<!-- Add more steps as needed. Each step should be small enough to verify independently. -->

---

## Testing & Verification

<!-- How does the reader confirm it works? Provide a concrete test or verification step. -->

```elixir
# Verify the implementation
[TEST OR VERIFICATION CODE]
```

**Expected result:**

```
[EXPECTED OUTPUT]
```

---

## Next Steps

<!-- Cross-links required (content-outline.md §5, §6).
     Build pages link to: training modules and docs. -->

- **Go deeper:** [TRAINING MODULE TITLE](/training/[MODULE-SLUG]) — [what they'll learn next]
- **Reference:** [DOCS PAGE](/docs/[PATH]) — [what they'll find there]
- **Related guide:** [ANOTHER BUILD GUIDE](/build/[SLUG]) — [how it extends what they just built]

---

## Get Building

<!-- CTA required (content-outline.md §5 rule 6). -->

[SENTENCE CONNECTING THIS GUIDE TO THE BROADER JIDO ECOSYSTEM OR A NATURAL NEXT ACTION]

[Get started with Jido](/build/getting-started) | [Explore the ecosystem](/ecosystem)

---

<!--
  ============================================================
  PUBLISHING CHECKLIST (content-governance.md §10)
  Remove this block before publishing.
  ============================================================

  Before publishing:
  [ ] Package references are real — every package in priv/ecosystem/*.md with visibility: public
  [ ] Code examples compile — tested against current package versions
  [ ] Links resolve — all cross-links point to real routes
  [ ] Claims are bounded
  [ ] CTA is present and routed
  [ ] Voice check — code-first, explanations after
  [ ] Cross-link chain — forward (training/docs) and backward (features/ecosystem)

  Build-specific checks:
  [ ] All setup steps tested against current package versions
  [ ] Prerequisites are listed completely
  [ ] Steps are runnable in sequence — each builds on the previous
-->
