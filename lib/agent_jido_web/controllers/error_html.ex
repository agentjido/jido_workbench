defmodule AgentJidoWeb.ErrorHTML do
  use AgentJidoWeb, :html

  def render("404.html", assigns) do
    assigns =
      assigns
      |> Map.put(:request_path, request_path(assigns))
      |> Map.put_new(:__changed__, nil)

    ~H"""
    <AgentJidoWeb.Jido.MarketingLayouts.marketing_layout current_path="" show_nav_modals={false}>
      <section class="px-6 py-20 md:py-28">
        <div class="mx-auto max-w-3xl">
          <div class="inline-flex items-center rounded border border-border px-3 py-1 text-xs text-muted-foreground">
            404
          </div>
          <h1 class="mt-5 text-3xl font-bold tracking-tight md:text-4xl">Page not found</h1>

          <%= if @request_path do %>
            <p class="mt-4 text-sm text-muted-foreground md:text-base">
              We could not find <code class="rounded bg-muted px-1.5 py-0.5 text-foreground">{@request_path}</code>.
            </p>
          <% else %>
            <p class="mt-4 text-sm text-muted-foreground md:text-base">
              The page you requested could not be found.
            </p>
          <% end %>

          <p class="mt-2 text-sm text-muted-foreground md:text-base">
            Use one of the paths below to continue.
          </p>

          <div class="mt-8 flex flex-wrap gap-3">
            <.link
              navigate="/docs/getting-started"
              class="bg-primary text-primary-foreground hover:bg-primary/90 text-[13px] font-bold px-5 py-3 rounded transition-colors"
            >
              GET BUILDING
            </.link>
            <.link
              navigate="/docs"
              class="border border-border hover:border-foreground/40 text-[13px] font-medium px-5 py-3 rounded transition-colors"
            >
              Docs
            </.link>
            <.link
              navigate="/examples"
              class="border border-border hover:border-foreground/40 text-[13px] font-medium px-5 py-3 rounded transition-colors"
            >
              Examples
            </.link>
          </div>
        </div>
      </section>
    </AgentJidoWeb.Jido.MarketingLayouts.marketing_layout>
    """
  end

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  defp request_path(%{request_path: request_path}) when is_binary(request_path), do: request_path

  defp request_path(%{reason: %Phoenix.Router.NoRouteError{conn: conn}}), do: conn.request_path

  defp request_path(_assigns), do: nil
end
