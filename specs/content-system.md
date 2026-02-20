# Content System Reference

Last updated: 2026-02-13
Purpose: Map the static content pipeline so AI agents and writers know where content goes, what shape it takes, and how it reaches the site.

## How content works

All site content lives as Markdown (`.md`) or Livebook (`.livemd`) files in `priv/`. At compile time, NimblePublisher reads each file, extracts an Elixir-map frontmatter block, validates it against a Zoi schema, and compiles the result into module attributes. The web layer reads these compiled structs to render pages.

Content flow: `priv/*.md` → NimblePublisher → Zoi schema validation → Elixir struct → module attribute → LiveView/controller → rendered page

Frontmatter format: Elixir map syntax (NOT YAML). Example:
```elixir
%{
  title: "My Page Title",
  tags: [:agents, :tutorial],
  status: :draft
}
---
Markdown body starts here.
```

## Content directories

### `priv/blog/`
- **Purpose:** Blog posts (announcements, tutorials, release notes, case studies)
- **Schema:** `AgentJido.Blog.Post` (`lib/agent_jido/blog/post.ex`)
- **Loader:** `AgentJido.Blog` (`lib/agent_jido/blog.ex`)
- **File naming:** `YYYY/MM-DD-slug.md` or `.livemd` (date derived from path)
- **Site route:** `/blog/:slug`
- **Current count:** 4 posts
- **Key frontmatter fields:**
  - `title` (required) — Post title
  - `author` (required) — Author name
  - `description` — Short summary
  - `tags` — List of tag strings
  - `post_type` — `:post | :announcement | :release | :tutorial | :case_study`
  - `audience` — `:general | :beginner | :intermediate | :advanced`
  - `validation` — Nested map: `repos`, `source_modules`, `source_files`, `ecosystem_packages`, `claims`, `evergreen`
  - `freshness` — Nested map: `stale_after_days`, `validation_status`
  - `seo` — Nested map: `canonical_url`, `og_title`, `og_description`, `og_image`, `keywords`, `noindex`
  - `quality` — Nested map: `reviewed_by`, `confidence`, `linted`
  - `livebook` — Nested map: `runnable`, `mix_deps`, `required_env_vars`
- **Computed fields:** `word_count`, `reading_time_minutes`, `freshness.content_hash`, `date`, `is_livebook`

### `priv/ecosystem/`
- **Purpose:** Package metadata and descriptions for every package in the Jido ecosystem
- **Schema:** `AgentJido.Ecosystem.Package` (`lib/agent_jido/ecosystem/package.ex`)
- **Loader:** `AgentJido.Ecosystem` (`lib/agent_jido/ecosystem.ex`)
- **File naming:** `package-name.md` (id derived from filename)
- **Site route:** `/ecosystem/:id`
- **Current count:** 19 packages
- **Key frontmatter fields:**
  - `name` (required) — Hex package name
  - `title` (required) — Display name
  - `version` — Current version string
  - `tagline` — One-line description
  - `description` — Longer description
  - `visibility` — `:public | :private`
  - `category` — `:core | :ai | :tools | :runtime | :integrations`
  - `tier` — Integer (1=core, 2=official, 3=community)
  - `hex_url`, `hexdocs_url`, `github_url` — External links
  - `ecosystem_deps` — List of ecosystem package id strings (used to build dependency graph)
  - `landing_summary`, `landing_cliff_notes`, `landing_important_packages`, `landing_major_components`, `landing_module_map` — Rich landing page content
  - `key_features` — Feature highlight list
  - `maturity` — Maturity tier: `:stable | :beta | :experimental | :planned`
  - `hex_status` — Hex.pm publication status (published version string or `"unreleased"`)
  - `api_stability` — API stability expectations (e.g., `"stable"`, `"unstable — expect breaking changes"`)
  - `limitations` — Known limitations or non-goals (list of strings)
  - `stub` — Whether the package is a stub vs real usable code (boolean)
  - `support` — Support expectations: `:best_effort | :community | :maintained`
- **Special behavior:** Loader builds a reverse dependency graph across all packages

### `priv/training/`
- **Purpose:** Structured training modules organized in curriculum tracks
- **Schema:** `AgentJido.Training.Module` (`lib/agent_jido/training/module.ex`)
- **Loader:** `AgentJido.Training` (`lib/agent_jido/training.ex`)
- **File naming:** `slug.md`
- **Site route:** `/training/:slug`
- **Current count:** 6 modules
- **Current modules:** agent-fundamentals, actions-validation, signals-routing, directives-scheduling, liveview-integration, production-readiness
- **Key frontmatter fields:**
  - `title` (required) — Module title
  - `description` — Short summary
  - `track` — `:foundations | :coordination | :integration | :operations`
  - `difficulty` — `:beginner | :intermediate | :advanced`
  - `duration_minutes` — Estimated time
  - `order` — Sort order in curriculum
  - `prerequisites` — List of prerequisite descriptions
  - `learning_outcomes` — List of outcome strings
  - `tags` — Tag list
- **Special behavior:** Loader builds prev/next neighbor navigation

### `priv/examples/`
- **Purpose:** Interactive examples with live demos and source code display
- **Schema:** `AgentJido.Examples.Example` (`lib/agent_jido/examples/example.ex`)
- **Loader:** `AgentJido.Examples` (`lib/agent_jido/examples.ex`)
- **File naming:** `slug.md`
- **Site route:** `/examples/:slug`
- **Current count:** 2 examples (counter-agent, demand-tracker-agent)
- **Key frontmatter fields:**
  - `title` (required) — Example title
  - `description` — Short summary
  - `category` — `:core | :ai | :production`
  - `emoji` — Display icon
  - `source_files` — List of repo-relative paths to source code files to embed
  - `live_view_module` (required) — Fully-qualified LiveView module for interactive demo
  - `difficulty` — `:beginner | :intermediate | :advanced`
  - `sort_order` — Sort position within category
  - `tags` — Tag list
- **Special behavior:** Source files listed in `source_files` are read and syntax-highlighted at compile time via Makeup

### `priv/documentation/`
- **Purpose:** Long-form docs, guides, and cookbook recipes (supports Livebook)
- **Schema:** `AgentJido.Documentation.Document` (`lib/agent_jido/documentation/document.ex`)
- **Loader:** `AgentJido.Documentation` (`lib/agent_jido/documentation.ex`)
- **File naming:** `category/slug.md` or `.livemd` (supports `index.md` for section roots)
- **Site routes:** `/docs/:slug` (for `:docs` category), `/cookbook/:slug` (for `:cookbook` category)
- **Current subdirectories:** `docs/`, `cookbook/`
- **Key frontmatter fields:**
  - `title` (required) — Document title
  - `category` (required) — Category atom (`:docs | :cookbook`)
  - `description` — Optional description
  - `order` — Sort order
  - `doc_type` — `:guide | :reference | :tutorial | :explanation | :cookbook`
  - `audience` — `:beginner | :intermediate | :advanced`
  - `draft` — Boolean, hides from listings
  - `in_menu` — Boolean, controls nav visibility
  - `menu_label` — Override title in nav
  - `tags` — Tag list
  - `related_docs`, `related_posts` — Cross-references
  - `validation` — Same nested structure as blog posts
  - `freshness` — Same nested structure as blog posts
  - `seo` — Same nested structure as blog posts
  - `quality` — Nested map with `examples_present` and `tested_examples` booleans
  - `livebook` — Nested map with `runnable`, `requires_network`, etc.
- **Computed fields:** `word_count`, `reading_time_minutes`, `content_hash`, `github_url`, `livebook_url`, `menu_path`
- **Special behavior:** Uses custom `LivebookParser` for `.livemd` files; builds hierarchical menu tree

### `priv/content_plan/`
- **Purpose:** Editorial briefs and specifications for planned content (not rendered on the site)
- **Schema:** `AgentJido.ContentPlan.Entry` (`lib/agent_jido/content_plan/entry.ex`)
- **Loader:** `AgentJido.ContentPlan` (`lib/agent_jido/content_plan.ex`)
- **File naming:** `section/slug.md` (section derived from folder name)
- **Special files:** `_section.md` in each folder defines section metadata
- **Current sections:** build, community, docs, ecosystem, features, training
- **Not rendered on site** — used for internal tracking and AI validation
- **Key frontmatter fields:**
  - `title` (required) — Page title
  - `purpose` — What this content achieves for the reader
  - `audience` — `:beginner | :intermediate | :advanced`
  - `content_type` — `:tutorial | :guide | :reference | :explanation`
  - `learning_outcomes` — List of outcome strings
  - `repos` — List of ecosystem repo ids
  - `source_modules` — List of module name strings content must cover
  - `source_files` — List of repo-relative file paths to cross-reference
  - `status` — `:planned | :outline | :draft | :review | :published`
  - `priority` — `:critical | :high | :medium | :low`
  - `prerequisites` — List of prerequisite entry slugs
  - `related` — List of related entry slugs
  - `ecosystem_packages` — List of package ids
  - `destination_route` — Target URL path (e.g., `"/features/reliability-by-architecture"`)
  - `destination_collection` — Target priv/ collection atom (e.g., `:pages`, `:training`, `:ecosystem`)
  - `tags` — Tag list
- **API:** `all_entries/0`, `entries_by_section/1`, `entries_by_status/1`, `entries_by_repo/1`, `coverage_report/0`, `table_of_contents/0`

## Content → route mapping

| priv/ directory | Site section | Route pattern | Rendered? |
|---|---|---|---|
| `priv/blog/` | Blog | `/blog/:slug` | ✅ |
| `priv/ecosystem/` | Ecosystem | `/ecosystem/:id` | ✅ |
| `priv/training/` | Training | `/training/:slug` | ✅ |
| `priv/examples/` | Examples | `/examples/:slug` | ✅ |
| `priv/documentation/docs/` | Docs | `/docs/:slug` | ✅ |
| `priv/documentation/cookbook/` | Cookbook | `/cookbook/:slug` | ✅ |
| `priv/content_plan/` | (internal) | Not rendered | ❌ |

### Outline sections with NO rendering pipeline yet

These sections are defined in `content-outline.md` but have no `priv/` content directory, no NimblePublisher loader, and no routes:

| Outline section | Needs | Status |
|---|---|---|
| Features sub-pages (`/features/:slug`) | Content directory + loader + routes | ❌ Not started |
| Build (`/build`, `/build/:slug`) | Content directory + loader + routes | ❌ Not started |
| Community (`/community`, `/community/:slug`) | Content directory + loader + routes | ❌ Not started |
| Ecosystem package-matrix (`/ecosystem/package-matrix`) | Static page or content file + route | ❌ Not started |

See `specs/TODO.md` for the implementation tasks.

### Docs pages defined in outline but missing from `priv/documentation/docs/`

Currently only `index.md` and `getting-started.livemd` exist. The outline requires:

- `/docs/core-concepts`
- `/docs/guides`
- `/docs/reference`
- `/docs/architecture`
- `/docs/production-readiness-checklist`
- `/docs/security-and-governance`
- `/docs/incident-playbooks`

These can use the existing documentation pipeline once content files are added to `priv/documentation/docs/`.

## How specs/ relates to priv/

The `specs/` folder contains **strategy, constraints, and specifications** that govern what goes into `priv/`.

| specs/ doc | Governs |
|---|---|
| `positioning.md` | Messaging claims, pillars, and narrative constraints for all content |
| `content-outline.md` | Information architecture — what pages exist and how they connect |
| `persona-journeys.md` | Who reads what, in what order, and why |
| `style-voice.md` | How content sounds and mechanical conventions for consistency |
| `content-governance.md` | Validation rules and publishing gates |
| `proof.md` | Evidence inventory — what proof assets exist and what's missing |
| `templates/` | Page scaffolds for each content type |
| `docs-manifesto.md` | Writing principles and documentation quality standards |

Think of it as: **specs/ is the spec, priv/ is the implementation.**

## Content plan as intermediate stage

The `priv/content_plan/` directory is the **intermediate staging area** between strategy (specs/) and published content (priv/). The pipeline is:

```
specs/content-outline.md  →  priv/content_plan/**/*.md  →  priv/{blog,documentation,training,...}/*.md
       (what pages exist)          (editorial briefs)              (published content)
```

Content plan briefs define *what* a page should contain, link to source code for validation, and track workflow status. Once a brief reaches `status: :published`, the actual content file should exist in the appropriate `priv/` content directory.

### Content plan → outline alignment

The content plan has 6 sections matching the outline's 6 top-level sections: `build`, `community`, `docs`, `ecosystem`, `features`, `training`.

Previously existing `why/`, `operate/`, and `reference/` sections have been reconciled:
- `why/` briefs moved to `features/` (these are features sub-pages in the outline)
- `operate/` briefs moved to `docs/` (these are docs pages in the outline)
- `reference/` briefs moved to `docs/` (these are docs pages in the outline)

All slug mismatches have been resolved. Each entry now includes `destination_route` and `destination_collection` fields for programmatic outline-to-brief-to-content validation.

## For AI agents

When generating or validating content:
1. Check `specs/style-voice.md` for tone, terminology, and mechanical conventions
2. Check `specs/content-outline.md` for where the content fits in the IA
3. Check `specs/templates/` for the structural template for this page type
4. Use the frontmatter schema from the relevant schema module — all fields with descriptions
5. Cross-reference `priv/ecosystem/*.md` for package claims and dependencies
6. Check `priv/content_plan/` for the editorial brief if one exists
7. Validate against `specs/content-governance.md` §10 before publishing
8. Use `specs/proof.md` to verify claims have backing evidence
