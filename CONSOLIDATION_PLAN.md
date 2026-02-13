# Content Pipeline Consolidation Plan

> **Purpose:** Replace 4 separate "markdown → rendered page" pipelines with one unified `Pages` system, then use it to ship the 3 missing outline sections (Features sub-pages, Build, Community) for free.
>
> **Delete this file when done.**

---

## Problem

We have 4 NimblePublisher pipelines that do the same thing — compile markdown, validate frontmatter, render HTML:

| Pipeline | Schema module | Loader module | priv/ dir | Unique behavior |
|---|---|---|---|---|
| Documentation | `Documentation.Document` | `Documentation` | `priv/documentation/docs/` | Menu tree, livebook parser, breadcrumbs |
| Training | `Training.Module` | `Training` | `priv/training/` | Track grouping, prev/next nav |
| Examples | `Examples.Example` | `Examples` | `priv/examples/` | `live_view_module`, compile-time source embedding |
| Blog | `Blog.Post` | `Blog` | `priv/blog/` | Date-from-path, RSS feed, tag search |

**Documentation is already the superset schema** — it has `category`, `doc_type`, `audience`, `validation`, `freshness`, `seo`, `quality`, `livebook`, menu hierarchy, draft/visibility, word count, reading time, related docs/posts, and cross-references.

Training.Module's fields (`track`, `difficulty`, `duration_minutes`, `order`, `prerequisites`, `learning_outcomes`) are a subset that could be optional fields on Document.

The outline requires 3 new sections (Features sub-pages, Build, Community). Without consolidation, that's 3 more schemas, 3 more loaders, 3 more LiveViews — all doing the same thing.

## What stays separate

- **Blog** — genuinely different: date derived from path (`YYYY/MM-DD-slug.md`), RSS feed, `post_type`, `author` field, `BlogController` (not LiveView). Keep as-is.
- **Examples** — genuinely different: `live_view_module` boots an interactive demo, `source_files` are read and syntax-highlighted at compile time. Not just a page. Keep as-is.
- **Ecosystem** — structured package metadata with reverse dependency graph, hex/github links, not prose pages. Keep as-is.
- **Content Plan** — internal briefs, not rendered. Keep as-is.

## What gets consolidated

Documentation + Training + (new) Features + (new) Build + (new) Community → **one `Pages` pipeline**.

### Before

```
priv/documentation/docs/*.md       → Documentation loader → JidoDocsLive
priv/training/*.md                  → Training loader     → JidoTrainingModuleLive
                                                            (no features sub-pages)
                                                            (no build pages)
                                                            (no community pages)
```

### After

```
priv/pages/docs/*.{md,livemd}      → Pages loader → PageLive (docs layout)
priv/pages/training/*.md            → Pages loader → PageLive (training layout)
priv/pages/features/*.md            → Pages loader → PageLive (marketing layout)
priv/pages/build/*.md               → Pages loader → PageLive (marketing layout)
priv/pages/community/*.md           → Pages loader → PageLive (marketing layout)
```

One loader. One schema. Layout selected by `category`.

---

## Step-by-step

### Phase 1: Create the unified Page schema

**New file:** `lib/agent_jido/pages/page.ex`

Take `Documentation.Document` as the base and add the training-specific fields as optional:

```elixir
# Fields carried over from Document (all kept):
# id, title, description, category, tags, order, body, path, source_path,
# is_livebook, github_url, livebook_url, menu_path, draft, in_menu, menu_label,
# doc_type, audience, word_count, reading_time_minutes, related_docs, related_posts,
# validation, freshness, seo, quality, livebook

# Fields added from Training.Module:
track:              Zoi.atom() |> Zoi.optional()    # :foundations | :coordination | :integration | :operations
difficulty:         Zoi.atom() |> Zoi.optional()    # :beginner | :intermediate | :advanced
duration_minutes:   Zoi.integer() |> Zoi.optional()
prerequisites:      Zoi.any() |> Zoi.default([])    # list of prerequisite descriptions
learning_outcomes:  Zoi.any() |> Zoi.default([])    # list of outcome strings

# Category values expanded:
# :docs | :training | :features | :build | :community
```

The `build/3` callback stays essentially the same as `Document.build/3` — derive id from path, compute word count, hash content, detect livebook. The only change is expanding the `category` derivation to handle the new subdirectories.

### Phase 2: Create the unified Pages loader

**New file:** `lib/agent_jido/pages.ex`

```elixir
defmodule AgentJido.Pages do
  use NimblePublisher,
    build: AgentJido.Pages.Page,
    from: Application.app_dir(:agent_jido, "priv/pages/**/*.{md,livemd}"),
    as: :pages,
    highlighters: [:makeup_elixir, :makeup_js, :makeup_html],
    parser: AgentJido.Documentation.LivebookParser  # reuse existing

  # Pre-built indexes (same pattern as Documentation + Training):
  # @pages_by_id, @pages_by_path, @pages_by_category, @pages_by_tag
  # @categories, @tags

  # API surface — union of Documentation + Training:
  # all_pages/0, get_page!/1, pages_by_category/1, pages_by_tag/1
  # menu_tree/0, menu_tree/1 (per-category)
  # neighbors/1 (prev/next within same category, ordered)
  # breadcrumbs/1
end
```

Keep `MenuNode` as-is — it's generic enough. Just move or alias it under `Pages`.

### Phase 3: Move content files

```bash
# Docs — flatten the unnecessary nesting
mv priv/documentation/docs/*    priv/pages/docs/

# Training
mv priv/training/*              priv/pages/training/

# Cookbook → absorb into docs (any livebook content worth keeping moves to priv/pages/docs/)
# Anything duplicated by examples can be deleted outright
mv priv/documentation/cookbook/*.livemd  priv/pages/docs/   # review each; delete dupes

# Create new empty directories for outline sections
mkdir -p priv/pages/features
mkdir -p priv/pages/build
mkdir -p priv/pages/community
```

Existing frontmatter for docs files already has `category: :docs`. Cookbook files being absorbed need their `category` changed from `:cookbook` to `:docs`. Training files need `category: :training` added to their frontmatter.

### Phase 4: Update routing

Replace the compile-time doc route generation and static training routes with a single pattern.

**Router changes:**

```elixir
# Remove:
live "/training", JidoTrainingLive, :index
live "/training/:slug", JidoTrainingModuleLive, :show
# Remove: @doc_routes compile-time block
# Remove: LivebookDemoLive routes

# Add — compile-time routes from Pages, grouped by category:
for page <- AgentJido.Pages.all_pages() do
  route_path = AgentJido.Pages.route_for(page)
  live route_path, AgentJidoWeb.PageLive, :show, metadata: %{category: page.category}
end

# Keep explicit index routes for each section:
live "/docs", PageLive, :index, metadata: %{category: :docs}
live "/training", PageLive, :index, metadata: %{category: :training}
live "/features", JidoFeaturesLive, :index  # keep existing — it's a custom marketing page
live "/build", PageLive, :index, metadata: %{category: :build}
live "/community", PageLive, :index, metadata: %{category: :community}
```

Route derivation logic (in `Pages`):

```elixir
def route_for(%Page{category: :docs, path: path}), do: "/docs/#{path_suffix(path)}"
def route_for(%Page{category: :training} = p), do: "/training/#{p.id}"
def route_for(%Page{category: :features} = p), do: "/features/#{p.id}"
def route_for(%Page{category: :build} = p), do: "/build/#{p.id}"
def route_for(%Page{category: :community} = p), do: "/community/#{p.id}"
```

### Phase 5: Create PageLive

**New file:** `lib/agent_jido_web/live/page_live.ex`

One LiveView that dispatches to the right layout based on category:

```elixir
defmodule AgentJidoWeb.PageLive do
  use AgentJidoWeb, :live_view

  def handle_params(params, uri, socket) do
    category = socket.assigns.live_action_metadata.category  # from route metadata
    # ... fetch page, build TOC, assign

    {:noreply, assign(socket, page: page, category: category, toc: toc, layout_type: layout_for(category))}
  end

  # Docs get sidebar + TOC layout
  defp layout_for(:docs), do: :docs_shell
  # Training gets marketing layout with prev/next + metadata badges
  defp layout_for(:training), do: :training_shell
  # Features/build/community get marketing layout
  defp layout_for(:features), do: :marketing_shell
  defp layout_for(:build), do: :marketing_shell
  defp layout_for(:community), do: :marketing_shell
end
```

The template switches on `@layout_type` to render the appropriate shell. The shells are already built — `DocsComponents` for the sidebar layout, `MarketingLayouts` for the centered layout. The training metadata badges (track, difficulty, duration) render conditionally when those fields are present.

### Phase 6: Update consumers

These files reference the old modules and need updating:

| File | Currently references | Change to |
|---|---|---|
| `router.ex` | `AgentJido.Documentation` | `AgentJido.Pages` |
| `jido_docs_live.ex` | `AgentJido.Documentation` | Delete (replaced by PageLive) |
| `jido_docs_live.html.heex` | — | Delete (absorbed into PageLive template) |
| `livebook_demo_live.ex` | `AgentJido.Documentation` | Delete (cookbook removed; livebook docs absorbed into PageLive) |
| `livebook_demo_live.html.heex` | — | Delete |
| `jido_training_live.ex` | `AgentJido.Training` | Keep as index, but query `Pages.pages_by_category(:training)` |
| `jido_training_module_live.ex` | `AgentJido.Training` | Delete (replaced by PageLive) |
| `sitemap_controller.ex` | `AgentJido.Documentation`, `AgentJido.Training` | `AgentJido.Pages` |
| `og_image_controller.ex` | — | Remove `/og/cookbook.png` route |

### Phase 7: Deprecate old modules

After PageLive is working:

1. Delete `lib/agent_jido/documentation/document.ex`
2. Delete `lib/agent_jido/documentation.ex`
3. Delete `lib/agent_jido/documentation/menu_node.ex` (or move to `lib/agent_jido/pages/menu_node.ex`)
4. Delete `lib/agent_jido/documentation/livebook_parser.ex` (or move to `lib/agent_jido/pages/`)
5. Delete `lib/agent_jido/training/module.ex`
6. Delete `lib/agent_jido/training.ex`
7. Delete `priv/documentation/` (empty after move — cookbook content absorbed into docs or deleted)
8. Delete `priv/training/` (empty after move)
9. Update tests in `test/agent_jido/documentation_test.exs` → `test/agent_jido/pages_test.exs`
10. Update tests in `test/agent_jido/training_test.exs` → merge into pages_test
11. Update `test/agent_jido_web/live/jido_training_*_test.exs`

### Phase 8: Add outline content stubs

With the pipeline in place, adding the missing outline pages is just creating markdown files:

```bash
# Features sub-pages
touch priv/pages/features/reliability-by-architecture.md
touch priv/pages/features/multi-agent-coordination.md
touch priv/pages/features/operations-observability.md
touch priv/pages/features/incremental-adoption.md
touch priv/pages/features/beam-for-ai-builders.md
touch priv/pages/features/jido-vs-framework-first-stacks.md
touch priv/pages/features/executive-brief.md

# Build pages
touch priv/pages/build/index.md
touch priv/pages/build/quickstarts-by-persona.md
touch priv/pages/build/reference-architectures.md
touch priv/pages/build/mixed-stack-integration.md
touch priv/pages/build/product-feature-blueprints.md

# Community pages
touch priv/pages/community/index.md
touch priv/pages/community/learning-paths.md
touch priv/pages/community/adoption-playbooks.md
touch priv/pages/community/case-studies.md

# Missing docs pages (already have a pipeline, just need files)
touch priv/pages/docs/core-concepts.md
touch priv/pages/docs/guides.md
touch priv/pages/docs/reference.md
touch priv/pages/docs/architecture.md
touch priv/pages/docs/production-readiness-checklist.md
touch priv/pages/docs/security-and-governance.md
touch priv/pages/docs/incident-playbooks.md
```

Each file gets minimal frontmatter + a placeholder body:

```elixir
%{
  title: "Reliability by Architecture",
  category: :features,
  description: "How Jido's OTP foundation provides fault isolation, supervision, and recovery by default.",
  doc_type: :explanation,
  audience: :intermediate,
  draft: true,
  order: 10
}
---
Content coming soon.
```

---

## Execution order

| Step | Phase | Effort | Can break existing? |
|---|---|---|---|
| 1 | Create `Pages.Page` schema | S | No — additive |
| 2 | Create `Pages` loader | S | No — additive |
| 3 | Move `priv/` content files | S | **Yes** — old loaders break |
| 4 | Update router | M | **Yes** — routes change |
| 5 | Create `PageLive` | M | No — additive |
| 6 | Wire PageLive into router, delete old LiveViews | M | **Yes** — swap |
| 7 | Delete old modules + update tests | S | Cleanup |
| 8 | Add content stubs | S | No — additive |

**Steps 1-2** can be done safely alongside existing code (both systems run in parallel).
**Steps 3-6** are the cutover — do them together in one commit.
**Steps 7-8** are cleanup and payoff.

Total effort: ~1 day.

## Verification

After each phase:

```bash
mix compile --warnings-as-errors
mix test
mix phx.server  # manual smoke test: /docs, /training, /training/:slug
```

After full cutover, verify:
- [ ] `/docs` index renders with sidebar
- [ ] `/docs/getting-started` renders with sidebar + TOC (livebook)
- [ ] `/training` index renders track grouping
- [ ] `/training/:slug` renders with prev/next nav + metadata badges
- [ ] `/features/:slug` renders (new, stub content)
- [ ] `/build` index renders (new, stub content)
- [ ] `/community` index renders (new, stub content)
- [ ] `/blog/*` still works (untouched)
- [ ] `/examples/*` still works (untouched)
- [ ] `/ecosystem/*` still works (untouched)
- [ ] `/sitemap.xml` includes all page routes
- [ ] `mix test` passes

## What this unblocks

- **3 new outline sections** ship immediately as empty stubs with working routes
- **Adding any future section** = `mkdir priv/pages/foo/` + add a category mapping — no new schema, loader, or LiveView
- **content-system.md** simplifies dramatically — one pipeline to document instead of 4
- **Content plan briefs** get a clear destination: `category` field maps 1:1 to `priv/pages/{category}/`
