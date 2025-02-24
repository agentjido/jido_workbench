defmodule JidoWorkbenchWeb.SettingsLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  alias JidoWorkbenchWeb.LLMKeys

  @impl true
  def mount(_params, session, socket) do
    settings = LLMKeys.load_settings(session)
    any_valid_key? = Enum.any?(settings, &(&1.value != ""))

    {:ok,
     assign(socket,
       settings: settings,
       active_tab: :settings,
       any_valid_key?: any_valid_key?,
       test_results: %{}
     )}
  end

  @impl true
  def handle_event("test_keys", _params, socket) do
    test_results =
      Enum.reduce(socket.assigns.settings, %{}, fn setting, acc ->
        case LLMKeys.test_key(setting.key, setting.value) do
          {:ok, message} -> Map.put(acc, setting.key, {:ok, message})
          {:error, message} -> Map.put(acc, setting.key, {:error, message})
        end
      end)

    {:noreply, assign(socket, test_results: test_results)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={:settings}>
      <div class="flex h-screen bg-zinc-900 text-gray-100">
        <div class="w-full p-6">
          <div class="max-w-4xl mx-auto">
            <div class="mb-8">
              <h1 class="text-2xl font-bold text-lime-500 mb-4">API Key Settings</h1>
              <div class="text-zinc-400">
                <p>
                  Configure your API keys for various language models. These keys are required to use the AI features in the workbench.
                </p>
                <%= if !@any_valid_key? do %>
                  <div class="mt-4 bg-yellow-900/50 border-l-4 border-yellow-500 p-4">
                    <div class="flex">
                      <div class="flex-shrink-0">
                        <.icon name="hero-exclamation-triangle" class="h-5 w-5 text-yellow-500" />
                      </div>
                      <div class="ml-3">
                        <p class="text-sm text-yellow-200">
                          No valid API keys found. Please add at least one API key to use the AI features.
                        </p>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>

            <div class="bg-zinc-800 shadow rounded-lg mb-8">
              <div class="px-4 py-5 sm:p-6">
                <h3 class="text-lg font-medium text-lime-500">Security Notice</h3>
                <div class="mt-2 text-sm text-zinc-400">
                  <p>
                    API keys are stored in your browser session for your use only. While we take security seriously,
                    if you're concerned about key security, we recommend:
                  </p>
                  <ul class="list-disc list-inside mt-2 space-y-1">
                    <li>Running the workbench locally</li>
                    <li>Using environment variables instead of the web interface</li>
                    <li>Setting up usage limits on your API keys</li>
                  </ul>
                </div>
                <div class="mt-3">
                  <a
                    href="https://github.com/agentjido/jido_workbench"
                    class="inline-flex items-center text-sm text-lime-500 hover:text-lime-400"
                  >
                    <.icon name="hero-arrow-top-right-on-square" class="h-4 w-4 mr-1" />
                    View on GitHub
                  </a>
                </div>
              </div>
            </div>

            <.form for={%{}} action={~p"/settings/save"} method="post" class="space-y-8">
              <%= for setting <- @settings do %>
                <div class="bg-zinc-800 shadow rounded-lg">
                  <div class="px-4 py-5 sm:p-6">
                    <div class="md:grid md:grid-cols-3 md:gap-6">
                      <div class="md:col-span-1">
                        <h3 class="text-lg font-medium text-lime-500">
                          <%= setting.name %>
                        </h3>
                        <p class="mt-2 text-sm text-zinc-400">
                          <%= setting.description %>
                        </p>
                        <div class="mt-4 flex flex-col space-y-2">
                          <a
                            href={setting.signup_url}
                            target="_blank"
                            rel="noopener noreferrer"
                            class="inline-flex items-center text-sm text-lime-500 hover:text-lime-400"
                          >
                            <.icon name="hero-key" class="h-4 w-4 mr-1" />
                            Get API Key
                          </a>
                          <a
                            href={setting.docs_url}
                            target="_blank"
                            rel="noopener noreferrer"
                            class="inline-flex items-center text-sm text-lime-500 hover:text-lime-400"
                          >
                            <.icon name="hero-document-text" class="h-4 w-4 mr-1" />
                            View Documentation
                          </a>
                        </div>
                      </div>
                      <div class="mt-5 md:mt-0 md:col-span-2">
                        <div class="space-y-4">
                          <div>
                            <div class="flex justify-between">
                              <.form_label for={setting.key} class="text-zinc-300">API Key</.form_label>
                              <span class={
                                "px-2 py-1 text-xs rounded-full #{if setting.value != "", do: "bg-lime-900/50 text-lime-300", else: "bg-red-900/50 text-red-300"}"
                              }>
                                <%= if setting.value != "", do: "Valid", else: "Not Set" %>
                              </span>
                            </div>
                            <div class="relative">
                              <.text_input
                                type="password"
                                name={"settings[#{setting.key}]"}
                                value={setting.value}
                                placeholder={"Enter your #{setting.name}"}
                                id={"input-#{setting.key}"}
                                class="w-full bg-zinc-700 border-zinc-600 text-zinc-200 focus:border-lime-500 focus:ring-lime-500"
                              />
                              <button
                                type="button"
                                onclick={"togglePasswordVisibility('input-#{setting.key}', this)"}
                                class="absolute inset-y-0 right-0 pr-3 flex items-center text-zinc-400 hover:text-zinc-300"
                              >
                                <.icon name="hero-eye" class="h-5 w-5" />
                              </button>
                            </div>
                          </div>
                          <%= if Map.has_key?(@test_results, setting.key) do %>
                            <div class={
                              "mt-2 p-2 rounded text-sm #{case @test_results[setting.key] do
                                {:ok, _} -> "bg-lime-900/50 text-lime-300"
                                {:error, _} -> "bg-red-900/50 text-red-300"
                              end}"
                            }>
                              <%= case @test_results[setting.key] do
                                {:ok, message} -> message
                                {:error, message} -> message
                              end %>
                            </div>
                          <% end %>
                          <p class="text-sm text-zinc-400">
                            <%= setting.help_text %>
                          </p>
                          <p class="text-xs text-zinc-500">
                            Environment Variable: <code class="bg-zinc-700 px-1 rounded"><%= setting.env_var %></code>
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              <% end %>

              <div class="flex justify-end space-x-3">
                <.link
                  href={~p"/settings/clear"}
                  class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-red-300 bg-red-900/50 hover:bg-red-900/75"
                >
                  <.icon name="hero-arrow-path" class="h-4 w-4 mr-2" />
                  Reset to Defaults
                </.link>
                <.button
                  type="button"
                  theme="secondary"
                  phx-click="test_keys"
                  label="Test Keys"
                  class="inline-flex items-center bg-zinc-700 hover:bg-zinc-600 text-zinc-200"
                >
                  <.icon name="hero-beaker" class="h-4 w-4 mr-2" />
                  Test Keys
                </.button>
                <.button
                  type="submit"
                  label="Save Settings"
                  class="inline-flex items-center bg-lime-600 hover:bg-lime-500 text-white"
                >
                  <.icon name="hero-check" class="h-4 w-4 mr-2" />
                  Save Settings
                </.button>
              </div>
            </.form>
          </div>
        </div>
      </div>
    </.workbench_layout>

    <script>
      function togglePasswordVisibility(inputId, button) {
        const input = document.getElementById(inputId);
        const icon = button.querySelector('svg');
        if (input.type === 'password') {
          input.type = 'text';
          icon.innerHTML = `<path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 001.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0112 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 01-4.293 5.774M6.228 6.228L3 3m3.228 3.228l3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 10-4.243-4.243m4.242 4.242L9.88 9.88"/>`;
        } else {
          input.type = 'password';
          icon.innerHTML = `<path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 010-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0Z"/>`;
        }
      }
    </script>
    """
  end
end
