defmodule JidoWorkbenchWeb.Router do
  use JidoWorkbenchWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {JidoWorkbenchWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(JidoWorkbenchWeb.Plugs.LLMKeysPlug)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", JidoWorkbenchWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
    # live("/settings", SettingsLive, :index)
    # get("/settings/clear", LLMKeyController, :clear_session)
    # post("/settings/save", LLMKeyController, :save_settings)

    # live("/jido", JidoLive, :index)
    # live("/jido2", JidoLive2, :index)
    # live("/team", TeamLive, :index)

    # Examples
    live("/examples", LivebookDemoLive, :index, metadata: %{tag: :examples})
    live("/examples/:demo_id", LivebookDemoLive, :index, metadata: %{tag: :examples})

    live("/docs", LivebookDemoLive, :index, metadata: %{tag: :docs})
    live("/docs/:demo_id", LivebookDemoLive, :index, metadata: %{tag: :docs})

    # Jido Catalog
    live("/catalog", CatalogLive, :index)
    live("/catalog/actions", CatalogActionsLive, :index)
    live("/catalog/agents", CatalogAgentsLive, :index)
    live("/catalog/sensors", CatalogSensorsLive, :index)
    live("/catalog/skills", CatalogSkillsLive, :index)

    # # Jido Demos
    # live("/demo", DemoIndexLive, :index, metadata: %{tag: :demo})
    # live("/demo/:demo_id", DemoShowLive, :index)

    # Petal Boilerplate Helpers
    # live("/form", FormLive, :index)
    # live("/live", PageLive, :index)
    # live("/live/modal/:size", PageLive, :modal)
    # live("/live/slide_over/:origin", PageLive, :slide_over)
    # live("/live/pagination/:page", PageLive, :pagination)
  end

  # Other scopes may use custom stacks.
  # scope "/api", JidoWorkbenchWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:jido_workbench, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: JidoWorkbenchWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
