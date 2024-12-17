# defmodule JidoWorkbenchWeb.SensorsLive do
#   @moduledoc """
#   A LiveView component to display a list of Sensors in the system.
#   """
#   use JidoWorkbenchWeb, :live_view

#   import JidoWorkbenchWeb.AdminLayoutComponent

#   @impl true
#   def mount(_params, _session, socket) do
#     sensors = Jido.list_sensors()
#     {:ok, assign(socket, page_title: "Sensors", sensors: sensors)}
#   end

#   @impl true
#   def handle_params(_params, _url, socket) do
#     {:noreply, socket}
#   end

#   @impl true
#   def render(assigns) do
#     ~H"""
#     <.admin_layout current_page={:admin_sensors} current_user={@current_user}>
#       <.page_header title={@page_title} />

#       <.table rows={@sensors}>
#         <:col :let={sensor} label="Module"><%= sensor.module %></:col>
#         <:col :let={sensor} label="Name"><%= sensor.name %></:col>
#         <:col :let={sensor} label="Description"><%= sensor.description %></:col>
#         <:col :let={sensor} label="Actions">
#           <.button
#             size="xs"
#             link_type="live_patch"
#             to={~p"/admin/workshop/sensors/#{sensor.slug}"}
#             phx-hook="TippyHook"
#             id={"view-sensor-#{sensor.name}"}
#             data-tippy-content="View details for Sensor"
#           >
#             <.icon name={"hero-eye"} solid class="w-4 h-4 m-0.5" />
#           </.button>
#         </:col>
#       </.table>
#     </.admin_layout>
#     """
#   end
# end
