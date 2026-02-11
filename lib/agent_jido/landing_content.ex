defmodule AgentJido.LandingContent do
  @moduledoc """
  Thin adapter between Ecosystem package data and marketing landing pages.
  Maps ecosystem categories to display layers and builds the data
  structures the LiveViews need.
  """

  alias AgentJido.Ecosystem
  alias AgentJido.Ecosystem.Layering

  def packages, do: packages_from(Ecosystem.public_packages())

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

  def packages_by_layer(:all), do: packages()
  def packages_by_layer(layer), do: Enum.filter(packages(), &(&1.layer == layer))

  def package_count do
    Ecosystem.public_packages()
    |> length()
  end

  def layer_count do
    packages()
    |> Enum.map(& &1.layer)
    |> Enum.uniq()
    |> length()
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
