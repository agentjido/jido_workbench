defmodule AgentJidoWeb.Router do
  use AgentJidoWeb, :router
  import JidoStudio.Router
  import ArcanaWeb.Router

  # Build documentation routes at compile time
  # @menu_tree AgentJido.Documentation.menu_tree()

  @doc_routes [
                {"/docs", JidoDocsLive, :index, %{}},
                {"/cookbook", LivebookDemoLive, :index, %{tag: :cookbook}}
              ] ++
                ((for doc <- AgentJido.Documentation.all_documents() do
                    path_without_category =
                      case String.trim_leading(doc.path, "/") |> String.split("/", parts: 2) do
                        [_category, rest] -> rest
                        _ -> nil
                      end

                    if path_without_category do
                      case doc.category do
                        :docs ->
                          {"/docs/#{path_without_category}", JidoDocsLive, :show, %{}}

                        :cookbook ->
                          {"/cookbook/#{path_without_category}", LivebookDemoLive, :show, %{tag: :cookbook}}

                        _ ->
                          nil
                      end
                    end
                  end)
                 |> Enum.reject(&is_nil/1))

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {AgentJidoWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", AgentJidoWeb do
    pipe_through(:browser)

    live "/", JidoHomeLive, :index
    live "/ecosystem", JidoEcosystemLive, :index
    live "/getting-started", JidoGettingStartedLive, :index
    live "/examples", JidoExamplesLive, :index
    live "/benchmarks", JidoBenchmarksLive, :index
    live "/partners", JidoPartnersLive, :index
    get("/discord", PageController, :discord)

    get "/og/default.png", OGImageController, :default
    get "/og/home.png", OGImageController, :home
    get "/og/ecosystem.png", OGImageController, :ecosystem
    get "/og/getting-started.png", OGImageController, :getting_started
    get "/og/examples.png", OGImageController, :examples
    get "/og/benchmarks.png", OGImageController, :benchmarks
    get "/og/partners.png", OGImageController, :partners
    get "/og/docs.png", OGImageController, :docs
    get "/og/cookbook.png", OGImageController, :cookbook
    get "/og/catalog.png", OGImageController, :catalog
    get "/og/blog.png", OGImageController, :blog
    get "/og/blog/:slug", OGImageController, :blog_post

    get("/blog", BlogController, :index)
    get("/blog/tags/:tag", BlogController, :tag)
    get("/blog/search", BlogController, :search)
    get("/blog/:slug", BlogController, :show)
    get("/feed", BlogController, :feed)
    get("/sitemap.xml", SitemapController, :index)

    for {path, live_view, action, metadata} <- @doc_routes do
      live path, live_view, action, metadata: metadata
    end

    # Jido Catalog
    live("/catalog", CatalogLive, :index)
    live("/catalog/actions", CatalogActionsLive, :index)
    live("/catalog/actions/:slug", CatalogActionsLive, :show)
    live("/catalog/agents", CatalogAgentsLive, :index)
    live("/catalog/sensors", CatalogSensorsLive, :index)
    live("/catalog/skills", CatalogSkillsLive, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", AgentJidoWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development

  if Application.compile_env(:agent_jido, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: AgentJidoWeb.Telemetry, additional_pages: JidoLiveDashboard.pages())
      jido_studio("/jido", host_app_js_path: "/assets/app.js")
      forward("/mailbox", Plug.Swoosh.MailboxPreview)

      arcana_dashboard("/arcana", repo: AgentJido.Repo)
    end
  end
end
