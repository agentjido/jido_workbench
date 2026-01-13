defmodule JidoWorkbenchWeb.JidoPartnersLive do
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
          <h1 class="text-3xl md:text-4xl font-bold mb-4">Partners</h1>
          <p class="text-muted-foreground text-sm max-w-2xl mx-auto">
            Organizations and individuals building with Jido.
          </p>
        </section>

        <section class="pb-16">
          <div class="grid md:grid-cols-3 gap-6">
            <.feature_card>
              <div class="text-center">
                <div class="w-16 h-16 rounded-full bg-elevated mx-auto mb-4 flex items-center justify-center text-2xl">
                  🏢
                </div>
                <h3 class="text-sm font-bold mb-2">Enterprise</h3>
                <p class="text-xs text-muted-foreground">
                  Building production AI systems with Jido
                </p>
              </div>
            </.feature_card>

            <.feature_card>
              <div class="text-center">
                <div class="w-16 h-16 rounded-full bg-elevated mx-auto mb-4 flex items-center justify-center text-2xl">
                  🎓
                </div>
                <h3 class="text-sm font-bold mb-2">Research</h3>
                <p class="text-xs text-muted-foreground">
                  Academic partners exploring AI agent architectures
                </p>
              </div>
            </.feature_card>

            <.feature_card>
              <div class="text-center">
                <div class="w-16 h-16 rounded-full bg-elevated mx-auto mb-4 flex items-center justify-center text-2xl">
                  💡
                </div>
                <h3 class="text-sm font-bold mb-2">Startups</h3>
                <p class="text-xs text-muted-foreground">
                  Fast-moving teams shipping AI-powered products
                </p>
              </div>
            </.feature_card>
          </div>
        </section>

        <section class="text-center pb-16 cta-glow rounded-lg p-8">
          <h2 class="text-xl font-bold mb-4">Become a Partner</h2>
          <p class="text-muted-foreground text-sm mb-6 max-w-lg mx-auto">
            Interested in partnering with Jido? We'd love to hear from you.
          </p>
          <a href="mailto:partners@agentjido.com" class="bg-primary text-primary-foreground hover:bg-primary/90 text-xs font-bold px-6 py-3 rounded inline-block transition-colors">
            CONTACT US
          </a>
        </section>
      </div>
    </.marketing_layout>
    """
  end
end
