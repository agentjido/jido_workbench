defmodule AgentJidoWeb.PageLiveTest do
  use AgentJidoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias AgentJido.Pages

  describe "home auth navigation" do
    test "does not render login link on the home page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      refute html =~ ~s(href="/users/log-in")
    end

    test "renders login link on non-home public pages", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/docs")

      assert html =~ ~s(href="/users/log-in")
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
        "/docs/core-concepts",
        "/docs/guides",
        "/docs/reference",
        "/docs/architecture",
        "/docs/production-readiness-checklist",
        "/docs/security-and-governance",
        "/docs/incident-playbooks"
      ]

      Enum.each(required_paths, fn path ->
        page = Pages.get_page_by_path(path)
        assert page != nil

        {:ok, _view, html} = live(conn, path)
        assert html =~ page.title
      end)
    end
  end

  describe "training" do
    test "renders training index page with curriculum modules", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/training")

      assert html =~ "TRAINING TRACK"
      assert html =~ "Practical Jido training for"

      for page <- Pages.pages_by_category(:training) do
        assert html =~ page.title
      end
    end

    test "renders training detail page", %{conn: conn} do
      page = Pages.pages_by_category(:training) |> hd()
      route = Pages.route_for(page)
      {:ok, _view, html} = live(conn, route)

      assert html =~ page.title
      assert html =~ "LEARNING OUTCOMES"
    end

    test "training detail has previous/next navigation", %{conn: conn} do
      training = Pages.pages_by_category(:training)

      if length(training) >= 3 do
        middle = Enum.at(training, 1)
        route = Pages.route_for(middle)
        {:ok, _view, html} = live(conn, route)

        assert html =~ "Previous Module"
        assert html =~ "Next Module"
      end
    end
  end

  describe "features wave A pages" do
    test "smoke routes for first three feature pages", %{conn: conn} do
      target_routes = [
        {"/features/reliability-by-architecture", "Jido treats reliability as an architectural constraint"},
        {"/features/multi-agent-coordination", "Jido models multi-agent behavior as explicit coordination contracts"},
        {"/features/operations-observability", "The router mounts LiveDashboard with Jido runtime pages enabled"}
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
        {"/features/beam-for-ai-builders", "AI builders often hit runtime limits before model limits"},
        {"/features/jido-vs-framework-first-stacks", "This comparison is about operating model, not brand ranking"},
        {"/features/executive-brief", "Jido is a runtime for reliable, multi-agent systems"}
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
