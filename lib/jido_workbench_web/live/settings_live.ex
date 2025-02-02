defmodule JidoWorkbenchWeb.SettingsLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  # Module param map for settings
  @settings [
    # %{
    #   group: :llm,
    #   name: "Anthropic API Key",
    #   description: "API key for Anthropic's language models",
    #   key: :anthropic_api_key,
    #   type: :string,
    #   default: "",
    #   config_path: [:anthropic_api_key]
    # },
    # %{
    #   group: :llm,
    #   name: "OpenAI API Key",
    #   description: "API key for OpenAI's language models",
    #   key: :openai_api_key,
    #   type: :string,
    #   default: "",
    #   config_path: [:openai_api_key]
    # },
    # %{
    #   group: :embedding,
    #   name: "Embedding Model",
    #   description: "Select the embedding model to use",
    #   key: :embedding_model,
    #   type: :select,
    #   options: ["OpenAI Ada", "Hugging Face", "Custom"],
    #   default: "OpenAI Ada",
    #   config_path: [:embedding_model]
    # },
    %{
      group: :instructor,
      name: "Instructor Anthropic API Key",
      description: "API key for Anthropic's language models used by Instructor",
      key: :instructor_anthropic_api_key,
      type: :string,
      default: "",
      config_path: [:instructor, :anthropic, :api_key]
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    settings = load_settings()
    {:ok, assign(socket, settings: settings, active_tab: :settings)}
  end

  @impl true
  def handle_event("save_settings", %{"settings" => form_settings}, socket) do
    updated_settings = update_settings(form_settings)

    {:noreply,
     socket
     |> assign(settings: updated_settings)
     |> put_flash(:info, "Settings saved successfully.")}
  end

  defp load_settings do
    Enum.map(@settings, fn setting ->
      app = List.first(setting.config_path)

      value =
        get_in(Application.get_all_env(app), Enum.drop(setting.config_path, 1)) || setting.default

      Map.put(setting, :value, value)
    end)
  end

  defp update_settings(form_settings) do
    Enum.map(@settings, fn setting ->
      app = List.first(setting.config_path)
      key = Enum.drop(setting.config_path, 1)
      value = form_settings[Atom.to_string(setting.key)]
      Application.put_env(app, key, value, persistent: true)
      Map.put(setting, :value, value)
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={:settings}>
      <.container class="mt-10 mb-32">
        <.h2 underline class="mt-10" label="Jido Workbench Settings" />
        <div class="bg-blue-50 border-l-4 border-blue-400 p-4 mb-6">
          <div class="flex">
            <div class="flex-shrink-0">
              <.icon name="hero-information-circle" class="h-5 w-5 text-blue-400" />
            </div>
            <div class="ml-3">
              <p class="text-sm text-blue-700">
                These settings will reset when the server restarts. To persist settings permanently, add them to a
                <code>.env</code>
                file in the root folder.
              </p>
            </div>
          </div>
        </div>
        <.form for={%{}} phx-submit="save_settings">
          <%= for group <- Enum.uniq(Enum.map(@settings, & &1.group)) do %>
            <.h3 class="mt-6" label={Phoenix.Naming.humanize(group)} />
            <%= for setting <- Enum.filter(@settings, & &1.group == group) do %>
              <div class="mt-4">
                <.form_label for={setting.key}>{setting.name}</.form_label>
                <%= case setting.type do %>
                  <% :string -> %>
                    <.text_input type="text" name={"settings[#{setting.key}]"} value={setting.value} />
                  <% :select -> %>
                    <.select
                      options={setting.options}
                      name={"settings[#{setting.key}]"}
                      selected={setting.value}
                    />
                <% end %>
                <.form_label class="text-sm text-gray-600">{setting.description}</.form_label>
              </div>
            <% end %>
          <% end %>
          <.button class="mt-6" label="Save Settings" />
        </.form>
      </.container>
    </.workbench_layout>
    """
  end
end
