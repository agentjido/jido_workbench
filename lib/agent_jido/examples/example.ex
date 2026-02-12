defmodule AgentJido.Examples.Example do
  @moduledoc """
  Represents an interactive example in the Jido Workbench.

  Parsed at compile time from Markdown files in `priv/examples/`.
  Frontmatter provides structured metadata; the body contains rendered HTML.
  Each example references a LiveView module for the interactive demo and
  explicitly lists source files to display alongside the explanation.

  Source files are read and syntax-highlighted at compile time via Makeup,
  ensuring they are available in production releases.
  """

  @schema Zoi.struct(
            __MODULE__,
            %{
              slug: Zoi.string(description: "Unique slug derived from filename"),
              title: Zoi.string(description: "Example title"),
              description: Zoi.string(description: "Short summary") |> Zoi.default(""),
              body: Zoi.string(description: "Rendered HTML body") |> Zoi.default(""),
              tags: Zoi.any(description: "List of tag strings for categorization") |> Zoi.default([]),
              category:
                Zoi.enum([:core, :ai, :production],
                  description: "Primary category"
                )
                |> Zoi.default(:core),
              emoji: Zoi.string(description: "Emoji icon for display") |> Zoi.default("⚡"),
              source_files:
                Zoi.any(description: "Explicit list of repo-relative source file paths to showcase")
                |> Zoi.default([]),
              sources:
                Zoi.any(description: "Compile-time embedded source code: list of %{path, content, highlighted}")
                |> Zoi.default([]),
              live_view_module: Zoi.string(description: "Fully-qualified LiveView module name that runs the interactive demo"),
              difficulty:
                Zoi.enum([:beginner, :intermediate, :advanced],
                  description: "Difficulty level"
                )
                |> Zoi.default(:beginner),
              sort_order:
                Zoi.integer(description: "Sort order within category")
                |> Zoi.default(100),
              path: Zoi.string(description: "App-relative source path") |> Zoi.default(""),
              source_path: Zoi.string(description: "Absolute source filename") |> Zoi.default("")
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
  Derives the example `slug` from the filename. Reads and highlights
  all source files at compile time.
  """
  def build(filename, attrs, body) do
    slug =
      filename
      |> Path.rootname()
      |> Path.basename()

    base_path = Application.app_dir(:agent_jido)
    path = String.replace(filename, base_path, "")

    source_files = Map.get(attrs, :source_files, [])
    sources = embed_sources(source_files)

    attrs =
      attrs
      |> Map.put(:slug, slug)
      |> Map.put(:body, body)
      |> Map.put(:path, path)
      |> Map.put(:source_path, filename)
      |> Map.put(:sources, sources)

    case Zoi.parse(@schema, attrs) do
      {:ok, example} -> example
      {:error, errors} -> raise "Invalid example #{slug}: #{inspect(errors)}"
    end
  end

  defp embed_sources(paths) do
    Enum.map(paths, fn rel_path ->
      content =
        case File.read(rel_path) do
          {:ok, content} -> content
          {:error, _} -> "# Source file not found: #{rel_path}"
        end

      highlighted =
        try do
          Makeup.highlight(content)
        rescue
          _ -> "<pre><code>#{content}</code></pre>"
        end

      %{path: rel_path, content: content, highlighted: highlighted}
    end)
  end
end
