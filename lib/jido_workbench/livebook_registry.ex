defmodule JidoWorkbench.LivebookRegistry do
  @moduledoc """
  GenServer responsible for scanning and caching livebook information at startup.
  Provides an API to access raw livebook metadata and content.
  """
  use GenServer
  require Logger

  @livebook_root "lib/jido_workbench_web/live"
  @livebook_extensions [".livemd", ".livebook"]

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_livebooks(type) when type in [:examples, :docs] do
    GenServer.call(__MODULE__, {:get_livebooks, type})
  end

  def get_livebook_content(path) do
    GenServer.call(__MODULE__, {:get_livebook_content, path})
  end

  @doc """
  Refresh the livebook cache for a specific type or all types if no type is provided.
  """
  def refresh_cache(type \\ nil) do
    GenServer.call(__MODULE__, {:refresh_cache, type})
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    state = scan_and_cache_livebooks()

    Logger.info(
      "LivebookRegistry initialized with #{length(state.examples)} examples and #{length(state.docs)} docs"
    )

    {:ok, state}
  end

  @impl true
  def handle_call({:get_livebooks, type}, _from, state) do
    {:reply, Map.get(state, type), state}
  end

  @impl true
  def handle_call({:refresh_cache, type}, _from, state) do
    new_state =
      case type do
        nil ->
          Logger.info("Refreshing all livebook caches")
          scan_and_cache_livebooks()

        type when type in [:examples, :docs] ->
          Logger.info("Refreshing #{type} livebook cache")
          Map.put(state, type, scan_livebooks(type))
      end

    Logger.info(
      "Cache refresh complete - #{length(new_state.examples)} examples and #{length(new_state.docs)} docs"
    )

    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call({:get_livebook_content, path}, _from, state) do
    Logger.debug("Attempting to load livebook content from base path: #{path}")

    # Try both extensions if the exact path isn't found
    paths =
      case Path.extname(path) do
        "" ->
          paths = Enum.map(@livebook_extensions, &(path <> &1))
          Logger.debug("No extension provided, will try paths: #{inspect(paths)}")
          paths

        ext ->
          Logger.debug("Extension provided: #{ext}")
          [path]
      end

    case Enum.find_value(paths, fn p -> Map.get(state.content_cache, p) end) do
      nil ->
        # Try to load from any of the possible paths
        Logger.debug("Content not found in cache, attempting to load from disk")

        content =
          Enum.find_value(paths, fn p ->
            Logger.debug("Trying to load from path: #{p}")
            load_livebook_content(p)
          end)

        case content do
          nil ->
            Logger.warning("Failed to load livebook content from any of paths: #{inspect(paths)}")
            {:reply, nil, state}

          content ->
            # Cache with the actual path that worked
            actual_path = Enum.find(paths, &File.exists?/1)
            Logger.debug("Successfully loaded content from path: #{actual_path}")
            new_state = put_in(state.content_cache[actual_path], content)
            {:reply, content, new_state}
        end

      content ->
        Logger.debug("Content found in cache")
        {:reply, content, state}
    end
  end

  # Private Functions

  defp scan_and_cache_livebooks do
    %{
      examples: scan_livebooks(:examples),
      docs: scan_livebooks(:docs),
      content_cache: %{}
    }
  end

  defp scan_livebooks(type) do
    type_path = Path.join(@livebook_root, to_string(type))
    Logger.debug("Scanning for livebooks in: #{type_path}")

    type_path
    |> File.ls!()
    |> Enum.flat_map(fn entry ->
      entry_path = Path.join(type_path, entry)
      scan_directory(entry_path, entry, type)
    end)
  end

  defp scan_directory(path, category, type) do
    Logger.debug("Scanning directory: #{path}")

    cond do
      Enum.any?(@livebook_extensions, &String.ends_with?(path, &1)) ->
        Logger.debug("Found livebook file: #{path}")
        [parse_livebook(path, Path.basename(path, Path.extname(path)), type)]

      File.dir?(path) ->
        files =
          path
          |> File.ls!()
          |> Enum.filter(
            &Enum.any?(@livebook_extensions, fn ext -> String.ends_with?(&1, ext) end)
          )

        Logger.debug("Found #{length(files)} livebook files in directory #{path}")

        files
        |> Enum.map(fn file ->
          full_path = Path.join(path, file)
          Logger.debug("Processing livebook: #{full_path}")

          parse_livebook(
            full_path,
            Path.basename(file, Path.extname(file)),
            type,
            category
          )
        end)

      true ->
        []
    end
  end

  defp parse_livebook(path, id, type, category \\ nil) do
    Logger.debug("Parsing livebook at #{path} with id: #{id}")
    # Read first section of file until --- marker
    content =
      path
      |> File.read!()
      |> String.split("---\n", parts: 3)
      |> case do
        [_, frontmatter, _content] ->
          Logger.debug("Successfully parsed frontmatter for #{path}")
          YamlElixir.read_from_string!(frontmatter)

        _ ->
          Logger.warning("No frontmatter found in #{path}")
          %{}
      end

    # Convert string keys to atoms and provide defaults
    %{
      id: id,
      title: content["title"] || String.capitalize(id),
      description: content["description"] || "",
      category: content["category"] || category || "Uncategorized",
      icon: content["icon"] || "hero-document",
      tags: content["tags"] || [],
      order: content["order"] || 999,
      path: path
    }
  end

  defp load_livebook_content(path) do
    case File.read(path) do
      {:ok, content} ->
        # Parse frontmatter and content
        case String.split(content, "---\n", parts: 3) do
          [_, frontmatter, markdown_content] ->
            Logger.debug("Successfully loaded and parsed content from #{path}")

            %{
              frontmatter: YamlElixir.read_from_string!(frontmatter),
              content: markdown_content
            }

          _ ->
            Logger.warning("No frontmatter found in content from #{path}")
            %{frontmatter: %{}, content: content}
        end

      {:error, reason} ->
        Logger.warning("Failed to read livebook file #{path}: #{inspect(reason)}")
        nil
    end
  end
end
