%{
  priority: :critical,
  status: :outline,
  title: "Operations Docs Hub",
  repos: ["agent_jido", "jido"],
  tags: [:docs, :operations, :navigation, :hub_operations, :format_markdown, :wave_1],
  audience: :advanced,
  content_type: :guide,
  destination_collection: :pages,
  destination_route: "/docs/operations",
  ecosystem_packages: ["jido", "agent_jido"],
  learning_outcomes: ["Route teams to production readiness, security, and incident response docs",
   "Define an operations-first workflow from launch gates to recovery procedures"],
  order: 45,
  prerequisites: ["docs/reference", "training/production-readiness"],
  purpose: "Centralize production operations guidance for reliability, security, and incident response",
  related: ["docs/production-readiness-checklist", "docs/security-and-governance", "docs/incident-playbooks"]
}
---
## Content Brief

Operations is the production-facing docs hub. It should index readiness checks, security controls, and incident response runbooks.

### Validation Criteria

- Starts with what operations risk this hub addresses and when to use it.
- Links to readiness checklist, security controls, and incident playbooks.
- Includes next-step links into Build and Training.
