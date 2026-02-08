defmodule AgentJidoWeb.SettingsLive do
  use AgentJidoWeb, :live_view
  import AgentJidoWeb.WorkbenchLayout

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       active_tab: :settings
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={:settings}>
      <div class="flex h-screen bg-secondary-50 dark:bg-secondary-950">
        <div class="w-full p-6">
          <div class="max-w-4xl mx-auto">
            <div class="mb-8">
              <h1 class="text-2xl font-bold text-primary-600 dark:text-primary-500 mb-4">Settings</h1>
              <p class="text-secondary-600 dark:text-secondary-400">
                Workbench settings will be available here.
              </p>
            </div>
          </div>
        </div>
      </div>
    </.workbench_layout>
    """
  end
end
