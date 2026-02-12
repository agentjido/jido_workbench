defmodule AgentJido.Examples do
  @moduledoc """
  Static interactive examples registry for the Jido Workbench.

  Powered by NimblePublisher, this module compiles Markdown files from
  `priv/examples/` into structured `Example` structs at build time.
  Provides indexed lookups by slug, category, and tag.
  """

  alias AgentJido.Examples.Example

  use NimblePublisher,
    build: Example,
    from: Application.app_dir(:agent_jido, "priv/examples/**/*.md"),
    as: :examples,
    highlighters: [:makeup_elixir, :makeup_js, :makeup_html]

  @examples Enum.sort_by(@examples, fn e -> {e.category, e.sort_order, e.title} end)

  @examples_by_slug Map.new(@examples, &{&1.slug, &1})

  @examples_by_category @examples |> Enum.group_by(& &1.category) |> Map.new()

  @tags @examples |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  @categories @examples |> Enum.map(& &1.category) |> Enum.uniq() |> Enum.sort()

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  @spec all_examples() :: [Example.t()]
  def all_examples, do: @examples

  @spec all_tags() :: [String.t()]
  def all_tags, do: @tags

  @spec all_categories() :: [atom()]
  def all_categories, do: @categories

  @spec get_example(String.t()) :: Example.t() | nil
  def get_example(slug), do: Map.get(@examples_by_slug, slug)

  @spec get_example!(String.t()) :: Example.t()
  def get_example!(slug) do
    get_example(slug) ||
      raise NotFoundError, "example with slug=#{slug} not found"
  end

  @spec examples_by_category(atom()) :: [Example.t()]
  def examples_by_category(category), do: Map.get(@examples_by_category, category, [])

  @spec examples_by_tag(String.t()) :: [Example.t()]
  def examples_by_tag(tag), do: Enum.filter(@examples, &(tag in &1.tags))

  @spec example_count() :: non_neg_integer()
  def example_count, do: length(@examples)
end
