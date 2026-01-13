defmodule JidoWorkbenchWeb.JidoExamplesLive do
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
          <h1 class="text-3xl md:text-4xl font-bold mb-4">Examples</h1>
          <p class="text-muted-foreground text-sm max-w-2xl mx-auto">
            Learn by example with our collection of sample projects and use cases.
          </p>
        </section>

        <div class="grid md:grid-cols-2 gap-4 pb-16">
          <.feature_card>
            <h3 class="text-sm font-bold mb-2">Chatbot with Tools</h3>
            <p class="text-xs text-muted-foreground mb-4">
              Build a conversational AI that can execute tools and maintain context.
            </p>
            <a href="https://github.com/agentjido/jido/tree/main/examples/chatbot" target="_blank" class="text-xs text-primary hover:text-primary/80">
              View Example →
            </a>
          </.feature_card>

          <.feature_card>
            <h3 class="text-sm font-bold mb-2">Multi-Agent System</h3>
            <p class="text-xs text-muted-foreground mb-4">
              Coordinate multiple agents working together on complex tasks.
            </p>
            <a href="https://github.com/agentjido/jido/tree/main/examples/multi-agent" target="_blank" class="text-xs text-primary hover:text-primary/80">
              View Example →
            </a>
          </.feature_card>

          <.feature_card>
            <h3 class="text-sm font-bold mb-2">RAG Pipeline</h3>
            <p class="text-xs text-muted-foreground mb-4">
              Retrieval-augmented generation with vector search and embeddings.
            </p>
            <a href="https://github.com/agentjido/jido/tree/main/examples/rag" target="_blank" class="text-xs text-primary hover:text-primary/80">
              View Example →
            </a>
          </.feature_card>

          <.feature_card>
            <h3 class="text-sm font-bold mb-2">Event-Driven Agent</h3>
            <p class="text-xs text-muted-foreground mb-4">
              React to external events with signal processing and workflows.
            </p>
            <a href="https://github.com/agentjido/jido/tree/main/examples/events" target="_blank" class="text-xs text-primary hover:text-primary/80">
              View Example →
            </a>
          </.feature_card>
        </div>
      </div>
    </.marketing_layout>
    """
  end
end
