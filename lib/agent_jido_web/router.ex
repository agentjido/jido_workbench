defmodule AgentJidoWeb.Router do
  use AgentJidoWeb, :router
  import JidoStudio.Router
  import ArcanaWeb.Router

  # Build page routes at compile time from the unified Pages system
  @page_routes (for page <- AgentJido.Pages.all_pages() do
                  AgentJido.Pages.route_for(page)
                end)

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
    live "/ecosystem/:id", JidoEcosystemPackageLive, :show
    live "/getting-started", JidoGettingStartedLive, :index
    live "/examples", JidoExamplesLive, :index
    live "/examples/:slug", JidoExampleLive, :show
    live "/contentops", ContentOpsLive, :index
    live "/contentops/github", ContentOpsGithubLive, :index
    live "/features", JidoFeaturesLive, :index
    live "/partners", JidoFeaturesLive, :index
    get("/discord", PageController, :discord)

    # Pages system — index routes
    live "/docs", PageLive, :index
    live "/training", PageLive, :index
    live "/build", PageLive, :index
    live "/community", PageLive, :index

    # Pages system — compile-time show routes
    for route_path <- @page_routes do
      live route_path, PageLive, :show
    end

    get "/og/default.png", OGImageController, :default
    get "/og/home.png", OGImageController, :home
    get "/og/ecosystem.png", OGImageController, :ecosystem
    get "/og/getting-started.png", OGImageController, :getting_started
    get "/og/examples.png", OGImageController, :examples
    get "/og/features.png", OGImageController, :features
    get "/og/partners.png", OGImageController, :features
    get "/og/training.png", OGImageController, :training
    get "/og/docs.png", OGImageController, :docs
    get "/og/blog.png", OGImageController, :blog
    get "/og/blog/:slug", OGImageController, :blog_post

    get("/blog", BlogController, :index)
    get("/blog/tags/:tag", BlogController, :tag)
    get("/blog/search", BlogController, :search)
    get("/blog/:slug", BlogController, :show)
    get("/feed", BlogController, :feed)
    get("/sitemap.xml", SitemapController, :index)
  end

  if Application.compile_env(:agent_jido, :dev_routes) do
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
