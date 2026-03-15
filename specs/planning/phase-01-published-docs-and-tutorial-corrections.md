# Phase 1 - Published Docs and Tutorial Corrections

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `AgentJido.Pages`
- `AgentJido.Pages.LivebookParser`
- `AgentJidoWeb.PageLive`
- `AgentJidoWeb.MarkdownLinks`
- `AgentJido.Release.LinkAudit`
- `Mix.Tasks.Site.LinkAudit`
- `priv/pages/docs/learn/ai-chat-agent.livemd`
- `priv/pages/docs/learn/plugins-and-composable-agents.livemd`
- `priv/pages/docs/guides/cookbook/chat-response.livemd`

## Relevant Assumptions / Defaults
- Published docs content remains file-backed under `priv/pages/**`.
- Route parity and internal link health are required before a Phase 1 issue can close.
- Tutorial snippets must match current Jido and `jido_ai` APIs, not legacy patterns.
- Existing cookbook content already present in the repo is treated as the canonical source for cookbook publication work.

[ ] 1 Phase 1 - Published Docs and Tutorial Corrections
  Resolve correctness, broken-link, and tutorial-API drift in published docs content.

  [ ] 1.1 Section - Issue #70 Correct code snippet in `Plugins and composable agents`
    Correct the runtime snippet and surrounding explanation so the tutorial matches current Jido startup semantics.

    [ ] 1.1.1 Task - Fix plugin tutorial runtime snippet and verify tutorial parity
      Update the code sample and confirm the full tutorial path remains internally consistent.

      [ ] 1.1.1.1 Subtask - Replace the invalid `Jido.start_agent(jido, ...)` usage with the canonical instance-name form and align the nearby prose and sample output expectations.
      [ ] 1.1.1.2 Subtask - Re-check the full tutorial snippet sequence against current Jido APIs and capture the regression checks required before the issue is considered closed.

  [ ] 1.2 Section - Issue #69 Broken link on AI Chat Agent docs page points to unpublished cookbook recipe
    Restore route parity between the AI chat tutorial and the cookbook content it references.

    [ ] 1.2.1 Task - Publish or finalize the canonical cookbook target and remove the broken link path
      Make `/docs/guides/cookbook/chat-response` production-ready and verify the upstream tutorial reference resolves.

      [ ] 1.2.1.1 Subtask - Treat the existing cookbook source already present in the repo as the canonical destination and define any polish needed before it is considered published content.
      [ ] 1.2.1.2 Subtask - Require route-render and link-audit verification for both the AI chat page and the cookbook page before closure evidence is considered complete.

  [ ] 1.3 Section - Issue #57 AI Chat Agent tutorial doesn't appear to work
    Remove unsupported callback guidance and replace it with a lifecycle-safe multi-turn state pattern.

    [ ] 1.3.1 Task - Rewrite the chat tutorial around supported `Jido.AI.Agent` lifecycle hooks
      Keep the tutorial goal intact while eliminating the invalid `init/1` callback example.

      [ ] 1.3.1.1 Subtask - Replace the `init/1` example with supported state or history management using current lifecycle callbacks or an equivalent canonical pattern that reflects current `Jido.AI.Agent` behavior.
      [ ] 1.3.1.2 Subtask - Verify all snippets on the page against current API behavior and record the regression proof required for issue closure.

  [ ] 1.4 Section - Issue #71 The learn plugins and composable agents section seems to have a problem
    Resolve the remaining runtime-name mismatch in the `Signal routing through the runtime` section so the published tutorial fully matches `Jido.start_agent/3` expectations.

    [ ] 1.4.1 Task - Audit and correct the signal routing runtime snippet end-to-end
      Ensure the section uses the runtime instance name consistently and reflects the actual `jido 2.0.0` function contract users hit in practice.

      [ ] 1.4.1.1 Subtask - Confirm the `Signal routing through the runtime` example uses `Jido.start_agent(:learn_plugins, ...)` and does not reintroduce pid-based startup examples.
      [ ] 1.4.1.2 Subtask - Add or update regression coverage so the livebook page cannot drift back to the invalid pid form after future edits.

  [ ] 1.5 Section - Phase 1 Integration Tests
    Validate docs route parity, link health, and snippet or tutorial correctness for all Phase 1 fixes.

    [ ] 1.5.1 Task - Add Phase 1 docs regression coverage
      Ensure all repaired docs flows remain stable and routable.

      [ ] 1.5.1.1 Subtask - Require route-render and link-audit coverage for every touched docs route.
      [ ] 1.5.1.2 Subtask - Require snippet-level or livebook-level verification where code examples are the source of the original defect.
