%{
  priority: :high,
  status: :planned,
  title: "MCP Integration Guide",
  repos: ["jido", "jido_ai"],
  tags: [:docs, :guides, :mcp, :integration],
  audience: :intermediate,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/guides/mcp-integration",
  ecosystem_packages: ["jido", "jido_ai"],
  learning_outcomes: ["Connect Jido agents to MCP-compatible tool servers",
   "Expose Jido actions as MCP tools for external clients",
   "Handle MCP protocol lifecycle and error cases"],
  order: 60,
  prerequisites: ["docs/learn/tool-use"],
  purpose: "Guide for integrating Jido agents with the Model Context Protocol (MCP) — both as client and server",
  related: ["docs/learn/tool-use", "docs/learn/ai-chat-agent",
   "docs/reference/packages/jido-ai"],
  source_modules: ["Jido.AI"],
  prompt_overrides: %{
    document_intent: "Write a guide for MCP integration — consuming external MCP tools and exposing Jido actions via MCP protocol.",
    required_sections: ["What Is MCP?", "Jido as MCP Client", "Jido as MCP Server", "Protocol Lifecycle", "Error Handling"],
    must_include: ["Connecting to an MCP tool server from a Jido agent",
     "Exposing Jido actions as MCP-compatible tools",
     "Protocol handshake and session lifecycle",
     "Error handling and graceful degradation"],
    must_avoid: ["General tool-use concepts — link to the tool-use tutorial",
     "MCP protocol specification details — link to official MCP docs"],
    required_links: ["/docs/learn/tool-use", "/docs/learn/ai-chat-agent",
     "/docs/reference/packages/jido-ai"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 3,
    diagram_policy: "recommended",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Guide for integrating Jido agents with the Model Context Protocol (MCP) — both consuming external tools and exposing Jido actions.

Cover:
- Connecting to MCP tool servers as a client
- Exposing Jido actions as MCP tools
- Protocol lifecycle management
- Error handling and graceful degradation

### Validation Criteria

- Client and server integration patterns use current jido_ai MCP APIs
- Protocol lifecycle is accurately described
- Error handling covers connection, timeout, and malformed response cases
- Diagram shows MCP client/server communication flow
