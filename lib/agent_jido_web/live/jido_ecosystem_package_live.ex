defmodule AgentJidoWeb.JidoEcosystemPackageLive do
  use AgentJidoWeb, :live_view

  alias AgentJido.Ecosystem
  alias AgentJido.Ecosystem.Layering

  import AgentJidoWeb.Jido.MarketingCards
  import AgentJidoWeb.Jido.MarketingLayouts

  @max_cliff_notes 6
  @fallback_cliff_notes 4
  @default_important_reason "Core ecosystem relationship"

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    package = Ecosystem.get_public_package!(id)
    package_hero_summary = hero_summary(package)

    {:ok,
     assign(socket,
       page_title: package.title,
       meta_description: package_meta_description(package, package_hero_summary),
       package: package,
       layer: Layering.layer_for(package),
       package_links: package_links(package),
       hero_summary: package_hero_summary,
       cliff_notes: cliff_notes(package),
       major_components: major_components(package),
       important_packages: important_packages(package),
       module_map: module_map(package),
       quick_install: quick_install_snippet(package),
       dependencies: resolve_packages(package.ecosystem_deps || []),
       reverse_dependencies: resolve_packages(Ecosystem.reverse_deps(package.id))
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/ecosystem">
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <div class="mb-8">
          <.link navigate="/ecosystem" class="text-xs text-muted-foreground hover:text-primary transition-colors">
            ← back to ecosystem
          </.link>
        </div>

        <section class="ecosystem-package-hero mb-10">
          <div class="flex flex-wrap items-center gap-3 mb-3">
            <.layer_badge layer={@layer} />
            <span class="text-[11px] uppercase tracking-wide text-muted-foreground">
              version {@package.version}
            </span>
            <span class="text-[11px] uppercase tracking-wide text-muted-foreground">
              package {@package.name}
            </span>
          </div>

          <h1 class="text-3xl font-bold tracking-tight mb-3">{@package.title}</h1>
          <p class="text-sm text-secondary-foreground leading-relaxed max-w-[820px] mb-5">
            {@hero_summary}
          </p>

          <%= if @package_links != [] do %>
            <div class="flex gap-2 flex-wrap mb-5">
              <%= for {label, href} <- @package_links do %>
                <a
                  href={href}
                  target="_blank"
                  rel="noopener noreferrer"
                  class={"text-xs px-3 py-2 rounded border transition-colors font-semibold #{cta_link_class(label)}"}
                >
                  {label}
                </a>
              <% end %>
            </div>
          <% end %>

          <div :if={@quick_install} class="code-block overflow-hidden">
            <div class="code-header">
              <span class="text-[10px] text-muted-foreground">quickstart.exs</span>
              <span class="text-[10px] text-muted-foreground">mix deps</span>
            </div>
            <div class="p-4">
              <pre class="text-[11px] leading-relaxed whitespace-pre-wrap"><%= @quick_install %></pre>
            </div>
          </div>
        </section>

        <section :if={@cliff_notes != []} class="mb-10">
          <h2 class="text-sm font-bold tracking-wider mb-3">AT A GLANCE</h2>
          <div class="ecosystem-cliff-notes-grid">
            <%= for note <- @cliff_notes do %>
              <article class="ecosystem-cliff-note">
                {note}
              </article>
            <% end %>
          </div>
        </section>

        <section :if={@major_components != []} class="mb-10">
          <h2 class="text-sm font-bold tracking-wider mb-3">MAJOR COMPONENTS</h2>
          <div class="ecosystem-major-components-grid">
            <%= for component <- @major_components do %>
              <article class="ecosystem-major-component-card">
                <div class="text-sm font-bold text-foreground mb-1">{component.name}</div>
                <p :if={component.summary != ""} class="text-xs text-muted-foreground leading-relaxed">
                  {component.summary}
                </p>
                <div class="flex gap-2 mt-3 flex-wrap">
                  <a
                    :if={component.docs_url}
                    href={component.docs_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="text-[10px] px-2 py-1 rounded border border-accent-cyan/40 bg-accent-cyan/10 text-accent-cyan hover:bg-accent-cyan/15 transition-colors font-semibold"
                  >
                    docs
                  </a>
                  <a
                    :if={component.github_url}
                    href={component.github_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="text-[10px] px-2 py-1 rounded border border-border bg-elevated text-foreground hover:text-primary transition-colors font-semibold"
                  >
                    github
                  </a>
                </div>
              </article>
            <% end %>
          </div>
        </section>

        <section :if={@important_packages != []} class="mb-10">
          <h2 class="text-sm font-bold tracking-wider mb-3">IMPORTANT PACKAGES</h2>
          <div class="ecosystem-important-packages-grid">
            <%= for pkg <- @important_packages do %>
              <article class="ecosystem-important-package-card">
                <.link navigate={pkg.path} class="text-sm font-bold text-foreground hover:text-primary transition-colors">
                  {pkg.title}
                </.link>
                <p class="text-xs text-muted-foreground leading-relaxed mt-2">{pkg.reason}</p>
                <div class="flex gap-2 mt-3">
                  <.link navigate={pkg.path} class="text-[10px] px-2 py-1 rounded bg-primary/10 text-primary hover:bg-primary/15 transition-colors">
                    ecosystem page
                  </.link>
                  <a
                    :if={pkg.external_href}
                    href={pkg.external_href}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="text-[10px] px-2 py-1 rounded bg-elevated text-muted-foreground hover:text-primary transition-colors"
                  >
                    {pkg.external_label}
                  </a>
                </div>
              </article>
            <% end %>
          </div>
        </section>

        <section :if={@module_map} class="mb-10">
          <h2 class="text-sm font-bold tracking-wider mb-3">{@module_map.title}</h2>
          <div class="ecosystem-module-map">
            <%= for row <- @module_map.rows do %>
              <div class="ecosystem-module-row">
                <div class="ecosystem-module-row-label">{row.label}</div>
                <div class="ecosystem-module-row-nodes" style={"--module-cols: #{max(length(row.nodes), 1)}"}>
                  <%= for node <- row.nodes do %>
                    <article class="ecosystem-module-node">
                      <.link :if={node.path} navigate={node.path} class="text-xs font-semibold text-foreground hover:text-primary transition-colors">
                        {node.label}
                      </.link>
                      <span :if={!node.path} class="text-xs font-semibold text-foreground">{node.label}</span>
                      <p :if={node.note != ""} class="text-[10px] text-muted-foreground leading-relaxed mt-1">{node.note}</p>
                    </article>
                  <% end %>
                </div>
              </div>
            <% end %>

            <%= if @module_map.edges != [] do %>
              <div class="mt-4">
                <div class="text-[10px] uppercase tracking-wider text-muted-foreground mb-2">Flow</div>
                <div class="flex flex-wrap gap-2">
                  <%= for edge <- @module_map.edges do %>
                    <span class="ecosystem-module-edge">
                      {edge.from} -> {edge.to}
                      <span :if={edge.label != ""} class="text-muted-foreground">({edge.label})</span>
                    </span>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </section>

        <section :if={@dependencies != [] or @reverse_dependencies != []} class="mb-10">
          <h2 class="text-sm font-bold tracking-wider mb-3">ECOSYSTEM RELATIONSHIPS</h2>
          <div class="grid md:grid-cols-2 gap-4">
            <article class="bg-card border border-border rounded-md p-4">
              <div class="text-[10px] uppercase tracking-wide text-muted-foreground mb-2">Depends On</div>
              <div class="flex gap-2 flex-wrap">
                <%= if @dependencies == [] do %>
                  <span class="text-xs text-muted-foreground">none</span>
                <% else %>
                  <%= for dep <- @dependencies do %>
                    <.link navigate={dep.path} class="text-xs px-3 py-2 rounded bg-primary/10 text-primary hover:bg-primary/15 transition-colors">
                      {dep.title}
                    </.link>
                  <% end %>
                <% end %>
              </div>
            </article>

            <article class="bg-card border border-border rounded-md p-4">
              <div class="text-[10px] uppercase tracking-wide text-muted-foreground mb-2">Used By</div>
              <div class="flex gap-2 flex-wrap">
                <%= if @reverse_dependencies == [] do %>
                  <span class="text-xs text-muted-foreground">none</span>
                <% else %>
                  <%= for pkg <- @reverse_dependencies do %>
                    <.link navigate={pkg.path} class="text-xs px-3 py-2 rounded bg-card border border-border hover:border-primary/40 transition-colors">
                      {pkg.title}
                    </.link>
                  <% end %>
                <% end %>
              </div>
            </article>
          </div>
        </section>

        <section class="ecosystem-package-details mb-12">
          <h2 class="text-sm font-bold tracking-wider mb-3">FULL OVERVIEW</h2>
          <article class="prose max-w-none text-sm leading-relaxed text-foreground prose-headings:text-foreground prose-p:text-foreground/90 prose-li:text-foreground/90 prose-strong:text-foreground prose-code:text-foreground">
            {Phoenix.HTML.raw(@package.body)}
          </article>
        </section>
      </div>
    </.marketing_layout>
    """
  end

  defp resolve_packages(ids) do
    ids
    |> Enum.map(&Ecosystem.get_public_package/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn pkg ->
      %{
        id: pkg.id,
        title: pkg.title,
        path: "/ecosystem/#{pkg.id}"
      }
    end)
  end

  defp package_links(pkg) do
    []
    |> maybe_push_link("docs", pkg.hexdocs_url)
    |> maybe_push_link("hex", pkg.hex_url)
    |> maybe_push_link("github", pkg.github_url)
  end

  defp hero_summary(pkg) do
    summary = normalize_text(pkg.landing_summary)

    if summary == "" do
      normalize_text(pkg.tagline)
    else
      summary
    end
  end

  defp package_meta_description(pkg, summary) do
    normalized_summary = normalize_text(summary)

    if normalized_summary == "" do
      "Learn about #{pkg.title} in the Jido ecosystem and how it composes with related packages."
    else
      normalized_summary
    end
  end

  defp cliff_notes(pkg) do
    custom_notes = normalize_string_list(pkg.landing_cliff_notes) |> Enum.take(@max_cliff_notes)

    case custom_notes do
      [] ->
        pkg.key_features
        |> normalize_string_list()
        |> Enum.take(@fallback_cliff_notes)

      notes ->
        notes
    end
  end

  defp important_packages(pkg) do
    source_items = important_source_items(pkg)

    source_items
    |> Enum.reduce({MapSet.new(), []}, fn %{id: id, reason: reason}, {seen, acc} ->
      if MapSet.member?(seen, id) do
        {seen, acc}
      else
        case Ecosystem.get_public_package(id) do
          nil ->
            {MapSet.put(seen, id), acc}

          related ->
            {label, href} = external_doc_link(related)

            item = %{
              id: related.id,
              title: related.title,
              path: "/ecosystem/#{related.id}",
              reason: normalize_text(reason),
              external_label: label,
              external_href: href
            }

            {MapSet.put(seen, id), acc ++ [item]}
        end
      end
    end)
    |> elem(1)
  end

  defp important_source_items(pkg) do
    custom_items =
      pkg.landing_important_packages
      |> normalize_important_items()

    if custom_items == [] do
      pkg.ecosystem_deps
      |> List.wrap()
      |> Enum.map(fn id -> %{id: normalize_text(id), reason: @default_important_reason} end)
      |> Enum.reject(&(&1.id == ""))
    else
      custom_items
    end
  end

  defp module_map(pkg) do
    map = pkg.landing_module_map

    rows =
      map
      |> get_key(:rows, [])
      |> normalize_map_rows()

    if rows == [] do
      nil
    else
      %{
        title: get_key(map, :title, "HOW MODULES FIT TOGETHER") |> normalize_text() |> default_if_empty("HOW MODULES FIT TOGETHER"),
        rows: rows,
        edges:
          map
          |> get_key(:edges, [])
          |> normalize_map_edges()
      }
    end
  end

  defp major_components(pkg) do
    pkg.landing_major_components
    |> normalize_major_components()
  end

  defp normalize_major_components(components) when is_list(components) do
    components
    |> Enum.map(fn component ->
      name =
        component
        |> get_key(:name, get_key(component, :module, ""))
        |> normalize_text()

      summary = component |> get_key(:summary, "") |> normalize_text()

      docs_url =
        component
        |> get_key(:docs_url, get_key(component, :hexdocs_url, nil))
        |> normalize_optional_text()

      github_url = component |> get_key(:github_url, nil) |> normalize_optional_text()

      if name == "" do
        nil
      else
        %{
          name: name,
          summary: summary,
          docs_url: docs_url,
          github_url: github_url
        }
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_major_components(_), do: []

  defp normalize_important_items(items) when is_list(items) do
    items
    |> Enum.map(fn item ->
      id = item |> get_key(:id, nil) |> normalize_text()
      reason = item |> get_key(:reason, @default_important_reason) |> normalize_text() |> default_if_empty(@default_important_reason)

      if id == "" do
        nil
      else
        %{id: id, reason: reason}
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_important_items(_), do: []

  defp normalize_map_rows(rows) when is_list(rows) do
    rows
    |> Enum.map(fn row ->
      label = row |> get_key(:label, "Layer") |> normalize_text() |> default_if_empty("Layer")

      nodes =
        row
        |> get_key(:nodes, [])
        |> normalize_map_nodes()

      if nodes == [] do
        nil
      else
        %{label: label, nodes: nodes}
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_map_rows(_), do: []

  defp normalize_map_nodes(nodes) when is_list(nodes) do
    nodes
    |> Enum.map(fn node ->
      id = node |> get_key(:id, nil) |> normalize_text()
      label = node |> get_key(:label, id) |> normalize_text() |> default_if_empty(id)
      note = node |> get_key(:note, "") |> normalize_text()

      cond do
        label == "" ->
          nil

        true ->
          %{
            id: id,
            label: label,
            note: note,
            path: module_node_path(id)
          }
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_map_nodes(_), do: []

  defp normalize_map_edges(edges) when is_list(edges) do
    edges
    |> Enum.map(fn edge ->
      from = edge |> get_key(:from, "") |> normalize_text()
      to = edge |> get_key(:to, "") |> normalize_text()
      label = edge |> get_key(:label, "") |> normalize_text()

      if from == "" or to == "" do
        nil
      else
        %{from: from, to: to, label: label}
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp normalize_map_edges(_), do: []

  defp module_node_path(""), do: nil

  defp module_node_path(id) do
    case Ecosystem.get_public_package(id) do
      nil -> nil
      _pkg -> "/ecosystem/#{id}"
    end
  end

  defp quick_install_snippet(pkg) do
    name = normalize_text(pkg.name)
    version = normalize_text(pkg.version)

    if name == "" do
      nil
    else
      version_constraint = if version == "", do: "~> 0.1.0", else: "~> #{version}"

      """
      defp deps do
        [
          {:#{name}, "#{version_constraint}"}
        ]
      end
      """
      |> String.trim()
    end
  end

  defp external_doc_link(pkg) do
    cond do
      present?(pkg.hexdocs_url) -> {"hexdocs", pkg.hexdocs_url}
      present?(pkg.hex_url) -> {"hex", pkg.hex_url}
      present?(pkg.github_url) -> {"github", pkg.github_url}
      true -> {nil, nil}
    end
  end

  defp normalize_string_list(value) when is_list(value) do
    value
    |> Enum.map(&normalize_text/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp normalize_string_list(value) when is_binary(value) do
    text = normalize_text(value)
    if text == "", do: [], else: [text]
  end

  defp normalize_string_list(_), do: []

  defp normalize_text(text) when is_binary(text), do: text |> String.trim() |> String.replace(~r/\s+/, " ")
  defp normalize_text(_), do: ""

  defp normalize_optional_text(value) do
    value
    |> normalize_text()
    |> case do
      "" -> nil
      text -> text
    end
  end

  defp default_if_empty("", fallback), do: fallback
  defp default_if_empty(value, _fallback), do: value

  defp get_key(map, key, default) when is_map(map) do
    Map.get(map, key) || Map.get(map, Atom.to_string(key), default)
  end

  defp get_key(_map, _key, default), do: default

  defp maybe_push_link(links, _label, nil), do: links
  defp maybe_push_link(links, _label, ""), do: links
  defp maybe_push_link(links, label, href), do: links ++ [{label, href}]

  defp cta_link_class("docs"),
    do: "border-accent-cyan/50 bg-accent-cyan/15 text-accent-cyan hover:bg-accent-cyan/20"

  defp cta_link_class("hex"),
    do: "border-accent-yellow/50 bg-accent-yellow/12 text-accent-yellow hover:bg-accent-yellow/20"

  defp cta_link_class("github"),
    do: "border-border bg-elevated text-foreground hover:text-primary hover:border-primary/40"

  defp cta_link_class(_), do: "border-border bg-elevated text-foreground hover:text-primary"

  defp present?(nil), do: false
  defp present?(""), do: false
  defp present?(_), do: true
end
