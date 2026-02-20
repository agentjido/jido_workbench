defmodule AgentJidoWeb.Router do
  use AgentJidoWeb, :router

  import AgentJidoWeb.UserAuth
  import Phoenix.LiveDashboard.Router
  import JidoStudio.Router
  import ArcanaWeb.Router

  # Build page routes at compile time from the unified Pages system
  @page_routes (for page <- AgentJido.Pages.all_pages(),
                    route = AgentJido.Pages.route_for(page),
                    route != "/docs",
                    not String.starts_with?(route, "/training/") do
                  route
                end)
  @legacy_docs_routes AgentJido.Pages.docs_legacy_redirects()
  @admin_on_mount [
    {AgentJidoWeb.UserAuth, :require_authenticated},
    {AgentJidoWeb.UserAuth, :require_admin}
  ]

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {AgentJidoWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(:fetch_current_scope_for_user)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", AgentJidoWeb do
    pipe_through(:browser)

    live "/", JidoHomeLive, :index
    live "/ecosystem", JidoEcosystemLive, :index
    # Keep static route above /ecosystem/:id so this page never collides with package ids.
    live "/ecosystem/package-matrix", JidoEcosystemPackageMatrixLive, :index
    live "/ecosystem/:id", JidoEcosystemPackageLive, :show
    live "/getting-started", JidoGettingStartedLive, :index
    live "/examples", JidoExamplesLive, :index
    live "/examples/:slug", JidoExampleLive, :show

    live "/features", JidoFeaturesLive, :index
    get("/discord", PageController, :discord)

    # Pages system — index routes
    live "/docs", PageLive, :index
    live "/build", PageLive, :index
    live "/community", PageLive, :index

    # Docs legacy aliases redirect to canonical section routes.
    for {legacy_path, _canonical} <- @legacy_docs_routes do
      get legacy_path, PageController, :docs_legacy_redirect
    end

    # Pages system — compile-time show routes
    for route_path <- @page_routes do
      live route_path, PageLive, :show
    end

    get "/og/render/*path", OGImageController, :render

    live "/blog", BlogLive, :index
    live "/blog/tags/:tag", BlogLive, :tag
    get("/blog/search", BlogController, :search)
    live "/blog/:slug", BlogLive, :show
    get("/feed", BlogController, :feed)
    get("/sitemap.xml", SitemapController, :index)
  end

  if Application.compile_env(:agent_jido, :dev_routes) do
    scope "/dev" do
      pipe_through([:browser])
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end

  scope "/dev" do
    pipe_through([:browser, :require_authenticated_user, :require_admin_user])

    live_session :require_admin_user,
      on_mount: @admin_on_mount do
      live "/contentops", AgentJidoWeb.ContentOpsLive, :index
      live "/contentops/github", AgentJidoWeb.ContentOpsGithubLive, :index
    end

    live_dashboard("/dashboard",
      metrics: AgentJidoWeb.Telemetry,
      additional_pages: JidoLiveDashboard.pages(),
      on_mount: @admin_on_mount
    )

    jido_studio("/jido", host_app_js_path: "/assets/app.js", on_mount: @admin_on_mount)

    get("/arcana", AgentJidoWeb.PageController, :arcana_redirect)
    get("/arcana/*path", AgentJidoWeb.PageController, :arcana_redirect)
  end

  scope "/", AgentJidoWeb do
    pipe_through([:browser, :require_authenticated_user, :require_admin_user])

    live_session :admin_control_plane,
      on_mount: @admin_on_mount do
      live "/dashboard", AdminDashboardLive, :index
      live "/dashboard/chatops", ChatOpsLive, :index
    end
  end

  scope "/" do
    pipe_through([:browser, :require_authenticated_user, :require_admin_user])
    get("/assets/js/app.js", AgentJidoWeb.PageController, :arcana_legacy_app_js)
    arcana_dashboard("/arcana", repo: AgentJido.Repo, on_mount: @admin_on_mount)
  end

  ## Authentication routes

  scope "/", AgentJidoWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{AgentJidoWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", AgentJidoWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{AgentJidoWeb.UserAuth, :mount_current_scope}] do
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  scope "/", AgentJidoWeb do
    pipe_through :browser

    match :*, "/*path", PageController, :not_found
  end
end
