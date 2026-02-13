defmodule AgentJido.OGImage do
  @moduledoc """
  Generates and caches Open Graph images for social media sharing.
  Uses the Image library (libvips) to render SVG templates to PNG images at 1200x630.
  Images are cached in ETS for fast retrieval.
  """

  use GenServer

  @ets_table :og_image_cache
  @image_width 1200
  @image_height 630
  @default_cache_ttl_ms :timer.hours(24)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  defp cache_ttl_ms do
    Application.get_env(:agent_jido, :og_image_cache_ttl_ms, @default_cache_ttl_ms)
  end

  def get_image(:default) do
    get_cached_or_generate("default", fn -> generate_default_image() end)
  end

  def get_image(:home) do
    get_cached_or_generate("home", fn -> generate_home_image() end)
  end

  def get_image(:ecosystem) do
    get_cached_or_generate("ecosystem", fn -> generate_ecosystem_image() end)
  end

  def get_image(:getting_started) do
    get_cached_or_generate("getting_started", fn -> generate_getting_started_image() end)
  end

  def get_image(:examples) do
    get_cached_or_generate("examples", fn -> generate_examples_image() end)
  end

  def get_image(:features) do
    get_cached_or_generate("features", fn -> generate_features_image() end)
  end

  def get_image(:training) do
    get_cached_or_generate("training", fn -> generate_training_image() end)
  end

  def get_image(:partners) do
    get_image(:features)
  end

  def get_image(:docs) do
    get_cached_or_generate("docs", fn -> generate_docs_image() end)
  end

  def get_image(:cookbook) do
    get_cached_or_generate("cookbook", fn -> generate_cookbook_image() end)
  end

  def get_image(:catalog) do
    get_cached_or_generate("catalog", fn -> generate_catalog_image() end)
  end

  def get_image(:blog) do
    get_cached_or_generate("blog", fn -> generate_blog_image() end)
  end

  def get_image({:blog_post, slug}) do
    get_cached_or_generate("blog_post:#{slug}", fn -> generate_blog_post_image(slug) end)
  end

  def get_image(_), do: get_image(:default)

  def clear_cache do
    GenServer.call(__MODULE__, :clear_cache)
  end

  @impl true
  def init(_opts) do
    table = :ets.new(@ets_table, [:set, :named_table, :public, read_concurrency: true])
    {:ok, %{table: table}}
  end

  @impl true
  def handle_call(:clear_cache, _from, state) do
    :ets.delete_all_objects(@ets_table)
    {:reply, :ok, state}
  end

  defp get_cached_or_generate(key, generator) do
    case :ets.lookup(@ets_table, key) do
      [{^key, data, expires_at}] ->
        if System.monotonic_time(:millisecond) < expires_at do
          {:ok, data}
        else
          :ets.delete(@ets_table, key)
          generate_and_cache(key, generator)
        end

      [] ->
        generate_and_cache(key, generator)
    end
  end

  defp generate_and_cache(key, generator) do
    case generator.() do
      {:ok, data} ->
        expires_at = System.monotonic_time(:millisecond) + cache_ttl_ms()
        :ets.insert(@ets_table, {key, data, expires_at})
        {:ok, data}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp render_svg_to_png(svg) do
    with {:ok, image} <- Image.from_svg(svg, width: @image_width, height: @image_height),
         {:ok, data} <- Image.write(image, :memory, suffix: ".png") do
      {:ok, data}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp svg_escape(text) when is_binary(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&apos;")
  end

  defp svg_escape(text), do: svg_escape(to_string(text))

  defp generate_default_image do
    svg = """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{glow_filter()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)"/>
      #{decorative_circles()}
      #{border_frame()}
      <text x="600" y="250" font-family="system-ui, -apple-system, sans-serif" font-size="64" font-weight="bold" fill="#60a5fa" text-anchor="middle" filter="url(#glow)">Agent Jido</text>
      <text x="600" y="330" font-family="system-ui, -apple-system, sans-serif" font-size="32" fill="white" text-anchor="middle">Elixir Autonomous Agent Framework</text>
      <text x="600" y="390" font-family="system-ui, -apple-system, sans-serif" font-size="22" fill="#94a3b8" text-anchor="middle">Build intelligent, composable AI agents on the BEAM</text>
      #{footer_url("agentjido.xyz")}
    </svg>
    """

    render_svg_to_png(svg)
  end

  defp generate_home_image do
    svg = """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{glow_filter()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)"/>
      #{decorative_circles()}
      #{border_frame()}
      <text x="600" y="200" font-family="system-ui, -apple-system, sans-serif" font-size="64" font-weight="bold" fill="#60a5fa" text-anchor="middle" filter="url(#glow)">Agent Jido</text>
      <text x="600" y="280" font-family="system-ui, -apple-system, sans-serif" font-size="34" fill="white" text-anchor="middle">From LLM calls to autonomous agents</text>
      <text x="600" y="340" font-family="system-ui, -apple-system, sans-serif" font-size="22" fill="#94a3b8" text-anchor="middle">7 composable packages. One unified stack.</text>
      #{badges(["Elixir", "BEAM", "Autonomous", "AI Agents"], 430)}
      #{footer_url("agentjido.xyz")}
    </svg>
    """

    render_svg_to_png(svg)
  end

  defp generate_ecosystem_image do
    svg = """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{glow_filter()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)"/>
      #{decorative_circles()}
      #{border_frame()}
      <text x="600" y="180" font-family="system-ui, -apple-system, sans-serif" font-size="52" font-weight="bold" fill="#60a5fa" text-anchor="middle" filter="url(#glow)">Agent Jido</text>
      <text x="600" y="260" font-family="system-ui, -apple-system, sans-serif" font-size="40" font-weight="bold" fill="white" text-anchor="middle">Package Ecosystem</text>
      <text x="600" y="320" font-family="system-ui, -apple-system, sans-serif" font-size="24" fill="#94a3b8" text-anchor="middle">7 composable packages. 4 layers.</text>
      #{badges(["jido", "jido_ai", "jido_signal", "req_llm"], 410)}
      #{footer_url("agentjido.xyz/ecosystem")}
    </svg>
    """

    render_svg_to_png(svg)
  end

  defp generate_getting_started_image do
    generate_page_image(
      "Getting Started",
      "Build your first AI agent in minutes",
      "agentjido.xyz/getting-started"
    )
  end

  defp generate_examples_image do
    generate_page_image(
      "Examples & Tutorials",
      "Learn by building",
      "agentjido.xyz/examples"
    )
  end

  defp generate_training_image do
    generate_page_image(
      "Training",
      "Module-based curriculum for Elixir engineers",
      "agentjido.xyz/training"
    )
  end

  defp generate_features_image do
    generate_page_image(
      "Features",
      "BEAM-native capabilities for autonomous agents",
      "agentjido.xyz/features"
    )
  end

  defp generate_docs_image do
    generate_page_image(
      "Documentation",
      "Comprehensive guides and API reference",
      "agentjido.xyz/docs"
    )
  end

  defp generate_cookbook_image do
    generate_page_image(
      "Cookbook",
      "Practical recipes for common patterns",
      "agentjido.xyz/cookbook"
    )
  end

  defp generate_catalog_image do
    generate_page_image(
      "Discovery Catalog",
      "Browse actions, agents, sensors & skills",
      "agentjido.xyz/catalog"
    )
  end

  defp generate_blog_image do
    generate_page_image(
      "Blog",
      "Updates, tutorials, and insights",
      "agentjido.xyz/blog"
    )
  end

  defp generate_blog_post_image(slug) do
    post = AgentJido.Blog.get_post_by_id!(slug)
    title = svg_escape(truncate(post.title, 60))
    description = svg_escape(truncate(post.description, 90))

    svg = """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{glow_filter()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)"/>
      #{decorative_circles()}
      #{border_frame()}
      <text x="600" y="170" font-family="system-ui, -apple-system, sans-serif" font-size="48" font-weight="bold" fill="#60a5fa" text-anchor="middle" filter="url(#glow)">Agent Jido</text>
      <rect x="520" y="200" width="160" height="32" rx="16" fill="#22d3ee" fill-opacity="0.15"/>
      <text x="600" y="222" font-family="system-ui, -apple-system, sans-serif" font-size="16" fill="#22d3ee" text-anchor="middle">BLOG POST</text>
      <text x="600" y="310" font-family="system-ui, -apple-system, sans-serif" font-size="36" font-weight="bold" fill="white" text-anchor="middle">#{title}</text>
      <text x="600" y="370" font-family="system-ui, -apple-system, sans-serif" font-size="22" fill="#94a3b8" text-anchor="middle">#{description}</text>
      #{footer_url("agentjido.xyz/blog/#{svg_escape(slug)}")}
    </svg>
    """

    render_svg_to_png(svg)
  rescue
    _ -> generate_blog_image()
  end

  defp generate_page_image(title, subtitle, url) do
    escaped_title = svg_escape(title)
    escaped_subtitle = svg_escape(subtitle)
    escaped_url = svg_escape(url)

    svg = """
    <svg width="#{@image_width}" height="#{@image_height}" xmlns="http://www.w3.org/2000/svg">
      <defs>
        #{background_gradient()}
        #{glow_filter()}
      </defs>
      <rect width="#{@image_width}" height="#{@image_height}" fill="url(#bggrad)"/>
      #{decorative_circles()}
      #{border_frame()}
      <text x="600" y="200" font-family="system-ui, -apple-system, sans-serif" font-size="52" font-weight="bold" fill="#60a5fa" text-anchor="middle" filter="url(#glow)">Agent Jido</text>
      <text x="600" y="300" font-family="system-ui, -apple-system, sans-serif" font-size="40" font-weight="bold" fill="white" text-anchor="middle">#{escaped_title}</text>
      <text x="600" y="370" font-family="system-ui, -apple-system, sans-serif" font-size="24" fill="#94a3b8" text-anchor="middle">#{escaped_subtitle}</text>
      #{footer_url(escaped_url)}
    </svg>
    """

    render_svg_to_png(svg)
  end

  defp background_gradient do
    """
    <linearGradient id="bggrad" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#0c1222"/>
      <stop offset="50%" stop-color="#111827"/>
      <stop offset="100%" stop-color="#1e293b"/>
    </linearGradient>
    """
  end

  defp glow_filter do
    """
    <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="3" result="blur"/>
      <feMerge>
        <feMergeNode in="blur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
    """
  end

  defp decorative_circles do
    """
    <circle cx="100" cy="100" r="200" fill="#60a5fa" fill-opacity="0.03"/>
    <circle cx="1100" cy="530" r="250" fill="#22d3ee" fill-opacity="0.03"/>
    <circle cx="900" cy="80" r="120" fill="#60a5fa" fill-opacity="0.02"/>
    """
  end

  defp border_frame do
    """
    <rect x="20" y="20" width="#{@image_width - 40}" height="#{@image_height - 40}" rx="16" ry="16" fill="none" stroke="#60a5fa" stroke-opacity="0.15" stroke-width="1"/>
    """
  end

  defp footer_url(url) do
    """
    <line x1="200" y1="540" x2="1000" y2="540" stroke="#60a5fa" stroke-opacity="0.2" stroke-width="1"/>
    <text x="600" y="585" font-family="system-ui, -apple-system, sans-serif" font-size="20" fill="#60a5fa" fill-opacity="0.8" text-anchor="middle">#{url}</text>
    """
  end

  defp badges(items, y) do
    count = length(items)
    total_width = count * 150 + (count - 1) * 16
    start_x = (1200 - total_width) / 2

    items
    |> Enum.with_index()
    |> Enum.map(fn {label, i} ->
      x = start_x + i * 166
      escaped = svg_escape(label)

      """
      <rect x="#{x}" y="#{y}" width="150" height="40" rx="20" fill="#22d3ee" fill-opacity="0.1" stroke="#22d3ee" stroke-opacity="0.3" stroke-width="1"/>
      <text x="#{x + 75}" y="#{y + 26}" font-family="system-ui, -apple-system, sans-serif" font-size="16" fill="#22d3ee" text-anchor="middle">#{escaped}</text>
      """
    end)
    |> Enum.join("\n")
  end

  defp truncate(text, max_length) when is_binary(text) do
    if String.length(text) > max_length do
      String.slice(text, 0, max_length - 1) <> "…"
    else
      text
    end
  end

  defp truncate(nil, _max_length), do: ""
  defp truncate(text, max_length), do: truncate(to_string(text), max_length)
end
