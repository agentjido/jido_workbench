defmodule JidoWorkbench.Documentation.MenuNode do
  @moduledoc """
  Represents a node in the documentation menu tree.

  Each node can have:
  - A document (if a doc exists at this level)
  - Children (nested nodes for sub-paths)
  - Order for sorting siblings
  """

  alias JidoWorkbench.Documentation.Document

  @type t :: %__MODULE__{
          slug: String.t(),
          doc: Document.t() | nil,
          children: [t()],
          order: integer()
        }

  defstruct [:slug, :doc, children: [], order: 9999]

  @doc """
  Creates a new MenuNode from a slug and optional document.
  """
  def new(slug, doc \\ nil) do
    %__MODULE__{
      slug: slug,
      doc: doc,
      order: (doc && doc.order) || 9999,
      children: []
    }
  end

  @doc """
  Returns the display label for this menu node.
  Uses menu_label if set, otherwise falls back to title.
  """
  def label(%__MODULE__{doc: nil, slug: slug}), do: humanize_slug(slug)

  def label(%__MODULE__{doc: doc}) do
    Map.get(doc, :menu_label) || doc.title
  end

  defp humanize_slug(slug) do
    slug
    |> String.replace(~r/[-_]/, " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
