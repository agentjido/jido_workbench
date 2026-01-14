defmodule JidoWorkbenchWeb.JidoGettingStartedLive do
  use JidoWorkbenchWeb, :live_view

  import JidoWorkbenchWeb.Jido.MarketingLayouts
  import JidoWorkbenchWeb.Jido.MarketingCode

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/getting-started">
      <div class="container max-w-[800px] mx-auto px-6">
        <section class="py-16 text-center">
          <h1 class="text-3xl md:text-4xl font-bold mb-4">Getting Started</h1>
          <p class="text-muted-foreground text-sm">
            Build your first AI agent in minutes
          </p>
        </section>

        <section class="pb-16 space-y-12">
          <!-- Step 1 -->
          <div>
            <h2 class="text-lg font-bold mb-4 flex items-center gap-3">
              <span class="w-8 h-8 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-sm">1</span>
              Add Dependencies
            </h2>
            <.code_block
              title="mix.exs"
              code={~s|defp deps do
  [
    {:jido, "~> 1.0"},
    {:jido_ai, "~> 1.0"}
  ]
end|}
            />
          </div>

          <!-- Step 2 -->
          <div>
            <h2 class="text-lg font-bold mb-4 flex items-center gap-3">
              <span class="w-8 h-8 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-sm">2</span>
              Fetch Dependencies
            </h2>
            <.terminal_command command="mix deps.get" />
          </div>

          <!-- Step 3 -->
          <div>
            <h2 class="text-lg font-bold mb-4 flex items-center gap-3">
              <span class="w-8 h-8 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-sm">3</span>
              Define Your First Agent
            </h2>
            <.code_block
              title="lib/my_app/my_agent.ex"
              code={~s|defmodule MyApp.MyAgent do
  use Jido.Agent,
    name: "my_agent",
    description: "My first AI agent"

  def handle_signal(:greet, %{name: name}, state) do
    {:ok, "Hello, \#{name}!", state}
  end
end|}
            />
          </div>

          <!-- Step 4 -->
          <div>
            <h2 class="text-lg font-bold mb-4 flex items-center gap-3">
              <span class="w-8 h-8 rounded-full bg-primary text-primary-foreground flex items-center justify-center text-sm">4</span>
              Run Your Agent
            </h2>
            <.code_block
              title="iex -S mix"
              language="elixir"
              code={~s|iex> {:ok, pid} = MyApp.MyAgent.start_link()
iex> MyApp.MyAgent.signal(pid, :greet, %{name: "World"})
{:ok, "Hello, World!"}|}
            />
          </div>
        </section>

        <section class="text-center pb-16">
          <.link navigate="/docs" class="bg-primary text-primary-foreground hover:bg-primary/90 text-xs font-bold px-6 py-3 rounded inline-block transition-colors">
            READ THE DOCS →
          </.link>
        </section>
      </div>
    </.marketing_layout>
    """
  end
end
