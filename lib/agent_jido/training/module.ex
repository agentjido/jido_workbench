defmodule AgentJido.Training.Module do
  @moduledoc """
  Represents a training module compiled from `priv/training/*.md`.
  """

  @schema Zoi.struct(
            __MODULE__,
            %{
              slug: Zoi.string(description: "Unique slug derived from filename"),
              title: Zoi.string(description: "Module title"),
              description: Zoi.string(description: "Short module summary") |> Zoi.default(""),
              track:
                Zoi.enum([:foundations, :coordination, :integration, :operations],
                  description: "Training track"
                )
                |> Zoi.default(:foundations),
              difficulty:
                Zoi.enum([:beginner, :intermediate, :advanced],
                  description: "Difficulty level"
                )
                |> Zoi.default(:beginner),
              duration_minutes: Zoi.integer(description: "Estimated duration in minutes") |> Zoi.default(30),
              order: Zoi.integer(description: "Sort order in curriculum") |> Zoi.default(100),
              tags: Zoi.any(description: "Tag list") |> Zoi.default([]),
              prerequisites: Zoi.any(description: "Prerequisites list") |> Zoi.default([]),
              learning_outcomes: Zoi.any(description: "Learning outcomes list") |> Zoi.default([]),
              body: Zoi.string(description: "Rendered HTML body") |> Zoi.default(""),
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
  """
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
      {:ok, module} -> module
      {:error, errors} -> raise "Invalid training module #{slug}: #{inspect(errors)}"
    end
  end
end
