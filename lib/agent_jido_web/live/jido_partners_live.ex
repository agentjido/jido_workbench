defmodule AgentJidoWeb.JidoPartnersLive do
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, og_image: "https://agentjido.xyz/og/partners.png")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/partners">
      <div class="container max-w-[1000px] mx-auto px-6 py-12">
        <%!-- Hero --%>
        <section class="text-center mb-16">
          <div class="inline-block px-4 py-2 rounded mb-5 bg-accent-yellow/10 border border-accent-yellow/30">
            <span class="text-accent-yellow text-[11px] font-semibold tracking-widest uppercase">
              PARTNER PROGRAM
            </span>
          </div>
          <h1 class="text-4xl font-bold mb-4">
            Build with <span class="text-accent-yellow">Jido</span>
          </h1>
          <p class="text-lg text-muted-foreground max-w-2xl mx-auto">
            Join leading companies building AI-powered applications on the BEAM.
          </p>
        </section>

        <%!-- Partnership Tiers --%>
        <section class="mb-16">
          <div class="text-center mb-8">
            <span class="text-sm font-bold tracking-wider">PARTNERSHIP TIERS</span>
          </div>
          <div class="grid md:grid-cols-3 gap-6">
            <div class="feature-card text-center border-t-[3px] border-t-secondary">
              <div class="text-2xl mb-3">🌱</div>
              <h3 class="font-bold text-lg mb-2">Community</h3>
              <p class="text-muted-foreground text-sm mb-4">Free forever</p>
              <ul class="text-xs text-muted-foreground space-y-2 text-left">
                <li>✓ All packages (MIT licensed)</li>
                <li>✓ Community Discord support</li>
                <li>✓ GitHub discussions</li>
                <li>✓ Documentation access</li>
              </ul>
            </div>
            <div class="feature-card text-center border-t-[3px] border-t-primary">
              <div class="text-2xl mb-3">🚀</div>
              <h3 class="font-bold text-lg mb-2">Pro</h3>
              <p class="text-primary text-sm mb-4">$500/month</p>
              <ul class="text-xs text-muted-foreground space-y-2 text-left">
                <li>✓ Everything in Community</li>
                <li>✓ Priority support (24h SLA)</li>
                <li>✓ Architecture review (2/year)</li>
                <li>✓ Private Slack channel</li>
                <li>✓ Early access to new packages</li>
              </ul>
            </div>
            <div class="feature-card text-center border-t-[3px] border-t-accent-yellow">
              <div class="text-2xl mb-3">🏢</div>
              <h3 class="font-bold text-lg mb-2">Enterprise</h3>
              <p class="text-accent-yellow text-sm mb-4">Custom pricing</p>
              <ul class="text-xs text-muted-foreground space-y-2 text-left">
                <li>✓ Everything in Pro</li>
                <li>✓ Dedicated support engineer</li>
                <li>✓ Custom development</li>
                <li>✓ On-site training</li>
                <li>✓ SLA guarantees</li>
              </ul>
            </div>
          </div>
        </section>

        <%!-- Contact CTA --%>
        <section>
          <div class="cta-glow rounded-lg p-12 text-center">
            <h2 class="text-2xl font-bold mb-3">Ready to partner?</h2>
            <p class="text-secondary-foreground text-sm mb-6">
              Get in touch to discuss how Jido can power your AI applications.
            </p>
            <a
              href="mailto:partners@agentjido.com?subject=Partnership%20Inquiry"
              class="bg-accent-yellow text-primary-foreground hover:bg-accent-yellow/90 text-[13px] font-bold px-7 py-3 rounded transition-colors inline-block"
            >
              CONTACT PARTNERSHIPS →
            </a>
          </div>
        </section>
      </div>
    </.marketing_layout>
    """
  end
end
