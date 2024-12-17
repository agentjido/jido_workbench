# defmodule JidoWorkbenchWeb.ActionsLive do
#   @moduledoc """
#   A LiveView component to display a list of Actions in the system.
#   """
#   use JidoWorkbenchWeb, :live_view

#   import JidoWorkbenchWeb.AdminLayoutComponent

#   @impl true
#   def mount(_params, _session, socket) do
#     actions = Jido.list_actions()
#     {:ok, assign(socket, page_title: "Actions", actions: actions)}
#   end

#   @impl true
#   def handle_params(_params, _url, socket) do
#     {:noreply, socket}
#   end

#   @impl true
#   def render(assigns) do
#     ~H"""
#     <.admin_layout current_page={:admin_thunks} current_user={@current_user}>
#       <.page_header title={@page_title} />

#       <.table rows={@thunks}>
#         <:col :let={thunk} label="Module"><%= thunk.module %></:col>
#         <:col :let={thunk} label="Name"><%= thunk.name %></:col>
#         <:col :let={thunk} label="Description"><%= thunk.description %></:col>
#         <:col :let={thunk} label="Actions">
#           <.button
#             size="sm"
#             link_type="live_patch"
#             to={~p"/admin/workshop/thunks/#{thunk.slug}"}
#             phx-hook="TippyHook"
#             id={"view-thunk-#{thunk.name}"}
#             data-tippy-content="View details for Thunk"
#           >
#             <.icon name={"hero-eye"} solid class="w-4 h-4 m-0.5" />
#           </.button>
#         </:col>
#       </.table>
#     </.admin_layout>
#     """
#   end
# end
