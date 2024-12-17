defmodule JidoWorkbenchWeb.ActionsShowLive do
  @moduledoc """
  LiveView for executing and testing Jido Actions in the developer workbench.
  """
  use JidoWorkbenchWeb, :live_view

  require Logger

  @impl true
  def mount(%{"slug" => slug}, _session, socket) do
    case Jido.get_action_by_slug(slug) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Action not found")
         |> redirect(to: ~p"/actions")}

      action ->
        {:ok,
         assign(socket,
           page_title: "Action: #{action.name}",
           action: action,
           form: build_form(action.schema),
           result: nil,
           active_tab: :actions,
           execution_time: nil
         )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container class="mx-auto my-10">
      <div class="mb-8">
        <.h1><%= @action.name %></.h1>
        <p class="text-gray-600 dark:text-gray-400 mt-2"><%= @action.description %></p>
      </div>
      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mb-8">
        <h2 class="text-xl font-semibold mb-4">Action Metadata</h2>
        <dl class="grid grid-cols-2 gap-4">
          <div>
            <dt class="font-medium text-gray-700 dark:text-gray-300">Name:</dt>
            <dd class="mt-1 text-gray-900 dark:text-gray-100"><%= @action.name %></dd>
          </div>
          <div>
            <dt class="font-medium text-gray-700 dark:text-gray-300">Description:</dt>
            <dd class="mt-1 text-gray-900 dark:text-gray-100"><%= @action.description %></dd>
          </div>
          <div>
            <dt class="font-medium text-gray-700 dark:text-gray-300">Category:</dt>
            <dd class="mt-1 text-gray-900 dark:text-gray-100"><%= @action.category %></dd>
          </div>
          <div>
            <dt class="font-medium text-gray-700 dark:text-gray-300">Tags:</dt>
            <dd class="mt-1 text-gray-900 dark:text-gray-100"><%= Enum.join(@action.tags, ", ") %></dd>
          </div>
          <div>
            <dt class="font-medium text-gray-700 dark:text-gray-300">Version:</dt>
            <dd class="mt-1 text-gray-900 dark:text-gray-100"><%= @action.vsn %></dd>
          </div>
          <div>
            <dt class="font-medium text-gray-700 dark:text-gray-300">Compensation:</dt>
            <dd class="mt-1 text-gray-900 dark:text-gray-100"><%= inspect(@action.compensation) %></dd>
          </div>
        </dl>
      </div>

      <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mb-8">
      </div>

      <%= if @result do %>
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-semibold">Result</h3>
            <span class="text-sm text-gray-500">
              Executed in <%= @execution_time %>ms
            </span>
          </div>

          <div class="bg-gray-100 dark:bg-gray-700 rounded-lg p-4 overflow-x-auto">
            <pre class="text-sm"><%= inspect(@result, pretty: true, limit: :infinity) %></pre>
          </div>
        </div>
      <% end %>
    </.container>
    """
  end

  @impl true
  def handle_event("execute", %{"action" => params}, socket) do
    start_time = System.monotonic_time(:millisecond)

    result = Jido.Workflow.run(socket.assigns.action.module, params, %{}, [])

    execution_time = System.monotonic_time(:millisecond) - start_time

    socket =
      socket
      |> assign(:result, result)
      |> assign(:execution_time, execution_time)
      |> maybe_put_flash(result)

    {:noreply, socket}
  end

  # Private helpers

  defp build_form(schema) do
    types =
      schema
      |> Enum.map(fn {field, opts} -> {field, get_ecto_type(opts[:type])} end)
      |> Map.new()

    {%{}, types}
    |> Ecto.Changeset.cast(%{}, Map.keys(types))
    |> to_form(as: :action)
  end

  defp get_ecto_type(:non_neg_integer), do: :integer
  defp get_ecto_type(:integer), do: :integer
  defp get_ecto_type(:float), do: :float
  defp get_ecto_type(:boolean), do: :boolean
  defp get_ecto_type(:atom), do: :string
  defp get_ecto_type(_), do: :string

  defp get_field_type(options) do
    case options[:type] do
      :boolean -> :switch
      :non_neg_integer -> :number
      :integer -> :number
      :float -> :number
      {:in, values} -> {:select, options: values}
      _ -> :text
    end
  end

  defp maybe_put_flash(socket, {:ok, _}),
    do: put_flash(socket, :info, "Action executed successfully")

  defp maybe_put_flash(socket, {:error, msg}), do: put_flash(socket, :error, "Error: #{msg}")
end
