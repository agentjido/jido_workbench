defmodule AgentJido.Ecosystem.Package do
  @moduledoc """
  Represents a package in the Jido ecosystem.

  Parsed at compile time from Markdown files in `priv/ecosystem/`.
  Frontmatter provides structured metadata; the body contains
  rich Markdown rendered as HTML for site pages and available
  as raw Markdown for RAG ingestion.
  """

  @schema Zoi.struct(
            __MODULE__,
            %{
              id: Zoi.string(description: "Unique slug derived from filename"),
              name: Zoi.string(description: "Hex package name"),
              title: Zoi.string(description: "Human-readable display name"),
              version: Zoi.string(description: "Current version") |> Zoi.default("0.0.0"),
              tagline: Zoi.string(description: "One-line description") |> Zoi.default(""),
              graph_label: Zoi.string(description: "Short graph label for ecosystem ASCII map") |> Zoi.optional(),
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

    attrs =
      attrs
      |> Map.put(:id, id)
      |> Map.put(:body, body)
      |> Map.put(:path, filename)
      |> Map.put_new(:name, id)
      |> Map.put_new(:title, id |> String.replace("_", " ") |> String.split() |> Enum.map_join(" ", &String.capitalize/1))

    case Zoi.parse(@schema, attrs) do
      {:ok, package} -> package
      {:error, errors} -> raise "Invalid package #{id}: #{inspect(errors)}"
    end
  end
end
