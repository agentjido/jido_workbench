defmodule AgentJido.ContentPlan.Section do
  @moduledoc """
  Represents a content section (folder) in the content plan.

  Parsed at compile time from `_section.md` files in `priv/content_plan/`.
  Each section defines a top-level grouping in the documentation hierarchy.
  """

  @schema Zoi.struct(
            __MODULE__,
            %{
              id: Zoi.string(description: "Unique slug derived from folder name"),
              title: Zoi.string(description: "Human-readable section title"),
              description: Zoi.string(description: "What this section covers") |> Zoi.default(""),
              order: Zoi.integer(description: "Sort order among sections") |> Zoi.default(9999),
              icon: Zoi.string(description: "Heroicon name for nav display") |> Zoi.optional(),
              body: Zoi.string(description: "Rendered HTML overview") |> Zoi.default(""),
              path: Zoi.string(description: "Source file path") |> Zoi.default("")
            },
            coerce: true
          )

  @type t :: unquote(Zoi.type_spec(@schema))

  @enforce_keys Zoi.Struct.enforce_keys(@schema)
  defstruct Zoi.Struct.struct_fields(@schema)

  def schema, do: @schema

  def build(filename, attrs, body) do
    id =
      filename
      |> Path.dirname()
      |> Path.basename()

    attrs =
      attrs
      |> Map.put(:id, id)
      |> Map.put(:body, body)
      |> Map.put(:path, filename)
      |> Map.put_new(:title, id |> String.replace("-", " ") |> String.split() |> Enum.map_join(" ", &String.capitalize/1))

    case Zoi.parse(@schema, attrs) do
      {:ok, section} -> section
      {:error, errors} -> raise "Invalid section #{id}: #{inspect(errors)}"
    end
  end
end
