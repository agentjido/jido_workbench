defmodule AgentJidoWeb.JidoSkillsLive do
  @moduledoc """
  Standalone catalog page for the vendored upstream Jido package skills.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.UpstreamSkillCatalog

  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Jido Skills Catalog",
       meta_description: "Browse the vendored upstream Jido package skills catalog, including package-focused skills and the router skill.",
       entries: UpstreamSkillCatalog.all_entries(),
       package_entries: UpstreamSkillCatalog.package_entries(),
       router_entries: UpstreamSkillCatalog.router_entries(),
       skills_root_source_path: UpstreamSkillCatalog.skills_root_source_path(),
       source_prompt_source_path: UpstreamSkillCatalog.source_prompt_source_path(),
       readme_source_path: UpstreamSkillCatalog.readme_source_path(),
       repo_url: UpstreamSkillCatalog.repo_url(),
       total_count: UpstreamSkillCatalog.count(),
       package_count: UpstreamSkillCatalog.package_count(),
       router_count: UpstreamSkillCatalog.router_count(),
       support_file_count: UpstreamSkillCatalog.support_file_count()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout
      current_path="/skills"
      current_scope={@current_scope}
      analytics_identity={@analytics_identity}
    >
      <div class="container max-w-[1040px] mx-auto px-6 py-12">
        <section class="mb-14">
          <div class="inline-block px-4 py-2 rounded mb-5 bg-primary/10 border border-primary/30">
            <span class="text-primary text-[11px] font-semibold tracking-widest uppercase">
              JIDO SKILLS CATALOG
            </span>
          </div>

          <h1 class="text-4xl font-bold mb-4 tracking-tight">
            Vendored package skills for the Jido ecosystem
          </h1>
          <p class="copy-measure-wide text-sm leading-relaxed text-secondary-foreground mb-8">
            This page lists the upstream package-oriented skills copied from <a
              href={@repo_url}
              target="_blank"
              rel="noopener noreferrer"
              class="text-primary hover:opacity-80 transition-opacity"
            >arrowcircle/jido-skills</a>.
            They complement the workbench-first builder skills we added in the runtime foundations demo by covering package boundaries directly.
          </p>

          <div class="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
            <div class="rounded-md border border-border bg-elevated p-4">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Total Skills</div>
              <div class="mt-2 text-2xl font-bold text-foreground">{@total_count}</div>
            </div>
            <div class="rounded-md border border-border bg-elevated p-4">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Package Skills</div>
              <div class="mt-2 text-2xl font-bold text-foreground">{@package_count}</div>
            </div>
            <div class="rounded-md border border-border bg-elevated p-4">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Router Skills</div>
              <div class="mt-2 text-2xl font-bold text-foreground">{@router_count}</div>
            </div>
            <div class="rounded-md border border-border bg-elevated p-4">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Support Files</div>
              <div class="mt-2 text-2xl font-bold text-foreground">{@support_file_count}</div>
            </div>
          </div>
        </section>

        <section class="grid gap-5 xl:grid-cols-[1.05fr_0.95fr] mb-14">
          <article class="rounded-lg border border-border bg-card p-6">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-3">How To Load The Catalog</div>
            <p class="text-sm text-secondary-foreground leading-relaxed mb-4">
              The copied skills live under a dedicated local root so they can be loaded without mixing them into the builder skill catalog.
            </p>
            <pre
              class="rounded-md border border-border bg-elevated p-4 text-[11px] whitespace-pre-wrap font-mono text-foreground"
              id="skills-load-snippet"
            ><%= "Jido.AI.Skill.Registry.load_from_paths([\"#{@skills_root_source_path}\"])" %></pre>
            <div class="mt-4 text-[11px] text-muted-foreground space-y-1">
              <div>local readme: {@readme_source_path}</div>
              <div>generation prompt: {@source_prompt_source_path}</div>
            </div>
          </article>

          <article class="rounded-lg border border-border bg-card p-6">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-3">How This Fits With The Existing Builder Skills</div>
            <div class="space-y-3 text-sm text-secondary-foreground leading-relaxed">
              <p>
                These upstream skills are package-first. They help Codex or other skill-aware runtimes anchor work to a specific Jido package such as `jido-action`, `req-llm`, or `jido-browser`.
              </p>
              <p>
                The workbench builder skills remain workflow-first. They focus on contributor jobs like scaffolding actions, authoring ecosystem pages, and outlining truthful examples.
              </p>
              <div class="flex flex-wrap gap-3 pt-2">
                <.link
                  navigate="/examples/jido-ai-skills-runtime-foundations?tab=demo"
                  class="text-xs font-semibold px-3 py-2 rounded border border-primary/30 bg-primary/10 text-primary hover:bg-primary/15 transition-colors"
                >
                  Open Builder Skills Demo
                </.link>
                <a
                  href={@repo_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-xs font-semibold px-3 py-2 rounded border border-border text-muted-foreground hover:text-foreground hover:border-foreground/40 transition-colors"
                >
                  View Upstream Repo
                </a>
              </div>
            </div>
          </article>
        </section>

        <section :if={@router_entries != []} class="mb-14">
          <div class="flex items-center justify-between mb-5">
            <span class="text-sm font-bold tracking-wider uppercase">Router Skill</span>
            <span class="text-[11px] text-muted-foreground">start here when package boundaries are unclear</span>
          </div>

          <%= for entry <- @router_entries do %>
            <article class="rounded-lg border border-primary/30 bg-primary/5 p-6">
              <div class="flex flex-wrap items-center gap-3 mb-3">
                <span class="text-[10px] uppercase tracking-wider text-primary font-semibold">Router</span>
                <span class="text-[10px] text-muted-foreground">{entry.name}</span>
              </div>
              <h2 class="text-2xl font-bold text-foreground mb-3">{entry.title}</h2>
              <p class="text-sm text-secondary-foreground leading-relaxed mb-5">{entry.description}</p>

              <div class="grid gap-4 md:grid-cols-3">
                <div class="rounded-md border border-border bg-background/70 p-4">
                  <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Source Path</div>
                  <div class="text-[11px] text-foreground break-all">{entry.skill_source_path}</div>
                </div>
                <div class="rounded-md border border-border bg-background/70 p-4">
                  <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Agent Files</div>
                  <div class="text-[11px] text-foreground">{length(entry.agent_files)}</div>
                </div>
                <div class="rounded-md border border-border bg-background/70 p-4">
                  <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Reference Files</div>
                  <div class="text-[11px] text-foreground">{length(entry.reference_files)}</div>
                </div>
              </div>

              <div class="mt-5 flex flex-wrap gap-3">
                <a
                  href={entry.upstream_url}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="text-xs font-semibold px-3 py-2 rounded border border-primary/30 bg-primary/10 text-primary hover:bg-primary/15 transition-colors"
                >
                  Open Upstream Skill
                </a>
              </div>
            </article>
          <% end %>
        </section>

        <section>
          <div class="flex items-center justify-between mb-5">
            <span class="text-sm font-bold tracking-wider uppercase">Package Skills</span>
            <span class="text-[11px] text-muted-foreground">package-first skills copied into the local workbench</span>
          </div>

          <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
            <%= for entry <- @package_entries do %>
              <article id={"skill-card-#{entry.id}"} class="rounded-lg border border-border bg-card p-5">
                <div class="flex items-center justify-between gap-3 mb-3">
                  <div>
                    <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Package Skill</div>
                    <h2 class="text-lg font-bold text-foreground">{entry.title}</h2>
                  </div>
                  <span class="text-[10px] font-mono text-muted-foreground bg-elevated px-2 py-1 rounded border border-border">
                    {entry.name}
                  </span>
                </div>

                <p class="text-sm text-secondary-foreground leading-relaxed mb-4">{entry.description}</p>

                <div class="space-y-2 text-[11px] text-muted-foreground mb-5">
                  <div>source: <span class="text-foreground break-all">{entry.skill_source_path}</span></div>
                  <div>agent files: <span class="text-foreground">{length(entry.agent_files)}</span></div>
                  <div>reference files: <span class="text-foreground">{length(entry.reference_files)}</span></div>
                </div>

                <div class="flex flex-wrap gap-2">
                  <a
                    href={entry.upstream_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="text-xs font-semibold px-3 py-2 rounded border border-accent-cyan/30 bg-accent-cyan/10 text-accent-cyan hover:bg-accent-cyan/15 transition-colors"
                  >
                    Upstream Skill
                  </a>
                  <.link
                    :if={entry.ecosystem_path}
                    navigate={entry.ecosystem_path}
                    class="text-xs font-semibold px-3 py-2 rounded border border-border text-muted-foreground hover:text-foreground hover:border-foreground/40 transition-colors"
                  >
                    Ecosystem Page
                  </.link>
                </div>
              </article>
            <% end %>
          </div>
        </section>
      </div>
    </.marketing_layout>
    """
  end
end
