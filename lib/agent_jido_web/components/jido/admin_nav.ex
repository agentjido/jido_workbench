defmodule AgentJidoWeb.Jido.AdminNav do
  @moduledoc """
  Shared authenticated utility bar and admin control-plane navigation shell.
  """
  use AgentJidoWeb, :html

  alias AgentJido.Accounts
  alias Phoenix.LiveView.JS

  @core_links [
    %{label: "Dashboard", path: "/dashboard", kind: :navigate},
    %{label: "Analytics", path: "/dashboard/analytics", kind: :navigate},
    %{label: "Content Ingestion", path: "/dashboard/content-ingestion", kind: :navigate},
    %{label: "ContentOps", path: "/dashboard/contentops", kind: :navigate},
    %{label: "ContentOps GitHub", path: "/dashboard/contentops/github", kind: :navigate},
    %{label: "Content Generator", path: "/dashboard/content-generator", kind: :navigate},
    %{label: "Blog", path: "/dashboard/blog", kind: :navigate},
    %{label: "ChatOps", path: "/dashboard/chatops", kind: :navigate}
  ]

  @external_links [
    %{label: "Arcana", path: "/arcana", kind: :href},
    %{label: "Jido Studio", path: "/dev/jido", kind: :href}
  ]

  attr :current_scope, :any, default: nil

  @spec utility_top_bar(map()) :: Phoenix.LiveView.Rendered.t()
  def utility_top_bar(assigns) do
    current_user = current_user(assigns.current_scope)

    assigns =
      assigns
      |> assign(:current_user, current_user)
      |> assign(:is_admin, Accounts.admin?(current_user))

    ~H"""
    <div :if={@current_user} id="logged-in-utility-bar" class="border-b border-border/70 bg-background/70 backdrop-blur-sm">
      <div class="container mx-auto flex max-w-[1200px] items-center justify-between gap-4 px-4 py-1.5 text-[11px] text-muted-foreground sm:px-6">
        <p class="min-w-0 truncate">
          Signed in as <span class="font-medium text-foreground/90">{@current_user.email}</span>
        </p>
        <nav class="flex items-center gap-3">
          <.link
            :if={@is_admin}
            navigate="/dashboard"
            class="font-medium text-muted-foreground transition-colors hover:text-foreground"
          >
            Dashboard
          </.link>
          <.link
            navigate="/users/settings"
            class="font-medium text-muted-foreground transition-colors hover:text-foreground"
          >
            Settings
          </.link>
          <.form for={%{}} as={:logout} action="/users/log-out" method="post" class="inline">
            <input type="hidden" name="_method" value="delete" />
            <button type="submit" class="font-medium text-muted-foreground transition-colors hover:text-foreground">
              Logout
            </button>
          </.form>
        </nav>
      </div>
    </div>
    """
  end

  attr :current_path, :string, required: true
  slot :inner_block, required: true

  @spec admin_shell(map()) :: Phoenix.LiveView.Rendered.t()
  def admin_shell(assigns) do
    assigns =
      assigns
      |> assign(:core_links, @core_links)
      |> assign(:external_links, @external_links)

    ~H"""
    <div id="admin-shell" class="mx-auto w-full max-w-[1420px] px-4 py-6 sm:px-6 lg:px-8">
      <div class="mb-4 flex items-center justify-between lg:hidden">
        <button
          id="admin-mobile-menu-trigger"
          type="button"
          phx-click={open_drawer()}
          class="inline-flex items-center gap-2 rounded-md border border-border bg-card px-3 py-2 text-xs font-semibold text-foreground transition-colors hover:border-primary/50"
        >
          <.icon name="hero-bars-3" class="h-4 w-4" /> Menu
        </button>
      </div>

      <div class="flex min-h-0 items-start gap-6">
        <aside id="admin-sidebar" class="sticky top-20 hidden w-64 shrink-0 lg:block">
          <div class="space-y-6 rounded-lg border border-border bg-card p-4">
            <.nav_section title="Control Plane" links={@core_links} current_path={@current_path} />
            <.nav_section title="External Tools" links={@external_links} current_path={@current_path} />
          </div>
        </aside>

        <main id="admin-shell-content" class="min-w-0 flex-1">
          {render_slot(@inner_block)}
        </main>
      </div>
    </div>

    <div
      id="admin-mobile-overlay"
      class="fixed inset-0 z-[70] hidden bg-background/75 backdrop-blur-sm lg:hidden"
      phx-click={close_drawer()}
      aria-hidden="true"
    >
    </div>

    <aside
      id="admin-mobile-drawer"
      class="fixed inset-y-0 left-0 z-[80] hidden w-[280px] border-r border-border bg-card p-4 shadow-2xl lg:hidden"
      aria-label="Admin navigation drawer"
    >
      <div class="mb-4 flex items-center justify-between">
        <p class="text-xs font-semibold uppercase tracking-[0.12em] text-primary">Admin Navigation</p>
        <button
          id="admin-mobile-menu-close"
          type="button"
          phx-click={close_drawer()}
          class="rounded-md border border-border p-2 text-muted-foreground transition-colors hover:text-foreground"
          aria-label="Close menu"
        >
          <.icon name="hero-x-mark" class="h-4 w-4" />
        </button>
      </div>

      <div class="space-y-6">
        <.nav_section
          title="Control Plane"
          links={@core_links}
          current_path={@current_path}
          mobile?={true}
        />
        <.nav_section
          title="External Tools"
          links={@external_links}
          current_path={@current_path}
          mobile?={true}
        />
      </div>
    </aside>
    """
  end

  attr :title, :string, required: true
  attr :links, :list, required: true
  attr :current_path, :string, required: true
  attr :mobile?, :boolean, default: false

  defp nav_section(assigns) do
    ~H"""
    <section>
      <h2 class="mb-2 text-[10px] font-semibold uppercase tracking-[0.12em] text-muted-foreground">{@title}</h2>
      <div class="space-y-1">
        <%= for link <- @links do %>
          <.admin_nav_link link={link} current_path={@current_path} mobile?={@mobile?} />
        <% end %>
      </div>
    </section>
    """
  end

  attr :link, :map, required: true
  attr :current_path, :string, required: true
  attr :mobile?, :boolean, default: false

  defp admin_nav_link(assigns) do
    active? = active_path?(assigns.current_path, assigns.link.path)

    assigns =
      assigns
      |> assign(:active?, active?)
      |> assign(
        :base_class,
        "block rounded-md border px-3 py-2 text-xs font-semibold transition-colors " <>
          if active? do
            "border-primary/40 bg-primary/10 text-primary"
          else
            "border-transparent text-muted-foreground hover:border-border hover:bg-background hover:text-foreground"
          end
      )

    ~H"""
    <%= if @link.kind == :navigate do %>
      <.link
        navigate={@link.path}
        phx-click={if @mobile?, do: close_drawer(), else: nil}
        class={@base_class}
        data-admin-nav-path={@link.path}
        data-admin-nav-active={to_string(@active?)}
      >
        {@link.label}
      </.link>
    <% else %>
      <.link
        href={@link.path}
        phx-click={if @mobile?, do: close_drawer(), else: nil}
        class={@base_class}
        data-admin-nav-path={@link.path}
        data-admin-nav-active={to_string(@active?)}
      >
        {@link.label}
      </.link>
    <% end %>
    """
  end

  defp active_path?(current_path, target_path) do
    (current_path || "/") == target_path
  end

  defp current_user(%{user: user}), do: user
  defp current_user(_scope), do: nil

  defp open_drawer do
    JS.show(
      to: "#admin-mobile-overlay",
      transition: {"transition-opacity ease-out duration-200", "opacity-0", "opacity-100"}
    )
    |> JS.show(
      to: "#admin-mobile-drawer",
      transition: {"transition-all ease-out duration-200", "-translate-x-4 opacity-0", "translate-x-0 opacity-100"}
    )
  end

  defp close_drawer do
    JS.hide(
      to: "#admin-mobile-drawer",
      transition: {"transition-all ease-in duration-150", "translate-x-0 opacity-100", "-translate-x-4 opacity-0"}
    )
    |> JS.hide(
      to: "#admin-mobile-overlay",
      transition: {"transition-opacity ease-in duration-150", "opacity-100", "opacity-0"}
    )
  end
end
