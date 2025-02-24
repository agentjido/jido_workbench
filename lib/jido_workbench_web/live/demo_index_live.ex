defmodule JidoWorkbenchWeb.DemoIndexLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  alias JidoWorkbench.JidoDemo

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, demos: [], page_title: "Loading...", search: "", tag: nil)}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    tag = get_route_tag(uri)
    demos = JidoDemo.list_demos()
    title = if tag == :showcase, do: "Showcase", else: "Demos"

    {:noreply, assign(socket, demos: demos, page_title: title, tag: tag)}
  end

  # Private function to extract tag from route info
  defp get_route_tag(uri) do
    uri
    |> URI.parse()
    |> Map.get(:path, "/")
    |> then(&Phoenix.Router.route_info(JidoWorkbenchWeb.Router, "GET", &1, ""))
    |> case do
      %{tag: tag} when not is_nil(tag) -> tag
      _ -> :demo
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={:demo}>
      <div class="flex h-screen bg-zinc-900 text-gray-100">
        <div class="w-full p-6">
          <div class="max-w-4xl mx-auto">
            <div class="mb-6">
              <h1 class="text-2xl font-bold text-lime-500 mb-4">Available Demos</h1>
              <div class="relative">
                <.icon
                  name="hero-magnifying-glass"
                  class="w-5 h-5 absolute left-3 top-2.5 text-zinc-400"
                />
                <.input
                  type="text"
                  name="search"
                  value={@search}
                  placeholder="Search demos..."
                  phx-change="search"
                  phx-debounce="300"
                  class="w-full bg-zinc-800 rounded-md py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-lime-500"
                />
              </div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <%= for demo <- @demos do %>
                <.link navigate={~p"/demo/#{demo.id}"} class="block">
                  <div class="bg-zinc-800 p-6 rounded-lg hover:bg-zinc-700 transition-colors">
                    <div class="flex items-center gap-3 mb-4">
                      <div class="text-lime-500">
                        <.icon name={demo.icon} class="w-6 h-6" />
                      </div>
                      <h2 class="text-xl font-semibold text-lime-500">{demo.name}</h2>
                    </div>
                    <p class="text-zinc-400 text-sm mb-4">{demo.description}</p>
                  </div>
                </.link>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </.workbench_layout>
    """
  end

  @impl true
  def handle_event("search", %{"search" => search_term}, socket) do
    filtered_demos =
      JidoDemo.list_demos()
      |> Enum.filter(fn demo ->
        String.contains?(
          String.downcase(demo.name <> demo.description),
          String.downcase(search_term)
        )
      end)

    {:noreply, assign(socket, demos: filtered_demos, search: search_term)}
  end
end
