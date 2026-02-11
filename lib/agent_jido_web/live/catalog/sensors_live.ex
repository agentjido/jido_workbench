defmodule AgentJidoWeb.CatalogSensorsLive do
  use AgentJidoWeb, :live_view
  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    sensors = Jido.Discovery.list_sensors()

    {:ok,
     assign(socket,
       page_title: "Sensors Dashboard",
       og_image: "https://agentjido.xyz/og/catalog.png",
       sensors: sensors,
       selected_sensor: nil,
       result: nil,
       active_tab: :sensors,
       search: ""
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/catalog/sensors">
      <div class="container max-w-[1200px] mx-auto px-6 py-8">
        <div class="flex bg-background text-foreground min-h-[600px] border border-border rounded-lg overflow-hidden">
          <div class="w-96 border-r border-border flex flex-col">
            <div class="p-4 border-b border-border">
              <h2 class="text-xl mb-4 flex items-center gap-2">
                <.icon name="hero-signal" class="w-6 h-6 text-primary" /> Available Sensors
              </h2>
              <div class="relative">
                <.icon name="hero-magnifying-glass" class="w-5 h-5 absolute left-3 top-2.5 text-muted-foreground" />
                <input
                  type="text"
                  name="search"
                  value={@search}
                  placeholder="Search sensors..."
                  phx-change="search"
                  phx-debounce="300"
                  class="w-full bg-elevated rounded-md py-2 pl-10 pr-4 focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
            </div>

            <div class="flex-1 overflow-y-auto">
              <%= for sensor <- @sensors do %>
                <button
                  phx-click="select-sensor"
                  phx-value-slug={sensor.slug}
                  class={"w-full p-4 text-left hover:bg-elevated flex items-center justify-between group #{if @selected_sensor && @selected_sensor.slug == sensor.slug, do: "bg-elevated border-l-2 border-primary", else: ""}"}
                >
                  <div class="flex items-center space-x-3">
                    <div class="text-primary">
                      <.icon name="hero-signal" class="w-5 h-5" />
                    </div>
                    <div>
                      <div class="font-medium flex items-center gap-2 text-foreground">
                        {sensor.name}
                        <span class="text-xs px-2 py-0.5 rounded-full bg-elevated text-muted-foreground">
                          {sensor.category}
                        </span>
                      </div>
                      <div class="text-sm text-muted-foreground">
                        {sensor.description}
                      </div>
                    </div>
                  </div>
                  <.icon name="hero-chevron-right" class="w-5 h-5 text-muted-foreground opacity-0 group-hover:opacity-100" />
                </button>
              <% end %>
            </div>
          </div>

          <div class="flex-1 p-6">
            <%= if @selected_sensor do %>
              <div class="max-w-2xl">
                <div class="flex items-center gap-3 mb-6">
                  <div class="text-primary">
                    <.icon name="hero-signal" class="w-6 h-6" />
                  </div>
                  <div>
                    <h1 class="text-2xl text-foreground font-semibold">
                      {@selected_sensor.name}
                    </h1>
                    <div class="text-muted-foreground text-sm">
                      {@selected_sensor.category}
                    </div>
                  </div>
                </div>

                <p class="text-muted-foreground mb-8">
                  {@selected_sensor.description}
                </p>
              </div>
            <% else %>
              <div class="h-full flex items-center justify-center text-muted-foreground">
                Select a sensor to get started
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </.marketing_layout>
    """
  end

  @impl true
  def handle_event("select-sensor", %{"slug" => slug}, socket) do
    sensor = Enum.find(socket.assigns.sensors, &(&1.slug == slug))
    {:noreply, assign(socket, selected_sensor: sensor)}
  end

  @impl true
  def handle_event("search", %{"search" => search_term}, socket) do
    filtered_sensors =
      socket.assigns.sensors
      |> Enum.filter(fn sensor ->
        String.contains?(
          String.downcase(sensor.name <> sensor.description),
          String.downcase(search_term)
        )
      end)

    {:noreply, assign(socket, sensors: filtered_sensors, search: search_term)}
  end

  # @impl true
  # def handle_event("execute", params, socket) do
  #   sensor = Enum.find(socket.assigns.sensors, &(&1.slug == params["sensor_slug"]))
  #   IO.inspect(params, label: "Params")
  #   IO.inspect(sensor, label: "Sensor")
  #
  #   result =
  #     case sensor do
  #       nil -> {:error, "Sensor not found"}
  #       sensor -> Jido.Workflow.run(sensor.module, params, %{}, [])
  #     end
  #
  #   {:noreply, assign(socket, result: result)}
  # end

  # defp build_form(sensor) do
  #   types =
  #     sensor.schema
  #     |> Enum.map(fn {field, opts} -> {field, get_ecto_type(opts[:type])} end)
  #     |> Map.new()
  #     |> Map.put(:sensor_slug, :string)
  #
  #   data = %{sensor_slug: sensor.slug}
  #
  #   {data, types}
  #   |> Ecto.Changeset.cast(%{}, Map.keys(types))
  #   |> to_form(as: "sensor")
  # end

  # defp get_ecto_type(:non_neg_integer), do: :integer
  # defp get_ecto_type(:integer), do: :integer
  # defp get_ecto_type(:float), do: :float
  # defp get_ecto_type(:boolean), do: :boolean
  # defp get_ecto_type(:atom), do: :string
  # defp get_ecto_type(_), do: :string

  # defp get_field_type(options) do
  #   case options[:type] do
  #     :boolean -> :checkbox
  #     :non_neg_integer -> :number
  #     :integer -> :number
  #     :float -> :number
  #     _ -> :text
  #   end
  # end
end
