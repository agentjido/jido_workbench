# defmodule JidoWorkbench.SensorsShowLive do
#   @moduledoc """
#   A LiveView component to display details of a specific Sensor in the system.
#   """
#   use JidoWorkbench, :live_view

#   import JidoWorkbench.AdminLayoutComponent

#   @impl true
#   def mount(%{"slug" => slug}, _session, socket) do
#     sensor = Jido.get_sensor_by_slug(slug)
#     {:ok, assign(socket, sensor: sensor, params: %{}, result: nil, execution_time: nil)}
#   end

#   @impl true
#   def render(assigns) do
#     ~H"""
#     <.admin_layout current_page={:admin_sensors} current_user={@current_user}>
#       <div class="sensor-show">
#         <h1><%= @sensor.name %></h1>
#         <p><%= @sensor.description %></p>

#         <div class="metadata">
#           <p>Category: <%= @sensor.category %></p>
#           <p>Version: <%= @sensor.vsn %></p>
#           <p>Tags: <%= Enum.join(@sensor.tags, ", ") %></p>
#         </div>

#         <div class="schema">
#           <h2>Input Schema</h2>
#           <pre><%= inspect(@sensor.schema, pretty: true) %></pre>
#         </div>

#         <%= if @result do %>
#           <div class="result">
#             <h2>Execution Result</h2>
#             <p>Execution Time: <%= @execution_time %> ms</p>
#             <pre><%= inspect(@result, pretty: true) %></pre>
#           </div>
#         <% end %>

#         <div class="history">
#           <h2>Execution History</h2>
#           <!-- Implement execution history here -->
#         </div>
#       </div>
#     </.admin_layout>
#     """
#   end

#   @impl true
#   def handle_event("execute", %{"sensor" => params}, socket) do
#     start_time = System.monotonic_time(:millisecond)
#     result = apply(socket.assigns.sensor, :run, [params, %{}])
#     end_time = System.monotonic_time(:millisecond)
#     execution_time = end_time - start_time

#     {:noreply, assign(socket, result: result, execution_time: execution_time)}
#   end
# end
