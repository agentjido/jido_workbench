%{
  priority: :high,
  status: :outline,
  title: "Package Reference: jido_browser",
  repos: ["jido_browser"],
  tags: [:docs, :reference, :packages, :jido_browser, :browser, :automation, :web],
  audience: :intermediate,
  content_type: :reference,
  destination_collection: :pages,
  destination_route: "/docs/reference/packages/jido-browser",
  ecosystem_packages: ["jido_browser"],
  learning_outcomes: [
    "Understand the purpose of the jido_browser package",
    "Know how to install and configure jido_browser",
    "Identify key modules for browser automation",
    "Understand how browser actions integrate with agents"
  ],
  order: 70,
  prerequisites: ["docs/concepts/key-concepts"],
  purpose: "Provide a comprehensive reference for the jido_browser package covering browser automation for web agents.",
  related: [
    "docs/learn/tool-use",
    "docs/reference/packages/jido"
  ],
  source_modules: ["Jido.Browser"],
  prompt_overrides: %{
    document_intent: "Reference documentation for the jido_browser package — browser automation capabilities for building web-interacting agents.",
    required_sections: ["Overview", "Installation", "Key Modules", "Configuration", "Usage Examples"],
    must_include: [
      "Package purpose and role in the Jido ecosystem",
      "Mix dependency installation snippet including system dependencies",
      "Summary of browser automation modules and actions",
      "Configuration options for browser instances and timeouts",
      "Usage examples showing browser navigation and interaction"
    ],
    must_avoid: [
      "Tutorial walkthroughs — link to Learn section",
      "Duplicating HexDocs content"
    ],
    required_links: [
      "HexDocs for jido_browser",
      "GitHub repository",
      "docs/learn/tool-use"
    ],
    min_words: 600,
    max_words: 1200,
    minimum_code_blocks: 3,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Reference for the `jido_browser` package — browser automation capabilities for web-interacting agents in the Jido ecosystem. Covers installation (including system dependencies), browser actions for navigation and interaction, configuration options, and how browser automation integrates with the agent framework. This package enables agents to browse, scrape, and interact with web pages.

### Validation Criteria

- Clearly explains the package's role in enabling browser automation for agents
- Includes a working Mix dependency installation snippet with system dependency notes
- Documents key modules for browser control and web interaction
- Lists configuration options for browser instances
- Provides at least 3 code examples showing browser automation
- Links to the tool use tutorial
- Does not duplicate full API docs from HexDocs
