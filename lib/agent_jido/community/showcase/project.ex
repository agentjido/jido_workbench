defmodule AgentJido.Community.Showcase.Project do
  @moduledoc """
  Represents a project card in the community showcase.

  Parsed at compile time from Markdown files in `priv/community_showcase/`.
  Frontmatter provides structured metadata and the body is rendered to HTML.
  """

  @schema Zoi.struct(
            __MODULE__,
            %{
              slug: Zoi.string(description: "Unique slug derived from filename"),
              title: Zoi.string(description: "Project title"),
              description: Zoi.string(description: "One-line project summary") |> Zoi.default(""),
              project_url: Zoi.string(description: "Primary project URL"),
              repo_url: Zoi.string(description: "Optional source repository URL") |> Zoi.optional(),
              logo_url: Zoi.string(description: "Optional logo image URL") |> Zoi.optional(),
              tags: Zoi.any(description: "Tag list for filtering or chips") |> Zoi.default([]),
              featured: Zoi.boolean(description: "Whether project should be visually prioritized") |> Zoi.default(false),
              status: Zoi.enum([:draft, :live], description: "Visibility state for listings") |> Zoi.default(:live),
              sort_order: Zoi.integer(description: "Sort order within the showcase") |> Zoi.default(100),
              body: Zoi.string(description: "Rendered HTML body") |> Zoi.default(""),
              path: Zoi.string(description: "App-relative source path") |> Zoi.default(""),
              source_path: Zoi.string(description: "Absolute source filename") |> Zoi.default("")
            },
            coerce: true
          )

  @type t :: %__MODULE__{
          slug: String.t(),
          title: String.t(),
          description: String.t(),
          project_url: String.t(),
          repo_url: String.t() | nil,
          logo_url: String.t() | nil,
          tags: [String.t()],
          featured: boolean(),
          status: :draft | :live,
          sort_order: integer(),
          body: String.t(),
          path: String.t(),
          source_path: String.t()
        }

  @enforce_keys Zoi.Struct.enforce_keys(@schema)
  defstruct Zoi.Struct.struct_fields(@schema)

  @doc """
  Returns the schema used to validate showcase project metadata.
  """
  @spec schema() :: Zoi.schema()
  def schema, do: @schema

  @doc """
  NimblePublisher build callback.
  """
  @spec build(String.t(), map(), String.t()) :: t()
  def build(filename, attrs, body) do
    slug =
      filename
      |> Path.rootname()
      |> Path.basename()

    base_path = Application.app_dir(:agent_jido)
    path = String.replace(filename, base_path, "")

    attrs =
      attrs
      |> Map.put(:slug, slug)
      |> Map.put(:body, body)
      |> Map.put(:path, path)
      |> Map.put(:source_path, filename)

    case Zoi.parse(@schema, attrs) do
      {:ok, project} -> project
      {:error, errors} -> raise "Invalid showcase project #{slug}: #{inspect(errors)}"
    end
  end
end
