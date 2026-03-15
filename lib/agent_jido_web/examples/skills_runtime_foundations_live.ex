defmodule AgentJidoWeb.Examples.SkillsRuntimeFoundationsLive do
  @moduledoc """
  Interactive skills runtime foundations demo backed by real module and SKILL.md fixtures.
  """

  use AgentJidoWeb, :live_view

  alias AgentJido.Demos.SkillsRuntimeFoundations.RuntimeDemo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_demo(socket, RuntimeDemo.new())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="skills-runtime-foundations-demo" class="rounded-lg border border-border bg-card p-6 space-y-6">
      <div class="flex items-center justify-between gap-4">
        <div>
          <div class="text-sm font-semibold text-foreground">Jido.AI Skills Runtime Foundations</div>
          <div class="text-[11px] text-muted-foreground">
            Real manifest loading, registry population, and prompt rendering with checked-in `SKILL.md` files
          </div>
        </div>
        <div class="text-[10px] font-mono text-muted-foreground bg-elevated px-2 py-1 rounded border border-border">
          registry: {@registry_count} skill(s)
        </div>
      </div>

      <div class="grid gap-3 sm:grid-cols-3 xl:grid-cols-6">
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">File Manifest</div>
          <div class="text-sm font-semibold text-foreground mt-2">
            {if @demo.file_manifest, do: "loaded", else: "pending"}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Module Skill</div>
          <div class="text-sm font-semibold text-foreground mt-2">
            {if @demo.module_manifest, do: "registered", else: "pending"}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Allowed Tools</div>
          <div class="text-sm font-semibold text-foreground mt-2">{length(@demo.allowed_tools)}</div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Prompt Ready</div>
          <div class="text-sm font-semibold text-foreground mt-2">
            {if @demo.prompt != "", do: "yes", else: "no"}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Builder Catalog</div>
          <div class="text-sm font-semibold text-foreground mt-2">
            {if @demo.builder_specs == [], do: "pending", else: "#{length(@demo.builder_specs)} loaded"}
          </div>
        </div>
        <div class="rounded-md border border-border bg-elevated p-3 text-center">
          <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Builder Workflow</div>
          <div class="text-sm font-semibold text-foreground mt-2">
            {if @demo.builder_workflow_steps == [], do: "pending", else: "ready"}
          </div>
        </div>
      </div>

      <div class="flex gap-3 flex-wrap">
        <button
          id="skills-load-file-btn"
          phx-click="load_file_manifest"
          class="px-4 py-2 rounded-md bg-primary/10 border border-primary/30 text-primary hover:bg-primary/20 transition-colors text-sm font-semibold"
        >
          Load File Manifest
        </button>
        <button
          id="skills-register-module-btn"
          phx-click="register_module_skill"
          class="px-4 py-2 rounded-md bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 hover:bg-emerald-500/20 transition-colors text-sm font-semibold"
        >
          Register Module Skill
        </button>
        <button
          id="skills-load-registry-btn"
          phx-click="load_runtime_skills"
          class="px-4 py-2 rounded-md bg-accent-cyan/10 border border-accent-cyan/30 text-accent-cyan hover:bg-accent-cyan/20 transition-colors text-sm font-semibold"
        >
          Load Runtime Directory
        </button>
        <button
          id="skills-load-builder-btn"
          phx-click="load_builder_catalog"
          class="px-4 py-2 rounded-md bg-fuchsia-500/10 border border-fuchsia-500/30 text-fuchsia-200 hover:bg-fuchsia-500/20 transition-colors text-sm font-semibold"
        >
          Load Builder Catalog
        </button>
        <button
          id="skills-render-prompt-btn"
          phx-click="render_prompt"
          class="px-4 py-2 rounded-md bg-amber-500/10 border border-amber-500/30 text-amber-300 hover:bg-amber-500/20 transition-colors text-sm font-semibold"
        >
          Render Prompt
        </button>
        <button
          id="skills-run-builder-btn"
          phx-click="run_builder_workflow"
          class="px-4 py-2 rounded-md bg-indigo-500/10 border border-indigo-500/30 text-indigo-200 hover:bg-indigo-500/20 transition-colors text-sm font-semibold"
        >
          Run Builder Workflow
        </button>
        <button
          id="skills-reset-btn"
          phx-click="reset_demo"
          class="px-3 py-2 rounded-md bg-elevated border border-border text-muted-foreground hover:text-foreground hover:border-primary/40 transition-colors text-xs"
        >
          Reset
        </button>
      </div>

      <div class="grid gap-4 xl:grid-cols-[1.1fr_0.9fr]">
        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">File-Backed Manifest</div>

            <div :if={is_nil(@demo.file_manifest)} class="text-xs text-muted-foreground">
              No file manifest loaded yet.
            </div>

            <div :if={@demo.file_manifest} id="skills-file-manifest" class="space-y-2 text-[11px] text-foreground">
              <div><span class="font-semibold">name:</span> {@demo.file_manifest.name}</div>
              <div><span class="font-semibold">path:</span> {@demo.primary_skill_source_path}</div>
              <div><span class="font-semibold">description:</span> {@demo.file_manifest.description}</div>
              <div>
                <span class="font-semibold">allowed tools:</span>
                {Enum.join(@demo.file_manifest.allowed_tools, ", ")}
              </div>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Module Skill Manifest</div>

            <div :if={is_nil(@demo.module_manifest)} class="text-xs text-muted-foreground">
              No module skill registered yet.
            </div>

            <div :if={@demo.module_manifest} id="skills-module-manifest" class="space-y-2 text-[11px] text-foreground">
              <div><span class="font-semibold">name:</span> {@demo.module_manifest.name}</div>
              <div><span class="font-semibold">module:</span> {inspect(elem(@demo.module_manifest.source, 1))}</div>
              <div><span class="font-semibold">description:</span> {@demo.module_manifest.description}</div>
              <div>
                <span class="font-semibold">allowed tools:</span>
                {Enum.join(@demo.module_manifest.allowed_tools, ", ")}
              </div>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Registry Contents</div>
              <div id="skills-registry-count" class="text-[10px] text-muted-foreground">
                {@registry_count} skill(s)
              </div>
            </div>

            <div :if={@demo.registry_specs == []} class="text-xs text-muted-foreground">
              Register the module skill or load the runtime directory to populate the registry.
            </div>

            <div :if={@demo.registry_specs != []} id="skills-registry-list" class="space-y-2">
              <%= for spec <- @demo.registry_specs do %>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="text-xs font-semibold text-foreground">{spec.name}</div>
                  <div class="text-[11px] text-muted-foreground mt-1">{spec.description}</div>
                  <div class="text-[11px] text-muted-foreground mt-2">
                    source: {render_source(spec.source)}
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Builder Skill Catalog</div>
              <div id="skills-builder-count" class="text-[10px] text-muted-foreground">
                {@demo.builder_loaded_count} file skill(s) loaded
              </div>
            </div>

            <div :if={@demo.builder_specs == []} class="text-xs text-muted-foreground">
              Load the builder catalog to inspect the checked-in workbench contributor skills.
            </div>

            <div :if={@demo.builder_specs != []} id="skills-builder-list" class="space-y-2">
              <%= for spec <- @demo.builder_specs do %>
                <div class="rounded-md border border-border bg-background/70 p-3">
                  <div class="text-xs font-semibold text-foreground">{spec.name}</div>
                  <div class="text-[11px] text-muted-foreground mt-1">{spec.description}</div>
                  <div class="text-[11px] text-muted-foreground mt-2">
                    boundary: {Map.get(spec.metadata, "boundary")}
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>

        <div class="space-y-4">
          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Allowed Tool Union</div>
            <div id="skills-allowed-tools" class="text-[11px] text-foreground whitespace-pre-wrap">
              {if @demo.allowed_tools == [], do: "No rendered prompt yet.", else: Enum.join(@demo.allowed_tools, ", ")}
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Rendered Prompt</div>
            <pre id="skills-prompt-output" class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= if @demo.prompt == "", do: "Render the prompt to inspect the combined skill instructions.", else: @demo.prompt %></pre>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4 space-y-3">
            <div class="flex items-center justify-between">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Builder Workflow Task</div>
              <div id="skills-builder-runtime-targets" class="text-[10px] text-muted-foreground">
                {if @demo.builder_runtime_targets == [], do: "runtime targets pending", else: Enum.join(@demo.builder_runtime_targets, ", ")}
              </div>
            </div>

            <div id="skills-builder-task-summary" class="space-y-2 text-[11px] text-foreground">
              <div><span class="font-semibold">task:</span> {@demo.builder_task.title}</div>
              <div><span class="font-semibold">target package:</span> {@demo.builder_task.target_package}</div>
              <div><span class="font-semibold">summary:</span> {@demo.builder_task.summary}</div>
            </div>

            <div>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Reference Paths</div>
              <div id="skills-builder-reference-paths" class="space-y-1 text-[11px] text-foreground">
                <%= for path <- @demo.builder_task.reference_paths do %>
                  <div>{path}</div>
                <% end %>
              </div>
            </div>

            <div>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Deliverables</div>
              <div id="skills-builder-deliverables" class="space-y-1 text-[11px] text-foreground">
                <%= for path <- @demo.builder_task.deliverable_paths do %>
                  <div>{path}</div>
                <% end %>
              </div>
            </div>

            <div :if={@demo.builder_selected_skill_names != []}>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Selected Builder Skills</div>
              <div id="skills-builder-selected-skills" class="space-y-1 text-[11px] text-foreground">
                <%= for skill_name <- @demo.builder_selected_skill_names do %>
                  <div>{skill_name}</div>
                <% end %>
              </div>
            </div>

            <div :if={@demo.builder_workflow_steps != []}>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Workflow Steps</div>
              <div id="skills-builder-workflow-steps" class="space-y-2">
                <%= for step <- @demo.builder_workflow_steps do %>
                  <div class="rounded-md border border-border bg-background/70 p-3">
                    <div class="text-xs font-semibold text-foreground">{step.title}</div>
                    <div class="text-[11px] text-muted-foreground mt-1">{step.detail}</div>
                    <div class="text-[11px] text-muted-foreground mt-2">deliverable: {step.deliverable}</div>
                  </div>
                <% end %>
              </div>
            </div>

            <div :if={@demo.builder_boundary_notes != []}>
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Boundary Notes</div>
              <div id="skills-builder-boundary-notes" class="space-y-1 text-[11px] text-foreground">
                <%= for note <- @demo.builder_boundary_notes do %>
                  <div>{note}</div>
                <% end %>
              </div>
            </div>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Builder Prompt</div>
            <pre id="skills-builder-prompt-output" class="text-[11px] text-foreground whitespace-pre-wrap font-mono"><%= if @demo.builder_prompt == "", do: "Run the builder workflow to inspect the contributor prompt assembled from the catalog.", else: @demo.builder_prompt %></pre>
          </div>

          <div class="rounded-md border border-border bg-elevated p-4">
            <div class="flex items-center justify-between mb-2">
              <div class="text-[10px] uppercase tracking-wider text-muted-foreground">Activity Log</div>
              <div class="text-[10px] text-muted-foreground">{length(@demo.log)} event(s)</div>
            </div>

            <div :if={@demo.log == []} class="text-xs text-muted-foreground">
              Use the controls above to inspect manifest loading, registry population, and prompt rendering.
            </div>

            <div :if={@demo.log != []} class="space-y-2 max-h-[28rem] overflow-y-auto">
              <%= for entry <- @demo.log do %>
                <div class="rounded-md border border-border bg-background/70 px-3 py-2">
                  <div class="text-[11px] font-semibold text-foreground">{entry.label}</div>
                  <div class="text-[11px] text-muted-foreground">{entry.detail}</div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("load_file_manifest", _params, socket) do
    {:noreply, assign_demo(socket, RuntimeDemo.load_file_manifest(socket.assigns.demo))}
  end

  def handle_event("register_module_skill", _params, socket) do
    {:noreply, assign_demo(socket, RuntimeDemo.register_module_skill(socket.assigns.demo))}
  end

  def handle_event("load_runtime_skills", _params, socket) do
    {:noreply, assign_demo(socket, RuntimeDemo.load_runtime_skills(socket.assigns.demo))}
  end

  def handle_event("load_builder_catalog", _params, socket) do
    {:noreply, assign_demo(socket, RuntimeDemo.load_builder_catalog(socket.assigns.demo))}
  end

  def handle_event("render_prompt", _params, socket) do
    {:noreply, assign_demo(socket, RuntimeDemo.render_prompt(socket.assigns.demo))}
  end

  def handle_event("run_builder_workflow", _params, socket) do
    {:noreply, assign_demo(socket, RuntimeDemo.run_builder_workflow(socket.assigns.demo))}
  end

  def handle_event("reset_demo", _params, socket) do
    {:noreply, assign_demo(socket, RuntimeDemo.reset(socket.assigns.demo))}
  end

  defp assign_demo(socket, demo) do
    assign(socket,
      demo: demo,
      registry_count: length(demo.registry_specs)
    )
  end

  defp render_source({:module, module}), do: inspect(module)

  defp render_source({:file, path}) do
    Path.relative_to(path, File.cwd!())
  end
end
