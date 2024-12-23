defmodule JidoWorkbenchWeb.ActionsLive do
  @moduledoc """
  A LiveView component to display a list of Actions in the system.
  """
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout

  @impl true
  def mount(_params, _session, socket) do
    actions = Jido.list_actions()
    {:ok, assign(socket, page_title: "Actions", actions: actions, active_tab: :actions)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={:actions}>
      <.container class="mt-10 mb-32">
        <.h2 underline class="mt-10" label={@page_title} />

        <.table rows={@actions}>
          <:col :let={action} label="Module">{action.module}</:col>
          <:col :let={action} label="Name">{action.name}</:col>
          <:col :let={action} label="Description">{action.description}</:col>
        </.table>
      </.container>
    </.workbench_layout>
    """
  end

  # <:col :let={action} label="Actions">
  #   <.button
  #     size="sm"
  #     link_type="live_patch"
  #     to={~p"/actions/#{action.slug}"}
  #     phx-hook="TippyHook"
  #     id={"view-action-#{action.name}"}
  #     data-tippy-content="View details for Action"
  #   >
  #     <.icon name="hero-eye" solid class="w-4 h-4 m-0.5" />
  #   </.button>
  # </:col>
end
