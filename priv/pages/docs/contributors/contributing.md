%{
  title: "Contributing",
  description: "How to contribute to Jido, where to start, and how lightweight package stewardship works.",
  category: :docs,
  legacy_paths: [],
  tags: [:docs, :contributors, :contributing],
  order: 20,
  menu_label: "Contributing"
}
---

Jido welcomes contributions at many levels: code, docs, examples, testing, issue triage, and long-term stewardship. The goal is to make it easy to start small, contribute in public, and grow into more responsibility if that is a fit.

For conversation, onboarding, and general community entry, go to [/community](/community). This page covers contribution lanes and process expectations.

## Contribution Lanes

- Code contributions - package features, fixes, integrations, and refactors
- Documentation - docs fixes, tutorials, examples, onboarding material, and contributor docs
- Examples and testing - exercise packages in real workflows, validate releases, and report gaps
- Issue triage and feedback - bug reports, reproduction help, release feedback, and design discussion
- Community support - help connect people to the right package, guide, or repo

## Lightweight Contribution Flow

1. Pick a package, team, or problem you want to help with.
2. Open an issue, join a discussion, or send a pull request for normal contribution work.
3. Follow the shared standards in [Package Quality Standards](/docs/contributors/package-quality-standards). If the change touches logging, telemetry, sanitization, or public error contracts, also use [Observability and Error Reporting Standards](/docs/contributors/observability-and-error-reporting-standards). If the change is a runnable docs notebook or cookbook example, also use [Livebook Authoring Standards](/docs/contributors/livebook-authoring-standards).
4. If the change affects package positioning, ownership, or support claims, align it with the [Ecosystem Atlas](/docs/contributors/ecosystem-atlas), [Package Support Levels](/docs/contributors/package-support-levels), and [Roadmap](/docs/contributors/roadmap).
5. Hand off clearly if you stop, pause, or need someone else to pick up the work.

## How to Start Small

- fix a docs or example gap in a package you are already using
- reproduce and document a bug clearly
- test a beta package and report what broke or felt unclear
- improve onboarding, examples, or package cross-links

One-off contributions are valuable. There is no expectation that every contributor becomes a maintainer.

## Package Stewardship

Package stewardship is the highest-trust contribution path, but it is still meant to be lightweight. A repository owner or tech lead is expected to:

- review and respond to pull requests and issues
- keep package docs reasonably current
- keep the package aligned with ecosystem standards and direction
- stay reasonably responsive while they hold the role

If you want to take on ongoing stewardship, talk with Mike Hostetler or the current package lead. Ownership should be explicit, but it is not meant to be bureaucratic or permanent.

## What Jido Asks From Contributors

- communicate clearly about what you are working on
- follow ecosystem standards and package conventions
- be explicit about handoff, availability, or stepping away
- keep contribution scope understandable for the next person

## Next Steps

- [Community](/community) - join Discord and collaborate in public
- [Package Quality Standards](/docs/contributors/package-quality-standards) - use the package review and release bar
- [Observability and Error Reporting Standards](/docs/contributors/observability-and-error-reporting-standards) - use the canonical logging, telemetry, and error-contract policy
- [Livebook Authoring Standards](/docs/contributors/livebook-authoring-standards) - use the canonical runnable notebook format for docs examples
- [Governance and Team Structure](/docs/contributors/governance-and-team) - understand how ownership and decisions work
