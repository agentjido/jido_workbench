# Phase 5 - Community Showcase Validation and Closeout

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `AgentJido.Community.Showcase`
- `AgentJido.Community.Showcase.Project`
- `AgentJidoWeb.JidoCommunityShowcaseLive`
- `AgentJidoWeb.MarkdownContent`
- `AgentJidoWeb.Router`
- `lib/agent_jido_web/controllers/sitemap_html/index.xml.eex`
- `priv/community_showcase/*.md`
- `test/agent_jido/community/showcase_test.exs`
- `test/agent_jido_web/live/page_live_test.exs`

## Relevant Assumptions / Defaults
- The community showcase route and content loader already exist and should be treated as validate-and-close work.
- Closure evidence must prove that the shipped implementation satisfies the original issue scope rather than reopening the feature as greenfield work.
- Structured markdown entries under `priv/community_showcase/**` remain the source of truth for published showcase cards.

[ ] 5 Phase 5 - Community Showcase Validation and Closeout
  Close the already-landed community showcase issue with explicit validation and residual-gap cleanup.

  [ ] 5.1 Section - Issue #32 Built with Jido / Community Showcase
    Treat the issue as implemented-but-open and plan a closeout audit against the original requested scope.

    [ ] 5.1.1 Task - Validate the current showcase implementation and identify only residual closeout work
      Confirm the existing route, content loader, rendered cards, sitemap presence, and markdown fallback satisfy the original request.

      [ ] 5.1.1.1 Subtask - Audit the current showcase page, loader, and seeded entries against the original project-card scope of name, one-line description, link, and optional logo.
      [ ] 5.1.1.2 Subtask - Limit any follow-on work to residual polish, validation, or test gaps needed for evidence-based closure.

  [ ] 5.2 Section - Phase 5 Integration Tests
    Validate the community showcase as a stable shipped surface and close the issue with evidence.

    [ ] 5.2.1 Task - Add Phase 5 showcase closeout coverage
      Ensure the showcase remains routable, indexed, and backed by structured content.

      [ ] 5.2.1.1 Subtask - Require showcase page render, markdown fallback, and sitemap coverage as closeout evidence.
      [ ] 5.2.1.2 Subtask - Require structured-content loader coverage for published and hidden showcase entries.
