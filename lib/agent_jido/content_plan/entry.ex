defmodule AgentJido.ContentPlan.Entry do
  @moduledoc """
  Represents a single planned content piece in the Jido documentation.

  Parsed at compile time from Markdown files in `priv/content_plan/`.
  Frontmatter provides structured metadata for TODO tracking and
  LLM-evaluable specification; the body contains the content brief.
  """

  @schema Zoi.struct(
            __MODULE__,
            %{
              # Identity
              id: Zoi.string(description: "Unique slug derived from filename"),
              title: Zoi.string(description: "Human-readable page title"),
              slug: Zoi.string(description: "URL slug, unique within section"),
              section: Zoi.string(description: "Parent section slug (folder name)"),
              order: Zoi.integer(description: "Sort order within section") |> Zoi.default(9999),

              # Purpose (LLM-evaluable)
              purpose: Zoi.string(description: "What this content achieves for the reader") |> Zoi.default(""),
              audience:
                Zoi.atom(description: "Target audience level: beginner, intermediate, advanced")
                |> Zoi.default(:beginner),
              content_type:
                Zoi.atom(description: "Content type: tutorial, guide, reference, explanation")
                |> Zoi.default(:guide),
              learning_outcomes:
                Zoi.any(description: "List of strings: what the reader can do after reading")
                |> Zoi.default([]),

              # Source code linkage (for LLM validation)
              repos:
                Zoi.any(description: "List of ecosystem repo ids from priv/ecosystem/")
                |> Zoi.default([]),
              source_modules:
                Zoi.any(description: "List of module name strings content must accurately cover")
                |> Zoi.default([]),
              source_files:
                Zoi.any(description: "List of repo-relative file paths to cross-reference")
                |> Zoi.default([]),

              # Status tracking
              status:
                Zoi.atom(description: "Workflow status: planned, outline, draft, review, published")
                |> Zoi.default(:planned),
              assignee: Zoi.string(description: "GitHub handle of assignee") |> Zoi.optional(),
              priority:
                Zoi.atom(description: "Priority: critical, high, medium, low")
                |> Zoi.default(:medium),

              # Cross-references
              prerequisites:
                Zoi.any(description: "List of entry slugs that should come before this")
                |> Zoi.default([]),
              related:
                Zoi.any(description: "List of entry slugs of related content")
                |> Zoi.default([]),
              ecosystem_packages:
                Zoi.any(description: "List of priv/ecosystem/ package ids this links to")
                |> Zoi.default([]),

              # Destination mapping
              destination_route:
                Zoi.string(description: "Target URL path where this content publishes, e.g. /features/reliability-by-architecture")
                |> Zoi.optional(),
              destination_collection:
                Zoi.atom(description: "Target priv/ content collection, e.g. :pages, :documentation, :training")
                |> Zoi.optional(),

              # Tags
              tags: Zoi.any(description: "List of tag atoms for filtering") |> Zoi.default([]),

              # Prompt controls
              prompt_overrides:
                Zoi.any(description: "Optional map of per-entry prompt constraints for content generation")
                |> Zoi.default(%{}),

              # Parsed content
              body: Zoi.string(description: "Rendered HTML content brief") |> Zoi.default(""),
              path: Zoi.string(description: "Source file path") |> Zoi.default("")
            },
            coerce: true
          )

  @type t :: unquote(Zoi.type_spec(@schema))

  @enforce_keys Zoi.Struct.enforce_keys(@schema)
  defstruct Zoi.Struct.struct_fields(@schema)

  def schema, do: @schema

  def build(filename, attrs, body) do
    slug =
      filename
      |> Path.rootname()
      |> Path.basename()

    section =
      filename
      |> Path.dirname()
      |> Path.basename()

    attrs =
      attrs
      |> Map.put(:id, "#{section}/#{slug}")
      |> Map.put(:slug, slug)
      |> Map.put(:section, section)
      |> Map.put(:body, body)
      |> Map.put(:path, filename)
      |> Map.put_new(:title, slug |> String.replace("-", " ") |> String.split() |> Enum.map_join(" ", &String.capitalize/1))

    case Zoi.parse(@schema, attrs) do
      {:ok, entry} -> entry
      {:error, errors} -> raise "Invalid content plan entry #{section}/#{slug}: #{inspect(errors)}"
    end
  end
end
