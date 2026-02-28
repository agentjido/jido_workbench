defmodule AgentJidoWeb.JidoCommunityLive do
  @moduledoc """
  Placeholder community landing page.
  """
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Jido Community",
       meta_description: "Community hub for Jido users."
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout
      current_path="/community"
      current_scope={@current_scope}
      analytics_identity={@analytics_identity}
    >
      <div class="container max-w-[1000px] mx-auto px-6 py-16">
        <h1 class="text-3xl font-bold tracking-tight">Community</h1>
      </div>
    </.marketing_layout>
    """
  end
end
