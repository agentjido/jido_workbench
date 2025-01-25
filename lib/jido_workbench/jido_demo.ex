defmodule JidoWorkbench.JidoDemo do
  @moduledoc """
  Module for managing GDO demos and providing easy access to demo information.
  """

  defmodule Demo do
    @moduledoc """
    Struct representing a single GDO demo with its metadata and configuration.
    """
    @type t :: %__MODULE__{
            id: String.t(),
            name: String.t(),
            description: String.t(),
            module: module(),
            config: map(),
            enabled: boolean(),
            icon: String.t(),
            category: String.t() | nil,
            source_files: [String.t()],
            version: String.t() | nil,
            updated_at: DateTime.t() | nil,
            status: String.t() | nil,
            documentation_url: String.t() | nil,
            source_url: String.t() | nil,
            livebook: String.t() | nil,
            sections: [map()] | nil,
            related_resources: [map()] | nil
          }

    defstruct [
      :id,
      :name,
      :description,
      :module,
      :icon,
      :category,
      :source_files,
      :config,
      :enabled,
      :version,
      :updated_at,
      :status,
      :documentation_url,
      :source_url,
      :livebook,
      :sections,
      :related_resources
    ]
  end

  @doc """
  Fetches all available demos from the GDO discovery module.
  Returns a list of Demo structs.
  """
  @spec list_demos() :: [Demo.t()]
  def list_demos do
    Jido.list_demos()
    |> Enum.map(fn demo ->
      %Demo{
        id: Map.get(demo, :id),
        name: Map.get(demo, :name),
        description: Map.get(demo, :description),
        module: Map.get(demo, :module),
        icon: Map.get(demo, :icon),
        source_files: Map.get(demo, :source_files, []),
        config: Map.get(demo, :config),
        enabled: Map.get(demo, :enabled),
        version: Map.get(demo, :version),
        updated_at: Map.get(demo, :updated_at),
        status: Map.get(demo, :status),
        documentation_url: Map.get(demo, :documentation_url),
        source_url: Map.get(demo, :source_url),
        category: Map.get(demo, :category),
        livebook: Map.get(demo, :livebook),
        sections: Map.get(demo, :sections),
        related_resources: Map.get(demo, :related_resources)
      }
    end)
  end

  @doc """
  Filters demos by given criteria.

  ## Options
    * `:tags` - List of tags to filter by
    * `:enabled` - Filter by enabled status
    * `:module` - Filter by specific module
  """
  @spec filter_demos([Demo.t()], keyword()) :: [Demo.t()]
  def filter_demos(demos, criteria \\ []) do
    Enum.filter(demos, fn demo ->
      Enum.all?(criteria, fn
        {:tags, tags} -> Enum.any?(tags, &(&1 in Map.get(demo, :tags, [])))
        {:enabled, enabled} -> Map.get(demo, :enabled) == enabled
        {:module, module} -> Map.get(demo, :module) == module
      end)
    end)
  end

  @doc """
  Finds a specific demo by ID.
  Returns nil if no demo is found.
  """
  @spec get_demo_by_id([Demo.t()], String.t() | atom()) :: Demo.t() | nil
  def get_demo_by_id(demos, id) when is_binary(id) do
    # Convert string ID to atom for comparison
    atom_id = String.to_existing_atom(id)
    Enum.find(demos, &(&1.id == atom_id))
  rescue
    # Handle case where atom doesn't exist
    ArgumentError -> nil
  end

  def get_demo_by_id(demos, id) when is_atom(id) do
    Enum.find(demos, &(&1.id == id))
  end

  @doc """
  Returns a list of all available tags across all demos.
  """
  @spec list_available_tags([Demo.t()]) :: [String.t()]
  def list_available_tags(demos) do
    demos
    |> Enum.flat_map(&Map.get(&1, :tags, []))
    |> Enum.uniq()
    |> Enum.sort()
  end
end
