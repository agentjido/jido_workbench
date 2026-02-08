defmodule AgentJido.DocumentationTest do
  use ExUnit.Case, async: true

  alias AgentJido.Documentation
  alias AgentJido.Documentation.Document
  alias AgentJido.Documentation.MenuNode

  describe "all_documents/0" do
    test "returns a list of documents" do
      docs = Documentation.all_documents()
      assert is_list(docs)
      assert length(docs) > 0
      assert Enum.all?(docs, &match?(%Document{}, &1))
    end

    test "documents are sorted by order" do
      docs = Documentation.all_documents()
      orders = Enum.map(docs, & &1.order)
      assert orders == Enum.sort(orders)
    end

    test "excludes draft documents" do
      docs = Documentation.all_documents()
      assert Enum.all?(docs, &(&1.draft == false))
    end
  end

  describe "all_tags/0" do
    test "returns a list of unique atoms" do
      tags = Documentation.all_tags()
      assert is_list(tags)
      assert Enum.all?(tags, &is_atom/1)
      assert tags == Enum.uniq(tags)
    end
  end

  describe "all_categories/0" do
    test "returns a list of unique atoms" do
      categories = Documentation.all_categories()
      assert is_list(categories)
      assert Enum.all?(categories, &is_atom/1)
      assert categories == Enum.uniq(categories)
    end
  end

  describe "menu_tree/0" do
    test "returns a list of MenuNode structs" do
      tree = Documentation.menu_tree()
      assert is_list(tree)
      assert Enum.all?(tree, &match?(%MenuNode{}, &1))
    end

    test "menu nodes have children as lists" do
      tree = Documentation.menu_tree()

      Enum.each(tree, fn node ->
        assert is_list(node.children)
      end)
    end
  end

  describe "get_document_by_id/1" do
    test "returns document when found" do
      docs = Documentation.all_documents()
      doc = hd(docs)

      found = Documentation.get_document_by_id(doc.id)
      assert found == doc
    end

    test "returns nil when not found" do
      assert Documentation.get_document_by_id("nonexistent-doc-id") == nil
    end
  end

  describe "get_document_by_id!/1" do
    test "returns document when found" do
      docs = Documentation.all_documents()
      doc = hd(docs)

      found = Documentation.get_document_by_id!(doc.id)
      assert found == doc
    end

    test "raises NotFoundError when not found" do
      assert_raise Documentation.NotFoundError, fn ->
        Documentation.get_document_by_id!("nonexistent-doc-id")
      end
    end
  end

  describe "get_document_by_path/1" do
    test "returns document when found" do
      docs = Documentation.all_documents()
      doc = hd(docs)

      found = Documentation.get_document_by_path(doc.path)
      assert found == doc
    end

    test "returns nil when not found" do
      assert Documentation.get_document_by_path("/nonexistent/path") == nil
    end
  end

  describe "documents_by_category/1" do
    test "returns documents for existing category" do
      categories = Documentation.all_categories()
      category = hd(categories)

      docs = Documentation.documents_by_category(category)
      assert is_list(docs)
      assert length(docs) > 0
      assert Enum.all?(docs, &(&1.category == category))
    end

    test "returns empty list for nonexistent category" do
      assert Documentation.documents_by_category(:nonexistent_category) == []
    end
  end

  describe "documents_by_tag/1" do
    test "returns empty list for nonexistent tag" do
      assert Documentation.documents_by_tag(:nonexistent_tag) == []
    end
  end

  describe "neighbors/1" do
    test "returns prev and next documents" do
      docs = Documentation.all_documents()

      if length(docs) >= 3 do
        middle_doc = Enum.at(docs, 1)
        {prev, next} = Documentation.neighbors(middle_doc.id)

        assert prev == Enum.at(docs, 0)
        assert next == Enum.at(docs, 2)
      end
    end

    test "returns nil for prev on first document" do
      docs = Documentation.all_documents()
      first_doc = hd(docs)
      {prev, _next} = Documentation.neighbors(first_doc.id)

      assert prev == nil
    end

    test "returns nil for next on last document" do
      docs = Documentation.all_documents()
      last_doc = List.last(docs)
      {_prev, next} = Documentation.neighbors(last_doc.id)

      assert next == nil
    end
  end

  describe "breadcrumbs/1" do
    test "returns path segments for a document" do
      doc = %Document{path: "/cookbook/chat-response", title: "Test", category: :test}
      crumbs = Documentation.breadcrumbs(doc)

      assert crumbs == ["cookbook", "chat-response"]
    end

    test "returns path segments for a string path" do
      crumbs = Documentation.breadcrumbs("/docs/getting-started")
      assert crumbs == ["docs", "getting-started"]
    end

    test "handles empty path" do
      crumbs = Documentation.breadcrumbs("")
      assert crumbs == []
    end
  end

  describe "breadcrumbs_with_docs/1" do
    test "returns tuples with segment and optional doc" do
      docs = Documentation.all_documents()
      doc = hd(docs)

      crumbs = Documentation.breadcrumbs_with_docs(doc.path)
      assert is_list(crumbs)

      Enum.each(crumbs, fn {segment, maybe_doc} ->
        assert is_binary(segment)
        assert is_nil(maybe_doc) or match?(%Document{}, maybe_doc)
      end)
    end
  end
end
