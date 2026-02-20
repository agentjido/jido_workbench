defmodule AgentJido.OGImage do
  @moduledoc """
  Generates and caches Open Graph images rendered from dynamic route descriptors.
  """

  use GenServer

  alias AgentJido.OGImage.Descriptor
  alias AgentJido.OGImage.Resolver
  alias AgentJido.OGImage.Templates

  @ets_table :og_image_cache
  @image_width 1200
  @image_height 630
  @default_cache_ttl_ms :timer.hours(24)

  @type image_result :: {:ok, binary(), Descriptor.t()} | {:error, term()}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec get_image_for_path(String.t()) :: image_result()
  def get_image_for_path(path) when is_binary(path) do
    with {:ok, descriptor} <- Resolver.resolve_path(path),
         {:ok, png_data} <- get_cached_or_generate(descriptor.cache_key, fn -> render_descriptor(descriptor) end) do
      {:ok, png_data, descriptor}
    end
  end

  @spec get_fallback_image() :: image_result()
  def get_fallback_image do
    get_image_for_path("/__not_found__")
  end

  def clear_cache do
    GenServer.call(__MODULE__, :clear_cache)
  end

  @impl true
  def init(_opts) do
    :ets.new(@ets_table, [:set, :named_table, :public, read_concurrency: true])
    {:ok, %{}}
  end

  @impl true
  def handle_call(:clear_cache, _from, state) do
    :ets.delete_all_objects(@ets_table)
    {:reply, :ok, state}
  end

  defp cache_ttl_ms do
    Application.get_env(:agent_jido, :og_image_cache_ttl_ms, @default_cache_ttl_ms)
  end

  defp get_cached_or_generate(cache_key, generator_fn) do
    now = System.monotonic_time(:millisecond)

    case :ets.whereis(@ets_table) do
      :undefined ->
        generator_fn.()

      _table ->
        case :ets.lookup(@ets_table, cache_key) do
          [{^cache_key, png_data, expires_at}] when expires_at > now ->
            {:ok, png_data}

          _ ->
            case generator_fn.() do
              {:ok, png_data} ->
                expires_at = now + cache_ttl_ms()
                :ets.insert(@ets_table, {cache_key, png_data, expires_at})
                {:ok, png_data}

              error ->
                error
            end
        end
    end
  end

  defp render_descriptor(descriptor) do
    svg = Templates.render_svg(descriptor)

    with {:ok, image} <- Image.from_svg(svg, width: @image_width, height: @image_height),
         {:ok, png_data} <- Image.write(image, :memory, suffix: ".png") do
      {:ok, png_data}
    end
  end
end
