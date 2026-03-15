# Phase 3 - Workbench Capability Expansion and Adoption

Back to index: [README](./README.md)

## Relevant Shared APIs / Interfaces
- `AgentJido.ContentAssistant.Retrieval`
- `AgentJido.ContentIngest.Inventory`
- `AgentJidoWeb.MarkdownContent`
- `AgentJido.Pages`
- `AgentJido.Blog`
- `AgentJido.Ecosystem`
- `priv/ecosystem/jido_skill.md`
- `priv/pages/docs/learn/multi-agent-orchestration.livemd`
- planned `priv/skills/**`

## Relevant Assumptions / Defaults
- The workbench app is this Phoenix LiveView repo and is the canonical host for the initial planning set.
- MCP v1 remains read-only and docs-first even though both `stdio` and HTTP transports are planned.
- Builder skills are workbench-first artifacts and use checked-in `SKILL.md` files rather than external-only references.
- The initial builder-skill catalog may document package-repo follow-on work, but at least one end-to-end demonstration must live in this repo.

[ ] 3 Phase 3 - Workbench Capability Expansion and Adoption
  Add new workbench capabilities for external retrieval and contributor-building workflows.

  [ ] 3.1 Section - Issue #49 MCP documentation query server
    Add a read-only MCP surface for docs retrieval with both local and remote transports in the first phase.

    [ ] 3.1.1 Task - Plan the v1 MCP contract and transport rollout
      Define the read-only operation set, retrieval scope, transport expectations, and verification path.

      [ ] 3.1.1.1 Subtask - Plan `search_docs`, `get_doc`, and `list_sections` as the only v1 operations, with canonical URLs, snippets, and citation metadata.
      [ ] 3.1.1.2 Subtask - Plan both `stdio` and HTTP transports in v1 while keeping the server explicitly read-only and docs-first.

  [ ] 3.2 Section - Issue #51 Builder Skills for common Jido ecosystem workflows
    Create a workbench-first builder-skill catalog with concrete checked-in skill artifacts.

    [ ] 3.2.1 Task - Plan the initial builder skill catalog and artifact layout
      Define the minimum v1 skill set and where those assets live.

      [ ] 3.2.1.1 Subtask - Plan checked-in `priv/skills/<skill>/SKILL.md` assets for at least action, agent, plugin, ecosystem-page, and example or tutorial builder workflows.
      [ ] 3.2.1.2 Subtask - Plan one end-to-end workbench-hosted demonstration and explicitly document what remains package-repo follow-on work.

  [ ] 3.3 Section - Phase 3 Integration Tests
    Validate the new MCP and skill-catalog surfaces as stable workbench capabilities.

    [ ] 3.3.1 Task - Add Phase 3 capability regression coverage
      Ensure new retrieval and skill-loading surfaces are testable and documented.

      [ ] 3.3.1.1 Subtask - Require MCP search and document-fetch tests for both transports.
      [ ] 3.3.1.2 Subtask - Require skill-loader coverage against checked-in `SKILL.md` fixtures and docs rendering coverage for the builder-skill walkthrough.
