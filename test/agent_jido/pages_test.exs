defmodule AgentJido.PagesTest do
  use ExUnit.Case, async: true

  alias AgentJido.Pages
  alias AgentJido.Pages.Page
  alias AgentJido.Pages.MenuNode

  describe "all_pages/0" do
    test "returns a list of pages" do
      pages = Pages.all_pages()
      assert is_list(pages)
      assert length(pages) > 0
      assert Enum.all?(pages, &match?(%Page{}, &1))
    end

    test "pages are sorted by order" do
      pages = Pages.all_pages()
      orders = Enum.map(pages, & &1.order)
      assert orders == Enum.sort(orders)
    end

    test "excludes draft pages" do
      pages = Pages.all_pages()
      assert Enum.all?(pages, &(&1.draft == false))
    end
  end

  describe "all_tags/0" do
    test "returns a list of unique values" do
      tags = Pages.all_tags()
      assert is_list(tags)
      assert tags == Enum.uniq(tags)
    end
  end

  describe "all_categories/0" do
    test "returns a list of unique atoms" do
      categories = Pages.all_categories()
      assert is_list(categories)
      assert Enum.all?(categories, &is_atom/1)
      assert categories == Enum.uniq(categories)
    end

    test "includes docs and training categories" do
      categories = Pages.all_categories()
      assert :docs in categories
      assert :training in categories
    end
  end

  describe "docs hierarchy helpers" do
    test "returns docs sections from root section pages" do
      sections = Pages.docs_sections()

      assert Enum.map(sections, &Pages.route_for/1) == [
               "/docs/getting-started",
               "/docs/cookbook",
               "/docs/reference"
             ]
    end

    test "returns contextual section pages" do
      pages = Pages.docs_section_pages("reference")
      routes = Enum.map(pages, &Pages.route_for/1)

      assert "/docs/reference" in routes
      assert "/docs/reference/architecture" in routes
      assert "/docs/reference/production-readiness-checklist" in routes
      assert "/docs/reference/security-and-governance" in routes
      assert "/docs/reference/incident-playbooks" in routes
      refute "/docs/getting-started" in routes
    end

    test "extracts section slug from docs path" do
      assert Pages.docs_section_for_path("/docs") == nil
      assert Pages.docs_section_for_path("/docs/getting-started") == "getting-started"
      assert Pages.docs_section_for_path("/docs/getting-started/core-concepts") == "getting-started"
    end
  end

  describe "menu_tree/0" do
    test "returns a list of MenuNode structs" do
      tree = Pages.menu_tree()
      assert is_list(tree)
      assert Enum.all?(tree, &match?(%MenuNode{}, &1))
    end

    test "menu nodes have children as lists" do
      tree = Pages.menu_tree()

      Enum.each(tree, fn node ->
        assert is_list(node.children)
      end)
    end
  end

  describe "get_page_by_id/1" do
    test "returns page when found" do
      pages = Pages.all_pages()
      page = hd(pages)

      found = Pages.get_page_by_id(page.id)
      assert found == page
    end

    test "returns nil when not found" do
      assert Pages.get_page_by_id("nonexistent-page-id") == nil
    end
  end

  describe "get_page!/1" do
    test "returns page when found" do
      pages = Pages.all_pages()
      page = hd(pages)

      found = Pages.get_page!(page.id)
      assert found == page
    end

    test "raises NotFoundError when not found" do
      assert_raise Pages.NotFoundError, fn ->
        Pages.get_page!("nonexistent-page-id")
      end
    end
  end

  describe "get_page_by_path/1" do
    test "returns page when found" do
      pages = Pages.all_pages()
      page = hd(pages)

      found = Pages.get_page_by_path(page.path)
      assert found == page
    end

    test "returns nil when not found" do
      assert Pages.get_page_by_path("/nonexistent/path") == nil
    end
  end

  describe "pages_by_category/1" do
    test "returns pages for existing category" do
      categories = Pages.all_categories()
      category = hd(categories)

      pages = Pages.pages_by_category(category)
      assert is_list(pages)
      assert length(pages) > 0
      assert Enum.all?(pages, &(&1.category == category))
    end

    test "returns empty list for nonexistent category" do
      assert Pages.pages_by_category(:nonexistent_category) == []
    end
  end

  describe "pages_by_tag/1" do
    test "returns empty list for nonexistent tag" do
      assert Pages.pages_by_tag(:nonexistent_tag) == []
    end
  end

  describe "neighbors/1" do
    test "returns prev and next pages within same category" do
      training = Pages.pages_by_category(:training)

      if length(training) >= 3 do
        middle = Enum.at(training, 1)
        {prev, next} = Pages.neighbors(middle.id)

        assert prev == Enum.at(training, 0)
        assert next == Enum.at(training, 2)
      end
    end

    test "returns nil for prev on first page in category" do
      training = Pages.pages_by_category(:training)
      first = hd(training)
      {prev, _next} = Pages.neighbors(first.id)

      assert prev == nil
    end

    test "returns nil for next on last page in category" do
      training = Pages.pages_by_category(:training)
      last = List.last(training)
      {_prev, next} = Pages.neighbors(last.id)

      assert next == nil
    end
  end

  describe "breadcrumbs/1" do
    test "returns path segments for a page" do
      page = %Page{id: "test", path: "/docs/getting-started", title: "Test", category: :docs}
      crumbs = Pages.breadcrumbs(page)

      assert crumbs == ["docs", "getting-started"]
    end

    test "returns path segments for a string path" do
      crumbs = Pages.breadcrumbs("/docs/getting-started")
      assert crumbs == ["docs", "getting-started"]
    end

    test "handles empty path" do
      crumbs = Pages.breadcrumbs("")
      assert crumbs == []
    end
  end

  describe "route_for/1" do
    test "generates correct routes for docs" do
      page = %Page{
        id: "getting-started",
        path: "/docs/getting-started",
        title: "GS",
        category: :docs
      }

      assert Pages.route_for(page) == "/docs/getting-started"
    end

    test "generates correct routes for training" do
      page = %Page{
        id: "agent-fundamentals",
        path: "/training/agent-fundamentals",
        title: "AF",
        category: :training
      }

      assert Pages.route_for(page) == "/training/agent-fundamentals"
    end

    test "generates correct routes for features" do
      page = %Page{
        id: "reliability",
        path: "/features/reliability",
        title: "R",
        category: :features
      }

      assert Pages.route_for(page) == "/features/reliability"
    end
  end

  describe "page_count/0" do
    test "returns correct count" do
      assert Pages.page_count() == length(Pages.all_pages())
      assert Pages.page_count() > 0
    end
  end

  describe "docs IA stubs" do
    test "required docs IA pages exist and are routable" do
      required_paths = [
        "/docs/getting-started/core-concepts",
        "/docs/getting-started/guides",
        "/docs/reference",
        "/docs/reference/architecture",
        "/docs/reference/production-readiness-checklist",
        "/docs/reference/security-and-governance",
        "/docs/reference/incident-playbooks"
      ]

      Enum.each(required_paths, fn path ->
        page = Pages.get_page_by_path(path)

        assert page != nil
        assert page.category == :docs
        assert Pages.route_for(page) == path
      end)
    end

    test "legacy docs paths resolve to canonical docs pages" do
      legacy_to_canonical = %{
        "/docs/cookbook-index" => "/docs/cookbook",
        "/docs/core-concepts" => "/docs/getting-started/core-concepts",
        "/docs/guides" => "/docs/getting-started/guides",
        "/docs/chat-response" => "/docs/cookbook/chat-response",
        "/docs/tool-response" => "/docs/cookbook/tool-response",
        "/docs/weather-tool-response" => "/docs/cookbook/weather-tool-response",
        "/docs/architecture" => "/docs/reference/architecture",
        "/docs/production-readiness-checklist" => "/docs/reference/production-readiness-checklist",
        "/docs/security-and-governance" => "/docs/reference/security-and-governance",
        "/docs/incident-playbooks" => "/docs/reference/incident-playbooks"
      }

      Enum.each(legacy_to_canonical, fn {legacy_path, canonical_path} ->
        assert {:ok, legacy_page, :legacy} = Pages.resolve_page_for_path(legacy_path)
        assert legacy_page.path == canonical_path
      end)
    end
  end

  describe "training pages" do
    test "training pages have track and difficulty" do
      training = Pages.pages_by_category(:training)
      assert length(training) == 6

      Enum.each(training, fn page ->
        assert page.track != nil
        assert page.difficulty != nil
        assert page.duration_minutes != nil
      end)
    end

    test "training pages are sorted by order" do
      training = Pages.pages_by_category(:training)
      orders = Enum.map(training, & &1.order)
      assert orders == Enum.sort(orders)
    end
  end

  describe "features wave A content quality" do
    test "first three feature pages are published and routable" do
      target_paths = [
        "/features/reliability-by-architecture",
        "/features/multi-agent-coordination",
        "/features/operations-observability"
      ]

      Enum.each(target_paths, fn path ->
        page = Pages.get_page_by_path(path)

        assert page != nil
        assert page.category == :features
        assert page.draft == false
      end)
    end

    test "first three feature source files do not contain placeholder markers" do
      feature_files = [
        Path.expand("../../priv/pages/features/reliability-by-architecture.md", __DIR__),
        Path.expand("../../priv/pages/features/multi-agent-coordination.md", __DIR__),
        Path.expand("../../priv/pages/features/operations-observability.md", __DIR__)
      ]

      placeholder_patterns = [
        ~r/content coming soon/i,
        ~r/\bcoming soon\b/i,
        ~r/\bTODO\b/,
        ~r/\bTBD\b/,
        ~r/lorem ipsum/i
      ]

      Enum.each(feature_files, fn file ->
        body = File.read!(file)

        assert body =~ "draft: false"

        Enum.each(placeholder_patterns, fn pattern ->
          refute body =~ pattern
        end)
      end)
    end
  end

  describe "features wave B content quality" do
    test "remaining four feature pages are published and routable" do
      target_paths = [
        "/features/incremental-adoption",
        "/features/beam-for-ai-builders",
        "/features/jido-vs-framework-first-stacks",
        "/features/executive-brief"
      ]

      Enum.each(target_paths, fn path ->
        page = Pages.get_page_by_path(path)

        assert page != nil
        assert page.category == :features
        assert page.draft == false
      end)
    end

    test "remaining four feature source files do not contain placeholder markers" do
      feature_files = [
        Path.expand("../../priv/pages/features/incremental-adoption.md", __DIR__),
        Path.expand("../../priv/pages/features/beam-for-ai-builders.md", __DIR__),
        Path.expand("../../priv/pages/features/jido-vs-framework-first-stacks.md", __DIR__),
        Path.expand("../../priv/pages/features/executive-brief.md", __DIR__)
      ]

      placeholder_patterns = [
        ~r/content coming soon/i,
        ~r/\bcoming soon\b/i,
        ~r/\bTODO\b/,
        ~r/\bTBD\b/,
        ~r/lorem ipsum/i
      ]

      Enum.each(feature_files, fn file ->
        body = File.read!(file)

        assert body =~ "draft: false"

        Enum.each(placeholder_patterns, fn pattern ->
          refute body =~ pattern
        end)
      end)
    end

    test "features section includes all seven published feature pages" do
      expected_paths = [
        "/features/reliability-by-architecture",
        "/features/multi-agent-coordination",
        "/features/operations-observability",
        "/features/incremental-adoption",
        "/features/beam-for-ai-builders",
        "/features/jido-vs-framework-first-stacks",
        "/features/executive-brief"
      ]

      features = Pages.pages_by_category(:features)
      assert length(features) == length(expected_paths)

      feature_paths = Enum.map(features, & &1.path)

      Enum.each(expected_paths, fn path ->
        assert path in feature_paths
      end)
    end
  end

  describe "build wave A content quality" do
    test "wave A build pages are published and routable" do
      target_pages = [
        {"/build", "/build/build"},
        {"/build/quickstarts-by-persona", "/build/quickstarts-by-persona"},
        {"/build/reference-architectures", "/build/reference-architectures"}
      ]

      Enum.each(target_pages, fn {path, expected_route} ->
        page = Pages.get_page_by_path(path)

        assert page != nil
        assert page.category == :build
        assert page.draft == false
        assert Pages.route_for(page) == expected_route
      end)
    end

    test "wave A build source files do not contain placeholder markers" do
      build_files = [
        Path.expand("../../priv/pages/build/index.md", __DIR__),
        Path.expand("../../priv/pages/build/quickstarts-by-persona.md", __DIR__),
        Path.expand("../../priv/pages/build/reference-architectures.md", __DIR__)
      ]

      placeholder_patterns = [
        ~r/content coming soon/i,
        ~r/\bcoming soon\b/i,
        ~r/\bTODO\b/,
        ~r/\bTBD\b/,
        ~r/lorem ipsum/i
      ]

      Enum.each(build_files, fn file ->
        body = File.read!(file)

        assert body =~ "draft: false"

        Enum.each(placeholder_patterns, fn pattern ->
          refute body =~ pattern
        end)
      end)
    end
  end

  describe "build wave B content quality" do
    test "remaining build pages are published and routable" do
      target_pages = [
        {"/build/mixed-stack-integration", "/build/mixed-stack-integration"},
        {"/build/product-feature-blueprints", "/build/product-feature-blueprints"}
      ]

      Enum.each(target_pages, fn {path, expected_route} ->
        page = Pages.get_page_by_path(path)

        assert page != nil
        assert page.category == :build
        assert page.draft == false
        assert Pages.route_for(page) == expected_route
      end)
    end

    test "remaining build source files do not contain placeholder markers" do
      build_files = [
        Path.expand("../../priv/pages/build/mixed-stack-integration.md", __DIR__),
        Path.expand("../../priv/pages/build/product-feature-blueprints.md", __DIR__)
      ]

      placeholder_patterns = [
        ~r/content coming soon/i,
        ~r/\bcoming soon\b/i,
        ~r/\bTODO\b/,
        ~r/\bTBD\b/,
        ~r/lorem ipsum/i
      ]

      Enum.each(build_files, fn file ->
        body = File.read!(file)

        assert body =~ "draft: false"

        Enum.each(placeholder_patterns, fn pattern ->
          refute body =~ pattern
        end)
      end)
    end
  end

  describe "community content quality" do
    test "community pages are published and routable" do
      target_pages = [
        {"/community", "/community/community"},
        {"/community/learning-paths", "/community/learning-paths"},
        {"/community/adoption-playbooks", "/community/adoption-playbooks"},
        {"/community/case-studies", "/community/case-studies"}
      ]

      Enum.each(target_pages, fn {path, expected_route} ->
        page = Pages.get_page_by_path(path)

        assert page != nil
        assert page.category == :community
        assert page.draft == false
        assert Pages.route_for(page) == expected_route
      end)
    end

    test "community source files do not contain placeholder markers" do
      community_files = [
        Path.expand("../../priv/pages/community/index.md", __DIR__),
        Path.expand("../../priv/pages/community/learning-paths.md", __DIR__),
        Path.expand("../../priv/pages/community/adoption-playbooks.md", __DIR__),
        Path.expand("../../priv/pages/community/case-studies.md", __DIR__)
      ]

      placeholder_patterns = [
        ~r/content coming soon/i,
        ~r/\bcoming soon\b/i,
        ~r/\bTODO\b/,
        ~r/\bTBD\b/,
        ~r/lorem ipsum/i
      ]

      Enum.each(community_files, fn file ->
        body = File.read!(file)

        assert body =~ "draft: false"

        Enum.each(placeholder_patterns, fn pattern ->
          refute body =~ pattern
        end)
      end)
    end
  end
end
