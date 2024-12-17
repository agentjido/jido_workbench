# defmodule JidoWorkbench.ThunksShowLive do
#   @moduledoc """
#   A LiveView component to display details of a specific Thunk and allow its execution.
#   """
#   use JidoWorkbench, :live_view

#   import JidoWorkbench.AdminLayoutComponent

#   @impl true
#   def mount(%{"slug" => slug}, _session, socket) do
#     thunk = Jido.get_thunk_by_slug(slug)
#     form = build_dynamic_form(thunk.schema)

#     {:ok,
#      assign(socket,
#        thunk: thunk,
#        form: form,
#        params: %{},
#        result: nil,
#        execution_time: nil
#      )}
#   end

#   @impl true
#   def render(assigns) do
#     ~H"""
#     <.admin_layout current_page={:admin_thunks} current_user={@current_user}>
#       <.breadcrumbs
#         separator="chevron"
#         links={[
#           %{label: "Thunks", to: ~p"/admin/workshop/thunks", link_type: "live_patch", icon: "hero-cog"}
#         ]}
#       />

#       <.page_header title={@thunk.name} class="mt-4">
#         <.button color="white" size="sm" link_type="live_patch" to={~p"/admin/workshop/thunks"}>
#           <.icon name="hero-arrow-left" class="h-4 w-4 mr-2" /> <%= gettext("Back to Thunks") %>
#         </.button>
#       </.page_header>

#       <div class="space-y-6">
#         <div class="bg-white dark:bg-gray-800 shadow overflow-hidden sm:rounded-lg">
#           <div class="px-4 py-5 sm:px-6">
#             <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-gray-100">
#               <%= gettext("Thunk Details") %>
#             </h3>
#             <p class="mt-1 max-w-2xl text-sm text-gray-500 dark:text-gray-400">
#               <%= @thunk.description %>
#             </p>
#           </div>
#           <div class="border-t border-gray-200 dark:border-gray-700 px-4 py-5 sm:px-6">
#             <dl class="grid grid-cols-1 gap-x-4 gap-y-8 sm:grid-cols-2">
#               <div class="sm:col-span-1">
#                 <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">
#                   <%= gettext("Category") %>
#                 </dt>
#                 <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">
#                   <%= @thunk.category %>
#                 </dd>
#               </div>
#               <div class="sm:col-span-1">
#                 <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">
#                   <%= gettext("Version") %>
#                 </dt>
#                 <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">
#                   <%= @thunk.vsn %>
#                 </dd>
#               </div>
#               <div class="sm:col-span-2">
#                 <dt class="text-sm font-medium text-gray-500 dark:text-gray-400">
#                   <%= gettext("Tags") %>
#                 </dt>
#                 <dd class="mt-1 text-sm text-gray-900 dark:text-gray-100">
#                   <%= Enum.join(@thunk.tags, ", ") %>
#                 </dd>
#               </div>
#             </dl>
#           </div>
#         </div>

#         <div class="bg-white dark:bg-gray-800 shadow sm:rounded-lg">
#           <div class="px-4 py-5 sm:p-6">
#             <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-gray-100">
#               <%= gettext("Execute Thunk") %>
#             </h3>
#             <div class="mt-5">
#               <.live_component
#                 module={JidoWorkbench.NimbleOptionsComponents}
#                 id="thunk-form"
#                 schema={@thunk.schema}
#               />
#             </div>
#           </div>
#         </div>

#         <%= if @result do %>
#           <div class="bg-white dark:bg-gray-800 shadow sm:rounded-lg">
#             <div class="px-4 py-5 sm:p-6">
#               <h3 class="text-lg leading-6 font-medium text-gray-900 dark:text-gray-100">
#                 <%= gettext("Execution Result") %>
#               </h3>
#               <p class="mt-2 text-sm text-gray-500 dark:text-gray-400">
#                 <%= gettext("Execution Time: %{time} ms", time: @execution_time) %>
#               </p>
#               <div class="mt-5">
#                 <pre class="bg-gray-100 dark:bg-gray-700 p-4 rounded-md overflow-x-auto">
#                   <%= inspect(@result, pretty: true) %>
#                 </pre>
#               </div>
#             </div>
#           </div>
#         <% end %>
#       </div>
#     </.admin_layout>
#     """
#   end

#   @impl true
#   def handle_event("execute", %{"thunk" => params}, socket) do
#     start_time = System.monotonic_time(:millisecond)
#     result = apply(socket.assigns.thunk.module, :run, [params, %{}])
#     end_time = System.monotonic_time(:millisecond)
#     execution_time = end_time - start_time

#     {:noreply, assign(socket, result: result, execution_time: execution_time)}
#   end

#   # Helper function to build a dynamic form based on the Thunk's schema
#   defp build_dynamic_form(schema) do
#     # Convert the schema to a form-compatible format
#     # This is a simplified version and might need to be adjusted based on your exact needs
#     Enum.reduce(schema, %{}, fn {field, _type}, acc ->
#       Map.put(acc, field, "")
#     end)
#   end

#   # Helper function to render the appropriate input based on the field type
#   # defp render_input(form, field, type) do
#   # case type do
#   #   :string ->
#   #     text_input(form, field,
#   #       class:
#   #         "mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
#   #     )

#   #   :integer ->
#   #     number_input(form, field,
#   #       class:
#   #         "mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
#   #     )

#   #   :boolean ->
#   #     checkbox(form, field,
#   #       class:
#   #         "rounded border-gray-300 text-indigo-600 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
#   #     )

#   #   _ ->
#   #     text_input(form, field,
#   #       class:
#   #         "mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
#   #     )
#   # end
#   # end
# end
