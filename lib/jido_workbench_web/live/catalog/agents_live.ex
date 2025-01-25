defmodule JidoWorkbenchWeb.CatalogAgentsLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout

  @impl true
  def mount(_params, _session, socket) do
    agents = Jido.list_agents()

    {:ok,
     assign(socket,
       page_title: "Agents Dashboard",
       agents: agents,
       selected_agent: nil,
       result: nil,
       active_tab: :agents,
       search: ""
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={:agents}>
      <div class="flex h-screen bg-zinc-900 text-gray-100">
        <div class="w-96 border-r border-zinc-700 flex flex-col">
          <div class="p-4 border-b border-zinc-700">
            <h2 class="text-xl mb-4 flex items-center gap-2">
              <.icon name="hero-users" class="w-6 h-6 text-lime-500" /> Available Agents
            </h2>
            <div class="relative">
              <.icon
                name="hero-magnifying-glass"
                class="w-5 h-5 absolute left-3 top-2.5 text-zinc-400"
              />
              <.input
                type="text"
                name="search"
                value={@search}
                placeholder="Search agents..."
                phx-change="search"
                phx-debounce="300"
                class="w-full bg-zinc-800 rounded-md py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-lime-500"
              />
            </div>
          </div>

          <div class="flex-1 overflow-y-auto">
            <%= for agent <- @agents do %>
              <button
                phx-click="select-agent"
                phx-value-slug={agent.slug}
                class={"w-full p-4 text-left hover:bg-zinc-800 flex items-center justify-between group #{if @selected_agent && @selected_agent.slug == agent.slug, do: "bg-zinc-800 border-l-2 border-lime-500", else: ""}"}
              >
                <div class="flex items-center space-x-3">
                  <div class="text-emerald-500">
                    <.icon name="hero-users" class="w-5 h-5" />
                  </div>
                  <div>
                    <div class="font-medium flex items-center gap-2">
                      {agent.name}
                      <span class="text-xs px-2 py-0.5 rounded-full bg-zinc-700 text-zinc-300">
                        {agent.category}
                      </span>
                    </div>
                    <div class="text-sm text-zinc-400">
                      {agent.description}
                    </div>
                  </div>
                </div>
                <.icon
                  name="hero-chevron-right"
                  class="w-5 h-5 text-zinc-500 opacity-0 group-hover:opacity-100"
                />
              </button>
            <% end %>
          </div>
        </div>

        <div class="flex-1 p-6">
          <%= if @selected_agent do %>
            <div class="max-w-2xl">
              <div class="flex items-center gap-3 mb-6">
                <div class="text-emerald-500">
                  <.icon name="hero-users" class="w-6 h-6" />
                </div>
                <div>
                  <h1 class="text-2xl text-lime-500">{@selected_agent.name}</h1>
                  <div class="text-zinc-400 text-sm">{@selected_agent.category}</div>
                </div>
              </div>

              <p class="text-zinc-400 mb-8">{@selected_agent.description}</p>

              <.form :let={f} for={build_form(@selected_agent)} phx-submit="execute" class="space-y-6">
                <%= for {field, schema} <- @selected_agent.schema do %>
                  <div>
                    <label class="block mb-2 text-zinc-300">
                      {field}
                      <%= if schema[:required] do %>
                        <span class="text-red-500 ml-1">*</span>
                      <% end %>
                    </label>
                    <.input
                      type={get_field_type(schema)}
                      field={f[field]}
                      class="w-full bg-zinc-800 rounded-md py-2 px-4 focus:outline-none focus:ring-2 focus:ring-lime-500"
                    />
                  </div>
                <% end %>

                <.button class="w-full bg-lime-500 hover:bg-lime-600 text-zinc-900 font-bold py-3 px-4 rounded-md transition-colors">
                  Execute Agent
                </.button>
              </.form>

              <%= if @result do %>
                <div class="mt-8">
                  <h3 class="text-xl text-lime-500 mb-4">Result</h3>
                  <pre class="bg-zinc-800 p-4 rounded-md overflow-x-auto"><%= inspect(@result, pretty: true) %></pre>
                </div>
              <% end %>
            </div>
          <% else %>
            <div class="h-full flex items-center justify-center text-zinc-500">
              Select an agent to get started
            </div>
          <% end %>
        </div>
      </div>
    </.workbench_layout>
    """
  end

  @impl true
  def handle_event("select-agent", %{"slug" => slug}, socket) do
    agent = Enum.find(socket.assigns.agents, &(&1.slug == slug))
    {:noreply, assign(socket, selected_agent: agent)}
  end

  @impl true
  def handle_event("search", %{"search" => search_term}, socket) do
    filtered_agents =
      socket.assigns.agents
      |> Enum.filter(fn agent ->
        String.contains?(
          String.downcase(agent.name <> agent.description),
          String.downcase(search_term)
        )
      end)

    {:noreply, assign(socket, agents: filtered_agents, search: search_term)}
  end

  @impl true
  def handle_event("execute", params, socket) do
    agent = Enum.find(socket.assigns.agents, &(&1.slug == params["agent_slug"]))
    IO.inspect(params, label: "Params")
    IO.inspect(agent, label: "Agent")

    result =
      case agent do
        nil -> {:error, "Agent not found"}
        agent -> Jido.Workflow.run(agent.module, params, %{}, [])
      end

    {:noreply, assign(socket, result: result)}
  end

  defp build_form(agent) do
    types =
      agent.schema
      |> Enum.map(fn {field, opts} -> {field, get_ecto_type(opts[:type])} end)
      |> Map.new()
      |> Map.put(:agent_slug, :string)

    data = %{agent_slug: agent.slug}

    {data, types}
    |> Ecto.Changeset.cast(%{}, Map.keys(types))
    |> to_form(as: "agent")
  end

  defp get_ecto_type(:non_neg_integer), do: :integer
  defp get_ecto_type(:integer), do: :integer
  defp get_ecto_type(:float), do: :float
  defp get_ecto_type(:boolean), do: :boolean
  defp get_ecto_type(:atom), do: :string
  defp get_ecto_type(_), do: :string

  defp get_field_type(options) do
    case options[:type] do
      :boolean -> :checkbox
      :non_neg_integer -> :number
      :integer -> :number
      :float -> :number
      _ -> :text
    end
  end
end
