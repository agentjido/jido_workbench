defmodule JidoWorkbenchWeb.ChooseToolAgentLive do
  use JidoWorkbenchWeb, :live_view
  import JidoWorkbenchWeb.WorkbenchLayout
  alias JidoWorkbench.Jido.ChooseToolAgent

  def __jido_demo__ do
    %JidoWorkbench.JidoDemo.Demo{
      id: :choose_tool_agent,
      name: "Choose Tool Agent",
      description:
        "An agent that can intelligently select appropriate tools based on user messages.",
      icon: "hero-check-circle",
      module: __MODULE__,
      category: "Tool Selection",
      source_files: ["lib/jido_workbench_web/live/demos/choose_tool_agent_live.ex"]
    }
  end

  @impl true
  def mount(_params, _session, socket) do
    available_tools = [
      Jido.Actions.Arithmetic.Add,
      Jido.Actions.Arithmetic.Subtract,
      Jido.Actions.Arithmetic.Multiply,
      Jido.Actions.Arithmetic.Divide,
      Jido.Actions.Arithmetic.Square
    ]

    case ChooseToolAgent.start_link(available_tools) do
      {:ok, agent_pid} ->
        agent = ChooseToolAgent.get_state(agent_pid)

        {:ok,
         assign(socket,
           agent_pid: agent_pid,
           agent: agent,
           message: "",
           result: nil,
           loading: false
         )}

      {:error, reason} ->
        {:ok,
         socket
         |> put_flash(:error, "Failed to start agent: #{inspect(reason)}")
         |> assign(agent_pid: nil, agent: nil, message: "", result: nil, loading: false)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.workbench_layout current_page={:demo}>
      <div class="max-w-4xl mx-auto px-4 py-6">
        <div class="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
          <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-4">
            Choose Tool Agent Demo
          </h1>
          <p class="text-gray-600 dark:text-gray-300 mb-4">
            This demo showcases an agent that can intelligently select appropriate tools based on user messages. It demonstrates:
          </p>
          <ul class="list-disc list-inside text-gray-600 dark:text-gray-300 mb-6 ml-4">
            <li>LLM-powered tool selection</li>
            <li>Integration with arithmetic tools</li>
          </ul>

          <div class="mt-6">
            <form phx-submit="choose_tool" class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 dark:text-gray-300">
                  Enter your message
                </label>
                <textarea
                  name="message"
                  rows="3"
                  class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 dark:bg-gray-700 dark:border-gray-600 dark:text-white"
                  placeholder="e.g. What is 5 + 3?"
                  disabled={is_nil(@agent_pid)}
                ><%= @message %></textarea>
              </div>
              <div class="flex items-center gap-4">
                <.button label="Choose Tool" type="submit" disabled={@loading || is_nil(@agent_pid)} />
                <.button
                  label="Guess Tool"
                  type="button"
                  phx-click="guess_tool"
                  phx-value-message={@message}
                  disabled={@loading || is_nil(@agent_pid)}
                />
                <.spinner show={@loading} size="sm" />
              </div>
            </form>
          </div>

          <%= if @result do %>
            <div class="mt-6">
              <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">Result</h2>
              <div class="bg-gray-50 dark:bg-gray-700 p-4 rounded-lg">
                <div class="space-y-4">
                  <div>
                    <h3 class="text-lg font-medium text-gray-900 dark:text-white">Selected Tool</h3>
                    <p class="text-gray-600 dark:text-gray-300">
                      {inspect(@result.result_state.result.action)}
                    </p>
                  </div>

                  <div>
                    <h3 class="text-lg font-medium text-gray-900 dark:text-white">Parameters</h3>
                    <div class="grid grid-cols-2 gap-2">
                      <%= for {key, value} <- @result.result_state.result.params do %>
                        <div class="text-gray-600 dark:text-gray-300 font-medium">{key}:</div>
                        <div class="text-gray-800 dark:text-gray-200">{value}</div>
                      <% end %>
                    </div>
                  </div>

                  <div>
                    <h3 class="text-lg font-medium text-gray-900 dark:text-white">Status</h3>
                    <span class="px-2 py-1 text-sm rounded-full bg-green-100 text-green-800 dark:bg-green-800 dark:text-green-100">
                      {@result.status}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          <% end %>

          <%= if @agent do %>
            <div class="mt-6">
              <h2 class="text-xl font-semibold text-gray-900 dark:text-white mb-4">Agent State</h2>
              <div class="p-4 bg-gray-100 dark:bg-gray-700 rounded-lg overflow-x-auto">
                <pre class="text-sm text-gray-800 dark:text-gray-200 whitespace-pre-wrap"><%= inspect(@agent, pretty: true, width: 80) %></pre>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </.workbench_layout>
    """
  end

  @impl true
  def handle_event("choose_tool", %{"message" => message}, %{assigns: %{agent_pid: pid}} = socket)
      when not is_nil(pid) do
    {:noreply, assign(socket, loading: true)}

    try do
      case ChooseToolAgent.choose_tool(pid, message) do
        {:ok, result} ->
          {:noreply,
           socket
           |> assign(:message, message)
           |> assign(:result, result)
           |> assign(:loading, false)
           |> put_flash(:info, "Tool selected successfully!")}

        {:error, :invalid_tool} ->
          {:noreply,
           socket
           |> assign(:message, message)
           |> assign(:loading, false)
           |> put_flash(:error, "No suitable tool found for this request")}

        {:error, :invalid_response} ->
          {:noreply,
           socket
           |> assign(:message, message)
           |> assign(:loading, false)
           |> put_flash(:error, "Failed to parse tool selection response")}

        {:error, :timeout} ->
          {:noreply,
           socket
           |> assign(:message, message)
           |> assign(:loading, false)
           |> put_flash(:error, "Tool selection timed out")}

        {:error, reason} ->
          {:noreply,
           socket
           |> assign(:message, message)
           |> assign(:loading, false)
           #  |> put_flash(:error, "Failed to select tool: #{inspect(reason)}")}
           |> put_flash(:error, "Failed to select tool")}
      end
    catch
      kind, reason ->
        require Logger

        Logger.error("Unexpected error in choose_tool",
          kind: kind,
          error: inspect(reason),
          stacktrace: __STACKTRACE__
        )

        {:noreply,
         socket
         |> assign(:message, message)
         |> assign(:loading, false)
         |> put_flash(:error, "An unexpected error occurred")}
    end
  end

  def handle_event("choose_tool", _params, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Agent not initialized")}
  end

  def handle_event("guess_tool", %{"message" => message}, %{assigns: %{agent_pid: pid}} = socket)
      when not is_nil(pid) do
    require Logger
    Logger.metadata(view: "choose_tool_agent", event: "guess_tool")
    Logger.debug("Starting tool guess", message: message)

    {:noreply, assign(socket, loading: true)}

    try do
      case ChooseToolAgent.guess_tool(pid, message) do
        {:ok, result} ->
          Logger.info("Tool guess successful",
            found: result.result.found,
            result_type: if(result.result.found, do: :existing_tool, else: :speculated_tool)
          )

          {:noreply,
           socket
           |> assign(:message, message)
           |> assign(:result, result)
           |> assign(:loading, false)
           |> put_flash(:info, "Tool guessed successfully!")}

        {:error, {:invalid_request, reason}} ->
          Logger.info("Invalid tool guess request", reason: reason)

          {:noreply,
           socket
           |> assign(:message, message)
           |> assign(:loading, false)
           |> put_flash(:error, reason)}

        {:error, reason} ->
          Logger.warning("Tool guess failed", error: inspect(reason))

          {:noreply,
           socket
           |> assign(:message, message)
           |> assign(:loading, false)
           |> put_flash(:error, "Unable to process your request. Please try again.")}
      end
    catch
      kind, reason ->
        Logger.error("Unexpected error in guess_tool",
          kind: kind,
          error: inspect(reason),
          stacktrace: __STACKTRACE__
        )

        {:noreply,
         socket
         |> assign(:message, message)
         |> assign(:loading, false)
         |> put_flash(:error, "An unexpected error occurred. Please try again.")}
    end
  end

  def handle_event("guess_tool", _params, socket) do
    require Logger
    Logger.warning("Attempted to guess tool with uninitialized agent")

    {:noreply,
     socket
     |> put_flash(:error, "Agent not initialized")}
  end

  @impl true
  def terminate(_reason, %{assigns: %{agent_pid: pid}}) when not is_nil(pid) do
    Process.exit(pid, :normal)
    :ok
  end

  def terminate(_reason, _socket), do: :ok
end
