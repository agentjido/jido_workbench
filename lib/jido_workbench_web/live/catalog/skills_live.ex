defmodule JidoWorkbenchWeb.CatalogSkillsLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout

  @impl true
  def mount(_params, _session, socket) do
    skills = Jido.list_skills()

    {:ok,
     assign(socket,
       page_title: "Skills Dashboard",
       skills: skills,
       selected_skill: nil,
       result: nil,
       active_tab: :skills,
       search: ""
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={:skills}>
      <div class="flex h-screen bg-zinc-900 text-gray-100">
        <div class="w-96 border-r border-zinc-700 flex flex-col">
          <div class="p-4 border-b border-zinc-700">
            <h2 class="text-xl mb-4 flex items-center gap-2">
              <.icon name="hero-bolt" class="w-6 h-6 text-lime-500" /> Available Skills
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
                placeholder="Search skills..."
                phx-change="search"
                phx-debounce="300"
                class="w-full bg-zinc-800 rounded-md py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-lime-500"
              />
            </div>
          </div>

          <div class="flex-1 overflow-y-auto">
            <%= for skill <- @skills do %>
              <button
                phx-click="select-skill"
                phx-value-slug={skill.slug}
                class={"w-full p-4 text-left hover:bg-zinc-800 flex items-center justify-between group #{if @selected_skill && @selected_skill.slug == skill.slug, do: "bg-zinc-800 border-l-2 border-lime-500", else: ""}"}
              >
                <div class="flex items-center space-x-3">
                  <div class="text-emerald-500">
                    <.icon name="hero-bolt" class="w-5 h-5" />
                  </div>
                  <div>
                    <div class="font-medium flex items-center gap-2">
                      {skill.name}
                      <span class="text-xs px-2 py-0.5 rounded-full bg-zinc-700 text-zinc-300">
                        {skill.category}
                      </span>
                    </div>
                    <div class="text-sm text-zinc-400">
                      {skill.description}
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
          <%= if @selected_skill do %>
            <div class="max-w-2xl">
              <div class="flex items-center gap-3 mb-6">
                <div class="text-emerald-500">
                  <.icon name="hero-bolt" class="w-6 h-6" />
                </div>
                <div>
                  <h1 class="text-2xl text-lime-500">{@selected_skill.name}</h1>
                  <div class="text-zinc-400 text-sm">{@selected_skill.category}</div>
                </div>
              </div>

              <p class="text-zinc-400 mb-8">{@selected_skill.description}</p>

              <.form :let={f} for={build_form(@selected_skill)} phx-submit="execute" class="space-y-6">
                <%= for {field, schema} <- @selected_skill.schema do %>
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
                  Execute Skill
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
              Select a skill to get started
            </div>
          <% end %>
        </div>
      </div>
    </.workbench_layout>
    """
  end

  @impl true
  def handle_event("select-skill", %{"slug" => slug}, socket) do
    skill = Enum.find(socket.assigns.skills, &(&1.slug == slug))
    {:noreply, assign(socket, selected_skill: skill)}
  end

  @impl true
  def handle_event("search", %{"search" => search_term}, socket) do
    filtered_skills =
      socket.assigns.skills
      |> Enum.filter(fn skill ->
        String.contains?(
          String.downcase(skill.name <> skill.description),
          String.downcase(search_term)
        )
      end)

    {:noreply, assign(socket, skills: filtered_skills, search: search_term)}
  end

  @impl true
  def handle_event("execute", params, socket) do
    skill = Enum.find(socket.assigns.skills, &(&1.slug == params["skill_slug"]))
    IO.inspect(params, label: "Params")
    IO.inspect(skill, label: "Skill")

    result =
      case skill do
        nil -> {:error, "Skill not found"}
        skill -> Jido.Workflow.run(skill.module, params, %{}, [])
      end

    {:noreply, assign(socket, result: result)}
  end

  defp build_form(skill) do
    types =
      skill.schema
      |> Enum.map(fn {field, opts} -> {field, get_ecto_type(opts[:type])} end)
      |> Map.new()
      |> Map.put(:skill_slug, :string)

    data = %{skill_slug: skill.slug}

    {data, types}
    |> Ecto.Changeset.cast(%{}, Map.keys(types))
    |> to_form(as: "skill")
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
