defmodule AgentJidoWeb.PageLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AgentJido.Pages

  describe "home auth navigation" do
    test "does not render login link on the home page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      refute html =~ ~s(href="/users/log-in")
    end

    test "does not render login link on non-home public pages", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/docs")

      refute html =~ ~s(href="/users/log-in")
    end
  end

  describe "footer metadata" do
    test "marketing footer reflects legal and ecosystem updates", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/features")
      jido_version = AgentJidoWeb.Jido.Nav.jido_version()
      current_year = Date.utc_today().year

      assert html =~ "Apache License 2.0"
      assert html =~ "Copyright © 2025-#{current_year} Mike Hostetler"
      assert html =~ "Jido #{jido_version}"

      assert html =~ ~s(href="/ecosystem")
      assert html =~ ~s(href="https://llmdb.xyz")
      assert html =~ ~s(id="primary-nav-search-trigger")

      assert html =~ "jido"
      assert html =~ "jido_ai"
      assert html =~ "req_llm"
      refute html =~ "HexDocs"
      refute html =~ "LinkedIn"
      refute html =~ "YouTube"
      refute html =~ ~s(href="/training")
      refute html =~ ~s(href="/search")
    end

    test "docs footer includes legal/version row and edit link", %{conn: conn} do
      page =
        Pages.pages_by_category(:docs)
        |> Enum.find(fn doc -> not is_nil(doc.github_url) end)

      assert page != nil

      {:ok, _view, html} = live(conn, Pages.route_for(page))
      jido_version = AgentJidoWeb.Jido.Nav.jido_version()
      current_year = Date.utc_today().year

      assert html =~ "Edit this page"
      assert html =~ "Apache License 2.0"
      assert html =~ "Copyright © 2025-#{current_year} Mike Hostetler"
      assert html =~ "Jido #{jido_version}"
    end
  end

  describe "docs" do
    test "renders docs index page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/docs")

      assert html =~ "Jido Documentation"
      assert html =~ "Get Started"
    end

    test "renders docs show page", %{conn: conn} do
      page = Pages.pages_by_category(:docs) |> hd()
      route = Pages.route_for(page)
      {:ok, _view, html} = live(conn, route)

      assert html =~ page.title
    end

    test "smoke routes for required docs IA stubs", %{conn: conn} do
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

        {:ok, _view, html} = live(conn, path)
        assert html =~ page.title
      end)
    end

    test "legacy docs routes redirect permanently to canonical section routes", %{conn: conn} do
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

      Enum.each(legacy_to_canonical, fn {legacy, canonical} ->
        redirected_conn = get(recycle(conn), legacy)
        assert redirected_to(redirected_conn, 301) == canonical
      end)
    end
  end

  describe "disabled public routes" do
    test "training index route returns 404", %{conn: conn} do
      conn = get(conn, "/training")
      assert response(conn, 404)
    end

    test "training detail routes return 404", %{conn: conn} do
      training_page = Pages.pages_by_category(:training) |> hd()
      training_path = Pages.route_for(training_page)

      conn = get(conn, training_path)
      assert response(conn, 404)
    end

    test "search route returns 404", %{conn: conn} do
      conn = get(conn, "/search")
      assert response(conn, 404)
    end
  end

  describe "features wave A pages" do
    test "smoke routes for first three feature pages", %{conn: conn} do
      target_routes = [
        {"/features/reliability-by-architecture", "Jido treats reliability as a runtime design concern"},
        {"/features/multi-agent-coordination", "Jido models multi-agent coordination as explicit runtime contracts"},
        {"/features/operations-observability", "Jido is designed for teams that need to run agents after launch"}
      ]

      Enum.each(target_routes, fn {path, expected_copy} ->
        page = Pages.get_page_by_path(path)
        assert page != nil

        {:ok, _view, html} = live(conn, path)

        assert html =~ expected_copy
        assert html =~ "Get Building"
        refute html =~ "Content coming soon."
      end)
    end
  end

  describe "features wave B pages" do
    test "smoke routes for remaining four feature pages", %{conn: conn} do
      target_routes = [
        {"/features/incremental-adoption", "You do not need a rewrite to adopt Jido"},
        {"/features/beam-for-ai-builders", "If your team is evaluating Jido from Python or TypeScript"},
        {"/features/jido-vs-framework-first-stacks", "This comparison is about operating model fit, not vendor ranking"},
        {"/features/executive-brief", "This page is for engineering managers, CTOs, and architecture leads evaluating"}
      ]

      Enum.each(target_routes, fn {path, expected_copy} ->
        page = Pages.get_page_by_path(path)
        assert page != nil

        {:ok, _view, html} = live(conn, path)

        assert html =~ expected_copy
        assert html =~ "Get Building"
        refute html =~ "Content coming soon."
      end)
    end
  end

  describe "build wave A pages" do
    test "renders /build index with wave A cards and no placeholder copy", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/build")

      assert html =~ "Build"
      assert html =~ "Build with Jido"
      assert html =~ "Quickstarts by Persona"
      assert html =~ "Reference Architectures"
      refute html =~ "Content coming soon."
    end

    test "smoke routes for wave A build pages", %{conn: conn} do
      target_pages = [
        {"/build", "Build is where you convert Jido concepts"},
        {"/build/quickstarts-by-persona", "Use this page as a routing layer"},
        {"/build/reference-architectures", "Reference architectures let you choose runtime boundaries"}
      ]

      Enum.each(target_pages, fn {path, expected_copy} ->
        page = Pages.get_page_by_path(path)
        assert page != nil

        {:ok, _view, html} = live(conn, Pages.route_for(page))

        assert html =~ expected_copy
        assert html =~ "Get Building"
        refute html =~ "Content coming soon."
      end)
    end
  end

  describe "build wave B pages" do
    test "smoke routes for remaining build pages", %{conn: conn} do
      target_pages = [
        {"/build/mixed-stack-integration", "Mixed-stack integration works when Jido owns orchestration"},
        {"/build/product-feature-blueprints", "Product feature blueprints convert fuzzy requirements into shippable milestones"}
      ]

      Enum.each(target_pages, fn {path, expected_copy} ->
        page = Pages.get_page_by_path(path)
        assert page != nil

        {:ok, _view, html} = live(conn, path)

        assert html =~ expected_copy
        assert html =~ "Get Building"
        refute html =~ "Content coming soon."
      end)
    end
  end

  describe "community pages" do
    test "renders /community index with section cards and no placeholder copy", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/community")

      assert html =~ "Community"
      assert html =~ "Learning Paths"
      assert html =~ "Adoption Playbooks"
      assert html =~ "Case Studies"
      refute html =~ "Content coming soon."
    end

    test "smoke routes for all four community pages", %{conn: conn} do
      target_pages = [
        {"/community", "Community is where implementation experience gets turned into reusable playbooks."},
        {"/community/learning-paths", "Learning paths reduce random exploration by pairing one objective with one proof checkpoint."},
        {"/community/adoption-playbooks", "Adoption playbooks are decision records, not slide decks."},
        {"/community/case-studies", "Each case study in this page has explicit publication permission for this repository."}
      ]

      Enum.each(target_pages, fn {path, expected_copy} ->
        page = Pages.get_page_by_path(path)
        assert page != nil

        {:ok, _view, html} = live(conn, Pages.route_for(page))

        assert html =~ expected_copy
        assert html =~ "Get Building"
        refute html =~ "Content coming soon."
      end)
    end
  end
end
