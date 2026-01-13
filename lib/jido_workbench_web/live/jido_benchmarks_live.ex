defmodule JidoWorkbenchWeb.JidoBenchmarksLive do
  use JidoWorkbenchWeb, :live_view

  import JidoWorkbenchWeb.Jido.MarketingLayouts
  import JidoWorkbenchWeb.Jido.MarketingCards

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout>
      <div class="container max-w-[1000px] mx-auto px-6">
        <section class="py-16 text-center">
          <h1 class="text-3xl md:text-4xl font-bold mb-4">Benchmarks</h1>
          <p class="text-muted-foreground text-sm max-w-2xl mx-auto">
            Performance metrics and comparisons for the Jido framework.
          </p>
        </section>

        <section class="grid md:grid-cols-4 gap-4 pb-8">
          <.metric_card value="<1ms" label="Action Latency" color_class="text-accent-green" />
          <.metric_card value="100k+" label="Agents/Node" color_class="text-accent-yellow" />
          <.metric_card value="99.99%" label="Uptime" color_class="text-accent-cyan" />
          <.metric_card value="0" label="Memory Leaks" color_class="text-accent-red" />
        </section>

        <section class="pb-16">
          <h2 class="text-xl font-bold mb-6">Why BEAM?</h2>
          <div class="grid md:grid-cols-2 gap-4">
            <.info_card
              title="Fault Tolerance"
              description="Built-in supervision trees ensure your agents recover from failures automatically."
            />
            <.info_card
              title="Concurrency"
              description="Lightweight processes allow running millions of concurrent agents on a single node."
            />
            <.info_card
              title="Distribution"
              description="Native clustering makes it easy to scale across multiple nodes."
            />
            <.info_card
              title="Hot Code Reload"
              description="Update your agents in production without downtime."
            />
          </div>
        </section>
      </div>
    </.marketing_layout>
    """
  end
end
