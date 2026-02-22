%{
  priority: :high,
  status: :planned,
  title: "Backup and Disaster Recovery",
  repos: ["jido", "jido_memory"],
  tags: [:docs, :operations, :backup, :disaster_recovery, :reliability],
  audience: :advanced,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/operations/backup-and-disaster-recovery",
  ecosystem_packages: ["jido", "jido_memory"],
  learning_outcomes: ["Identify critical agent data that requires backup",
   "Implement backup strategies for agent state, conversation history, and vector embeddings",
   "Design and test disaster recovery procedures with defined RTO/RPO targets"],
  order: 40,
  prerequisites: ["docs/operations/production-readiness-checklist", "docs/guides/persistence-memory-and-vector-search"],
  purpose: "Guide for backing up agent state, conversation history, and vector embeddings with disaster recovery procedures",
  related: ["docs/operations/production-readiness-checklist",
   "docs/guides/persistence-memory-and-vector-search"],
  prompt_overrides: %{
    document_intent: "Write a backup and disaster recovery guide for Jido agent systems covering state, memory, and vector data.",
    required_sections: ["What to Back Up", "Backup Strategies", "Recovery Procedures", "RTO/RPO Planning", "Testing Recovery"],
    must_include: ["Agent state and conversation history backup approaches",
     "Vector embedding export and restore with jido_memory",
     "Point-in-time recovery procedures",
     "Recovery testing checklist and schedule"],
    must_avoid: ["General database backup tutorials — focus on agent-specific concerns",
     "Infrastructure provisioning — assume reader has backup infrastructure"],
    required_links: ["/docs/operations/production-readiness-checklist",
     "/docs/guides/persistence-memory-and-vector-search"],
    min_words: 600,
    max_words: 1_200,
    minimum_code_blocks: 2,
    diagram_policy: "none",
    section_density: "light_technical",
    max_paragraph_sentences: 3
  }
}
---
## Content Brief

Guide for backing up and recovering Jido agent data. Covers agent state, conversation history, and vector embeddings with disaster recovery procedures and RTO/RPO planning.

Cover:
- Identifying critical agent data for backup (state, history, embeddings)
- Backup strategies for agent state and jido_memory vector data
- Point-in-time recovery procedures
- RTO/RPO target planning and recovery testing

### Validation Criteria

- Backup targets cover all agent-specific data types including vector embeddings
- Recovery procedures are step-by-step and testable
- RTO/RPO guidance helps teams set realistic recovery targets
- Testing checklist ensures recovery procedures are validated regularly
