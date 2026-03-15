defmodule AgentJido.LandingContent do
  @moduledoc """
  Thin adapter between Ecosystem package data and marketing landing pages.
  Maps ecosystem categories to display layers and builds the data
  structures the LiveViews need.
  """

  alias AgentJido.Ecosystem
  alias AgentJido.Ecosystem.Layering

  @home_default_scope :public
  @home_default_layer_order [:app, :ai, :core, :foundation]
  @home_default_max_chips 4
  @home_layer_chips %{
    app: ["adapters", "ops / runtime"],
    ai: ["cognition", "memory", "tool use"],
    core: ["agent core"],
    foundation: ["agent primitives", "llm foundation"]
  }

  @type home_ecosystem_package :: %{
          id: String.t(),
          name: String.t(),
          path: String.t()
        }

  @type home_ecosystem_row :: %{
          id: Layering.layer(),
          label: String.t(),
          package_count: non_neg_integer(),
          chips: [String.t()],
          packages: [home_ecosystem_package()]
        }

  @type home_ecosystem_overview :: %{
          package_count: non_neg_integer(),
          layer_count: non_neg_integer(),
          rows: [home_ecosystem_row()]
        }

  @doc """
  Returns grouped ecosystem summary data for the home page rows.

  ## Options

    * `:scope` - `:public` (default) or `:all`
    * `:layer_order` - ordered list of layers (default: app -> ai -> core -> foundation)
    * `:max_chips` - max tags/chips per row (default: 4)

  """
  @spec home_ecosystem_overview(keyword()) :: home_ecosystem_overview()
  def home_ecosystem_overview(opts \\ [])

  def home_ecosystem_overview(opts) when is_list(opts) do
    scope = Keyword.get(opts, :scope, @home_default_scope)
    layer_order = normalize_layer_order(Keyword.get(opts, :layer_order, @home_default_layer_order))
    max_chips = normalize_max_chips(Keyword.get(opts, :max_chips, @home_default_max_chips))
    packages = packages_for_scope(scope)
    packages_by_layer = Enum.group_by(packages, &Layering.layer_for/1)

    rows =
      layer_order
      |> Enum.map(fn layer ->
        layer_packages = Map.get(packages_by_layer, layer, [])

        %{
          id: layer,
          label: layer_label(layer),
          package_count: length(layer_packages),
          chips: layer_chips(layer, layer_packages, max_chips),
          packages: layer_package_rows(layer_packages)
        }
      end)
      |> Enum.reject(&(&1.package_count == 0))

    %{
      package_count: length(packages),
      layer_count: length(rows),
      rows: rows
    }
  end

  def home_ecosystem_overview(_opts), do: home_ecosystem_overview([])

  @spec packages() :: [map()]
  def packages, do: packages_from(Ecosystem.public_packages())

  @spec packages_from([map()]) :: [map()]
  def packages_from(ecosystem_packages) when is_list(ecosystem_packages) do
    Enum.map(ecosystem_packages, fn pkg ->
      %{
        id: pkg.id,
        name: pkg.name,
        desc: pkg.tagline,
        layer: Layering.layer_for(pkg),
        path: "/ecosystem/#{pkg.id}",
        links: build_links(pkg)
      }
    end)
  end

  @spec packages_by_layer(:all | Layering.layer()) :: [map()]
  def packages_by_layer(:all), do: packages()
  def packages_by_layer(layer), do: Enum.filter(packages(), &(&1.layer == layer))

  @spec package_count() :: non_neg_integer()
  def package_count do
    Ecosystem.public_packages()
    |> length()
  end

  @spec layer_count() :: non_neg_integer()
  def layer_count do
    packages()
    |> Enum.map(& &1.layer)
    |> Enum.uniq()
    |> length()
  end

  defp packages_for_scope(:all), do: Ecosystem.all_packages()
  defp packages_for_scope(:public), do: Ecosystem.public_packages()
  defp packages_for_scope(_scope), do: Ecosystem.public_packages()

  defp normalize_layer_order(order) when is_list(order) do
    order
    |> Enum.filter(&(&1 in @home_default_layer_order))
    |> Enum.uniq()
    |> case do
      [] -> @home_default_layer_order
      layers -> layers
    end
  end

  defp normalize_layer_order(_order), do: @home_default_layer_order

  defp normalize_max_chips(value) when is_integer(value) and value > 0, do: value
  defp normalize_max_chips(_value), do: @home_default_max_chips

  defp layer_label(:app), do: "App"
  defp layer_label(:ai), do: "AI"
  defp layer_label(:core), do: "Core"
  defp layer_label(:foundation), do: "Foundation"
  defp layer_label(other), do: other |> to_string() |> String.capitalize()

  defp layer_package_rows(layer_packages) do
    layer_packages
    |> Enum.map(fn pkg ->
      %{
        id: pkg.id,
        name: pkg.name,
        path: "/ecosystem/#{pkg.id}"
      }
    end)
    |> Enum.sort_by(&String.downcase(&1.name))
  end

  defp layer_chips(layer, layer_packages, max_chips) do
    @home_layer_chips
    |> Map.get(layer)
    |> case do
      chips when is_list(chips) and chips != [] ->
        Enum.take(chips, max_chips)

      _ ->
        tag_chips(layer_packages, max_chips)
    end
  end

  defp tag_chips(layer_packages, max_chips) do
    chips =
      layer_packages
      |> Enum.flat_map(&List.wrap(&1.tags))
      |> Enum.map(&normalize_tag/1)
      |> Enum.reject(&(&1 == ""))
      |> Enum.frequencies()
      |> Enum.sort_by(fn {tag, frequency} -> {-frequency, tag} end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.take(max_chips)

    if chips == [], do: ["ecosystem"], else: chips
  end

  defp normalize_tag(tag) when is_atom(tag), do: tag |> Atom.to_string() |> normalize_tag()

  defp normalize_tag(tag) when is_binary(tag) do
    normalized =
      tag
      |> String.trim()
      |> String.downcase()
      |> String.replace("_", " ")

    Map.get(tag_aliases(), normalized, normalized)
  end

  defp normalize_tag(_tag), do: ""

  defp tag_aliases do
    %{
      "opentelemetry" => "observability",
      "telemetry" => "observability",
      "tracing" => "observability",
      "discord" => "messaging",
      "slack" => "messaging",
      "telegram" => "messaging",
      "whatsapp" => "messaging",
      "chat" => "messaging"
    }
  end

  defp build_links(pkg) do
    %{}
    |> maybe_put("hex", pkg.hex_url)
    |> maybe_put("docs", pkg.hexdocs_url)
    |> maybe_put("github", pkg.github_url)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, val), do: Map.put(map, key, val)
end
