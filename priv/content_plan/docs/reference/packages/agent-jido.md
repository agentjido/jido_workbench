%{
  priority: :high,
  status: :outline,
  title: "Package Reference: agent_jido",
  repos: ["agent_jido"],
  tags: [:docs, :reference, :packages, :agent_jido, :phoenix, :liveview, :workbench],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/packages/agent-jido",
  ecosystem_packages: ["agent_jido"],
  learning_outcomes: [
    "Understand the purpose of the agent_jido workbench application",
    "Know how to set up and run the application locally",
    "Identify key modules and architecture patterns",
    "Understand how the workbench showcases Jido framework capabilities"
  ],
  order: 80,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Provide a comprehensive reference for the agent_jido workbench application — the Phoenix LiveView showcase for the Jido framework.",
  related: [
    "docs/learn/liveview-integration",
    "docs/reference/packages/jido"
  ],
  source_modules: ["AgentJido"],
  prompt_overrides: %{
    document_intent: "Reference documentation for the agent_jido package — the workbench/showcase Phoenix LiveView application demonstrating Jido framework capabilities.",
    required_sections: ["Overview", "Installation", "Key Modules", "Configuration", "Usage Examples"],
    must_include: [
      "Package purpose as the Jido workbench and showcase application",
      "Setup and installation instructions for local development",
      "Summary of key application modules and architecture",
      "Configuration options for environment and deployment",
      "Usage examples showing LiveView integration patterns"
    ],
    must_avoid: [
      "Tutorial walkthroughs — link to Learn section",
      "Duplicating HexDocs content"
    ],
    required_links: [
      "GitHub repository",
      "docs/learn/liveview-integration",
      "Live demo site"
    ],
    min_words: 600,
    max_words: 1200,
    minimum_code_blocks: 2,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Reference for the `agent_jido` package — the workbench/showcase Phoenix LiveView application for the Jido framework. Covers the application's purpose as a demonstration platform, local setup instructions, key architectural modules, configuration options, and how LiveView integrates with the Jido agent framework. This serves as both a reference implementation and a living demo of Jido capabilities.

### Validation Criteria

- Clearly explains the package's role as the workbench/showcase application
- Includes setup and installation instructions for local development
- Documents key application modules and their architecture
- Lists configuration options for development and deployment
- Provides at least 2 code examples showing LiveView integration patterns
- Links to the LiveView integration tutorial
- Does not duplicate full API docs from HexDocs
