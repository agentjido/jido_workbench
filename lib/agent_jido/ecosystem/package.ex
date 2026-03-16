defmodule AgentJido.Ecosystem.Package do
  @moduledoc """
  Represents a package in the Jido ecosystem.

  Parsed at compile time from Markdown files in `priv/ecosystem/`.
  Frontmatter provides structured metadata; the body contains
  rich Markdown rendered as HTML for site pages and available
  as raw Markdown for RAG ingestion.
  """

  alias AgentJido.Ecosystem.SupportLevel

  @schema Zoi.struct(
            __MODULE__,
            %{
              id: Zoi.string(description: "Unique slug derived from filename"),
              name: Zoi.string(description: "Hex package name"),
              title: Zoi.string(description: "Human-readable display name"),
              version: Zoi.string(description: "Current version") |> Zoi.default("0.0.0"),
              tagline: Zoi.string(description: "One-line description") |> Zoi.default(""),
              graph_label: Zoi.string(description: "Short graph label for ecosystem ASCII map") |> Zoi.optional(),
              orbit_domain:
                Zoi.atom(description: "Optional orbit grouping key for ecosystem visualizations")
                |> Zoi.optional(),
              orbit_parent:
                Zoi.string(description: "Optional parent package id for selective sub-orbit rendering")
                |> Zoi.optional(),
              orbit_order:
                Zoi.integer(description: "Optional explicit orbit sort order within a domain")
                |> Zoi.optional(),
              compare_order:
                Zoi.integer(description: "Optional explicit sort order for ecosystem comparison views")
                |> Zoi.optional(),
              orbit_label:
                Zoi.string(description: "Optional short label override for orbit node rendering")
                |> Zoi.optional(),
              orbit_weight:
                Zoi.number(description: "Optional orbit node size/weight override for visualizations")
                |> Zoi.optional(),
              orbit_visible:
                Zoi.boolean(description: "Whether this package should be included in orbit visualizations")
                |> Zoi.default(true),
              description: Zoi.string(description: "Longer description paragraph") |> Zoi.optional(),
              landing_summary: Zoi.string(description: "High-level landing summary blurb") |> Zoi.optional(),
              landing_cliff_notes:
                Zoi.any(description: "List of short cliff-note bullets for landing pages")
                |> Zoi.default([]),
              landing_important_packages:
                Zoi.any(description: "Important ecosystem package links and reasons")
                |> Zoi.default([]),
              landing_major_components:
                Zoi.any(description: "Major components with explicit documentation links")
                |> Zoi.default([]),
              landing_module_map:
                Zoi.any(description: "Curated high-level module map metadata")
                |> Zoi.default(%{}),
              license: Zoi.string(description: "SPDX license identifier") |> Zoi.default("Apache-2.0"),
              visibility: Zoi.atom(description: "Public or private package") |> Zoi.default(:public),
              category:
                Zoi.atom(description: "Package category (core, ai, tools, runtime, integrations)")
                |> Zoi.default(:tools),
              tier:
                Zoi.integer(description: "Display/sort tier (1=core, 2=official, 3=community)")
                |> Zoi.default(2),
              tags: Zoi.any(description: "List of tag atoms") |> Zoi.default([]),
              hex_url: Zoi.string(description: "Hex.pm package URL") |> Zoi.optional(),
              hexdocs_url: Zoi.string(description: "HexDocs URL") |> Zoi.optional(),
              github_url: Zoi.string(description: "GitHub repository URL") |> Zoi.optional(),
              github_org: Zoi.string(description: "GitHub organization") |> Zoi.default("agentjido"),
              github_repo: Zoi.string(description: "GitHub repository name") |> Zoi.optional(),
              elixir: Zoi.string(description: "Required Elixir version") |> Zoi.optional(),
              ecosystem_deps:
                Zoi.any(description: "List of ecosystem package id strings this depends on")
                |> Zoi.default([]),
              key_features: Zoi.any(description: "List of feature highlight strings") |> Zoi.default([]),
              support_level:
                Zoi.atom(description: "Public support level (stable, beta, experimental)")
                |> Zoi.optional(),
              maturity:
                Zoi.atom(description: "Maturity tier (stable, beta, experimental, planned)")
                |> Zoi.default(:experimental),
              hex_status:
                Zoi.string(description: "Hex.pm publication status (published version or unreleased)")
                |> Zoi.default("unreleased"),
              api_stability:
                Zoi.string(description: "API stability expectations")
                |> Zoi.default("not yet defined"),
              limitations:
                Zoi.any(description: "Known limitations or non-goals")
                |> Zoi.default([]),
              stub: Zoi.boolean(description: "Whether this is a stub vs real usable code") |> Zoi.default(false),
              support:
                Zoi.atom(description: "Support expectations (best_effort, community, maintained)")
                |> Zoi.default(:best_effort),
              body: Zoi.string(description: "Rendered HTML body") |> Zoi.default(""),
              path: Zoi.string(description: "Source file path") |> Zoi.default("")
            },
            coerce: true
          )

  @type t :: unquote(Zoi.type_spec(@schema))

  @enforce_keys Zoi.Struct.enforce_keys(@schema)
  defstruct Zoi.Struct.struct_fields(@schema)

  def schema, do: @schema

  @doc """
  NimblePublisher build callback.

  Receives the filename, frontmatter attrs map, and parsed HTML body.
  Derives the package `id` from the filename slug.
  """
  def build(filename, attrs, body) do
    id =
      filename
      |> Path.rootname()
      |> Path.basename()

    support_level =
      attrs
      |> Map.get(:support_level)
      |> Kernel.||(Map.get(attrs, :maturity))
      |> SupportLevel.normalize()

    attrs =
      attrs
      |> Map.put(:id, id)
      |> Map.put(:body, body)
      |> Map.put(:path, filename)
      |> Map.put_new(:name, id)
      |> Map.put_new(:title, id |> String.replace("_", " ") |> String.split() |> Enum.map_join(" ", &String.capitalize/1))
      |> maybe_put(:support_level, support_level)

    case Zoi.parse(@schema, attrs) do
      {:ok, package} -> package
      {:error, errors} -> raise "Invalid package #{id}: #{inspect(errors)}"
    end
  end

  defp maybe_put(attrs, _key, nil), do: attrs
  defp maybe_put(attrs, key, value), do: Map.put(attrs, key, value)
end
