defmodule AgentJido.ContentIngest.InventoryTest do
  use ExUnit.Case, async: true

  alias AgentJido.Blog
  alias AgentJido.ContentIngest.Inventory
  alias AgentJido.ContentIngest.Source
  alias AgentJido.Ecosystem
  alias AgentJido.Pages

  describe "build/1" do
    test "returns all managed sources with unique ids" do
      sources = Inventory.build()

      expected_count =
        length(Pages.all_pages()) +
          length(Blog.all_posts()) +
          length(Ecosystem.public_packages())

      assert length(sources) == expected_count
      assert Enum.all?(sources, &match?(%Source{}, &1))

      source_ids = Enum.map(sources, & &1.source_id)
      assert length(source_ids) == length(Enum.uniq(source_ids))

      assert Enum.all?(sources, fn source ->
               source.metadata["managed_by"] == Inventory.managed_by()
             end)

      assert Enum.all?(sources, fn source ->
               hash = source.metadata["content_hash"]
               is_binary(hash) and byte_size(hash) == 64
             end)

      assert Enum.all?(sources, fn source ->
               source.text |> String.trim() |> byte_size() > 0
             end)
    end

    test "supports docs-only scope" do
      sources = Inventory.build(only: [:docs])

      assert length(sources) == length(Pages.all_pages())

      assert Enum.all?(sources, fn source ->
               String.starts_with?(source.source_id, "docs:") and source.collection == "site_docs"
             end)
    end
  end
end
