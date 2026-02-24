defmodule AgentJido.LandingContentTest do
  use ExUnit.Case, async: true

  alias AgentJido.Ecosystem
  alias AgentJido.Ecosystem.Layering
  alias AgentJido.LandingContent

  describe "home_ecosystem_overview/1" do
    test "uses public packages and computes top-level totals" do
      overview = LandingContent.home_ecosystem_overview()
      public_packages = Ecosystem.public_packages()

      expected_layer_count =
        public_packages
        |> Enum.map(&Layering.layer_for/1)
        |> Enum.uniq()
        |> length()

      assert overview.package_count == length(public_packages)
      assert overview.layer_count == expected_layer_count
      assert is_list(overview.rows)
      assert overview.rows != []
    end

    test "returns rows in app, ai, core, foundation order" do
      overview = LandingContent.home_ecosystem_overview()
      public_packages = Ecosystem.public_packages()

      expected_order =
        [:app, :ai, :core, :foundation]
        |> Enum.filter(fn layer ->
          Enum.any?(public_packages, &(Layering.layer_for(&1) == layer))
        end)

      assert Enum.map(overview.rows, & &1.id) == expected_order
    end

    test "each row count matches grouped public packages by layer" do
      overview = LandingContent.home_ecosystem_overview()

      expected_counts =
        Ecosystem.public_packages()
        |> Enum.group_by(&Layering.layer_for/1)
        |> Map.new(fn {layer, packages} -> {layer, length(packages)} end)

      for row <- overview.rows do
        assert row.package_count == Map.get(expected_counts, row.id, 0)
        assert length(row.packages) == row.package_count
      end
    end

    test "chips are deterministic and honor max_chips limit" do
      first = LandingContent.home_ecosystem_overview(max_chips: 2)
      second = LandingContent.home_ecosystem_overview(max_chips: 2)

      assert first == second

      for row <- first.rows do
        assert row.chips != []
        assert length(row.chips) <= 2
      end
    end

    test "package entries include valid ecosystem paths and deterministic name order" do
      overview = LandingContent.home_ecosystem_overview()

      for row <- overview.rows do
        assert row.packages ==
                 Enum.sort_by(row.packages, fn package ->
                   String.downcase(package.name)
                 end)

        for package <- row.packages do
          assert is_binary(package.id)
          assert is_binary(package.name)
          assert package.path == "/ecosystem/#{package.id}"
          assert String.starts_with?(package.path, "/ecosystem/")
        end
      end
    end
  end
end
