defmodule AgentJido.ContentGen.SelectionTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentGen.Selection

  describe "select/2" do
    test "filters by destination_collection/status/section and sorts deterministically" do
      entries = [
        entry(%{id: "docs/b", section: "docs", order: 30, status: :outline}),
        entry(%{id: "docs/a", section: "docs", order: 10, status: :outline}),
        entry(%{id: "build/a", section: "build", order: 20, status: :draft}),
        entry(%{id: "docs/published", section: "docs", order: 40, status: :published}),
        entry(%{id: "docs/not-pages", destination_collection: :training, order: 50, status: :outline}),
        entry(%{id: "docs/no-route", destination_route: nil, order: 60, status: :outline})
      ]

      selected =
        Selection.select(
          %{
            statuses: [:outline, :draft],
            sections: ["docs", "build"],
            max: 10
          },
          entries
        )

      assert Enum.map(selected, & &1.id) == ["build/a", "docs/a", "docs/b"]
    end

    test "supports explicit entry selection" do
      entries = [
        entry(%{id: "docs/one", status: :outline}),
        entry(%{id: "docs/two", status: :outline})
      ]

      selected = Selection.select(%{entry: "docs/two", statuses: [:outline], max: 10}, entries)
      assert Enum.map(selected, & &1.id) == ["docs/two"]
    end

    test "applies max limit" do
      entries =
        Enum.map(1..5, fn idx ->
          entry(%{
            id: "docs/#{idx}",
            order: idx,
            status: :outline
          })
        end)

      selected = Selection.select(%{statuses: [:outline], max: 2}, entries)
      assert length(selected) == 2
      assert Enum.map(selected, & &1.id) == ["docs/1", "docs/2"]
    end
  end

  defp entry(attrs) do
    Map.merge(
      %{
        id: "docs/test",
        section: "docs",
        order: 100,
        status: :outline,
        destination_collection: :pages,
        destination_route: "/docs/test"
      },
      attrs
    )
  end
end
