defmodule AgentJidoWeb.JidoEcosystemPackageMatrixLive do
  use AgentJidoWeb, :live_view

  alias AgentJido.Ecosystem
  alias AgentJido.Ecosystem.Layering

  import AgentJidoWeb.Jido.MarketingLayouts

  @layer_order %{foundation: 1, core: 2, ai: 3, app: 4}

  @impl true
  def mount(_params, _session, socket) do
    packages = Ecosystem.public_packages()
    title_by_id = Map.new(packages, &{&1.id, &1.title})

    rows =
      packages
      |> Enum.map(&to_row/1)
      |> Enum.sort_by(fn row -> {layer_rank(row.layer), String.downcase(row.title)} end)

    {:ok,
     assign(socket,
       rows: rows,
       title_by_id: title_by_id,
       package_count: length(rows),
       layer_count: rows |> Enum.map(& &1.layer) |> Enum.uniq() |> length(),
       og_image: "https://agentjido.xyz/og/ecosystem.png"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/ecosystem">
      <div class="container max-w-[1100px] mx-auto px-6 py-12">
        <section class="mb-10">
          <div class="inline-block px-4 py-2 rounded mb-5 bg-primary/10 border border-primary/30">
            <span class="text-primary text-[11px] font-semibold tracking-widest uppercase">
              PACKAGE MATRIX
            </span>
          </div>

          <h1 class="text-3xl font-bold leading-tight mb-4 tracking-tight">
            Ecosystem Package Matrix
          </h1>

          <p class="text-sm text-secondary-foreground leading-relaxed max-w-[720px]">
            Compare responsibilities, layering, maturity, and dependencies across public packages.
            Use this matrix to pick an adoption path before diving into package details.
          </p>

          <div class="flex flex-wrap items-center gap-6 mt-6">
            <div class="flex items-baseline gap-2">
              <span class="text-primary text-2xl font-bold">{@package_count}</span>
              <span class="text-muted-foreground text-xs">packages</span>
            </div>
            <div class="flex items-baseline gap-2">
              <span class="text-primary text-2xl font-bold">{@layer_count}</span>
              <span class="text-muted-foreground text-xs">layers</span>
            </div>
            <.link
              navigate="/ecosystem"
              class="text-xs text-primary hover:text-primary/80 transition-colors font-semibold"
            >
              VIEW DEPENDENCY GRAPH →
            </.link>
          </div>
        </section>

        <section class="mb-10">
          <h2 class="text-sm font-bold tracking-wider mb-4">ADOPTION ORDER</h2>
          <div class="grid md:grid-cols-4 gap-3">
            <%= for layer <- [:foundation, :core, :ai, :app] do %>
              <article class="bg-card border border-border rounded-md p-4">
                <div class={"text-[11px] font-bold uppercase tracking-wide #{layer_label_class(layer)}"}>
                  {layer_label(layer)}
                </div>
                <p class="text-xs text-muted-foreground mt-2">
                  Start with {layer_label(layer) |> String.downcase()} packages when your architecture needs this layer.
                </p>
              </article>
            <% end %>
          </div>
        </section>

        <section class="code-block overflow-hidden">
          <div class="code-header">
            <span class="text-[10px] text-muted-foreground">ecosystem_matrix.csv</span>
            <span class="text-[10px] text-muted-foreground">{@package_count} rows</span>
          </div>

          <div class="overflow-x-auto">
            <table class="w-full min-w-[940px] text-xs">
              <thead class="bg-elevated text-muted-foreground uppercase tracking-wider">
                <tr>
                  <th class="text-left font-semibold px-4 py-3">Package</th>
                  <th class="text-left font-semibold px-4 py-3">Layer</th>
                  <th class="text-left font-semibold px-4 py-3">Category</th>
                  <th class="text-left font-semibold px-4 py-3">Maturity</th>
                  <th class="text-left font-semibold px-4 py-3">Dependencies</th>
                  <th class="text-left font-semibold px-4 py-3">Links</th>
                </tr>
              </thead>
              <tbody>
                <%= for row <- @rows do %>
                  <tr class="border-t border-border align-top">
                    <td class="px-4 py-3">
                      <.link navigate={row.path} class="font-semibold text-foreground hover:text-primary transition-colors">
                        {row.title}
                      </.link>
                      <div class="text-muted-foreground mt-1">{row.tagline}</div>
                    </td>
                    <td class="px-4 py-3">
                      <span class={"inline-flex px-2 py-1 rounded text-[10px] uppercase tracking-wide border #{layer_badge_class(row.layer)}"}>
                        {layer_label(row.layer)}
                      </span>
                    </td>
                    <td class="px-4 py-3 text-muted-foreground">{row.category}</td>
                    <td class="px-4 py-3 text-muted-foreground">{row.maturity}</td>
                    <td class="px-4 py-3">
                      <%= if row.dependency_ids == [] do %>
                        <span class="text-muted-foreground">none</span>
                      <% else %>
                        <div class="flex flex-wrap gap-1.5">
                          <%= for dep_id <- row.dependency_ids do %>
                            <.link
                              navigate={package_path(dep_id)}
                              class="text-[10px] px-2 py-1 rounded bg-primary/10 text-primary hover:bg-primary/15 transition-colors"
                            >
                              {Map.get(@title_by_id, dep_id, dep_id)}
                            </.link>
                          <% end %>
                        </div>
                      <% end %>
                    </td>
                    <td class="px-4 py-3">
                      <%= if row.links == [] do %>
                        <span class="text-muted-foreground">n/a</span>
                      <% else %>
                        <div class="flex flex-wrap gap-1.5">
                          <%= for {label, href} <- row.links do %>
                            <a
                              href={href}
                              target="_blank"
                              rel="noopener noreferrer"
                              class="text-[10px] px-2 py-1 rounded bg-elevated text-muted-foreground hover:text-primary transition-colors"
                            >
                              {label}
                            </a>
                          <% end %>
                        </div>
                      <% end %>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </.marketing_layout>
    """
  end

  defp to_row(pkg) do
    %{
      title: pkg.title,
      tagline: normalize_text(pkg.tagline),
      layer: Layering.layer_for(pkg),
      category: format_atom(pkg.category),
      maturity: format_atom(pkg.maturity),
      dependency_ids: pkg.ecosystem_deps || [],
      path: package_path(pkg.id),
      links: package_links(pkg)
    }
  end

  defp package_links(pkg) do
    []
    |> maybe_push_link("docs", pkg.hexdocs_url)
    |> maybe_push_link("hex", pkg.hex_url)
    |> maybe_push_link("github", pkg.github_url)
  end

  defp maybe_push_link(links, _label, nil), do: links
  defp maybe_push_link(links, _label, ""), do: links
  defp maybe_push_link(links, label, href) when is_binary(href), do: links ++ [{label, href}]

  defp package_path(id), do: "/ecosystem/#{id}"

  defp layer_rank(layer), do: Map.get(@layer_order, layer, 99)

  defp layer_label(layer), do: format_atom(layer)

  defp layer_label_class(:foundation), do: "text-accent-cyan"
  defp layer_label_class(:core), do: "text-accent-green"
  defp layer_label_class(:ai), do: "text-accent-yellow"
  defp layer_label_class(:app), do: "text-accent-red"
  defp layer_label_class(_), do: "text-primary"

  defp layer_badge_class(:foundation), do: "border-accent-cyan/40 bg-accent-cyan/10 text-accent-cyan"
  defp layer_badge_class(:core), do: "border-accent-green/40 bg-accent-green/10 text-accent-green"
  defp layer_badge_class(:ai), do: "border-accent-yellow/40 bg-accent-yellow/10 text-accent-yellow"
  defp layer_badge_class(:app), do: "border-accent-red/40 bg-accent-red/10 text-accent-red"
  defp layer_badge_class(_), do: "border-primary/30 bg-primary/10 text-primary"

  defp format_atom(value) when is_atom(value) do
    value
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.upcase()
  end

  defp format_atom(value) when is_binary(value), do: String.upcase(value)
  defp format_atom(_), do: "N/A"

  defp normalize_text(nil), do: ""
  defp normalize_text(value) when is_binary(value), do: String.trim(value)
  defp normalize_text(value), do: value |> to_string() |> String.trim()
end
