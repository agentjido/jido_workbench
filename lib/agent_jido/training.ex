defmodule AgentJido.Training do
  @moduledoc """
  Static training curriculum registry for the Jido Workbench.
  """

  alias AgentJido.Training.Module

  use NimblePublisher,
    build: Module,
    from: Application.app_dir(:agent_jido, "priv/training/*.md"),
    as: :modules,
    highlighters: [:makeup_elixir, :makeup_js, :makeup_html]

  @modules Enum.sort_by(@modules, fn module -> {module.order, module.title} end)

  @modules_by_slug Map.new(@modules, &{&1.slug, &1})
  @modules_by_track Enum.group_by(@modules, & &1.track)
  @index_by_slug @modules |> Enum.with_index() |> Map.new(fn {module, index} -> {module.slug, index} end)

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  @spec all_modules() :: [Module.t()]
  def all_modules, do: @modules

  @spec get_module(String.t()) :: Module.t() | nil
  def get_module(slug), do: Map.get(@modules_by_slug, slug)

  @spec get_module!(String.t()) :: Module.t()
  def get_module!(slug) do
    get_module(slug) ||
      raise NotFoundError, "training module with slug=#{slug} not found"
  end

  @spec modules_by_track(atom() | String.t()) :: [Module.t()]
  def modules_by_track(track) when is_atom(track), do: Map.get(@modules_by_track, track, [])

  def modules_by_track(track) when is_binary(track) do
    Enum.filter(@modules, fn module -> to_string(module.track) == track end)
  end

  @spec neighbors(String.t() | Module.t()) :: {Module.t() | nil, Module.t() | nil}
  def neighbors(%Module{slug: slug}), do: neighbors(slug)

  def neighbors(slug) when is_binary(slug) do
    case Map.fetch(@index_by_slug, slug) do
      {:ok, index} ->
        previous_module =
          if index > 0 do
            Enum.at(@modules, index - 1)
          end

        next_module =
          if index + 1 < length(@modules) do
            Enum.at(@modules, index + 1)
          end

        {previous_module, next_module}

      :error ->
        {nil, nil}
    end
  end

  @spec module_count() :: non_neg_integer()
  def module_count, do: length(@modules)
end
