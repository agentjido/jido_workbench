# Jido Workbench Redesign Plan

## Overview

Port the React/Tailwind prototype from `jido-dev-relaunch/` to Phoenix LiveView. The prototype is a developer documentation site with a terminal/code-centric aesthetic featuring neon green primary color and IBM Plex Mono font.

---

## Routes to Port

| React Route | Phoenix Route | LiveView |
|-------------|---------------|----------|
| `/` | `/` | `JidoHomeLive` |
| `/ecosystem` | `/ecosystem` | `JidoEcosystemLive` |
| `/getting-started` | `/getting-started` | `JidoGettingStartedLive` |
| `/examples` | `/examples` | `JidoExamplesLive` |
| `/benchmarks` | `/benchmarks` | `JidoBenchmarksLive` |
| `/partners` | `/partners` | `JidoPartnersLive` |
| `/docs/*` | Keep existing | Re-skin with new design |

---

## Phase 1: CSS/Tailwind Migration
**Effort: 1-3 hours**

### 1.1 Add Fonts

In `assets/css/app.css`:

```css
@import url('https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&display=swap');

@layer base {
  body {
    @apply bg-background text-foreground antialiased;
    font-family: 'IBM Plex Mono', ui-monospace, monospace;
  }

  html {
    scroll-behavior: smooth;
  }

  ::selection {
    background: hsl(var(--primary) / 0.3);
  }
}
```

### 1.2 Add CSS Variables

Copy from `jido-dev-relaunch/src/index.css` to `assets/css/app.css`:

```css
@layer base {
  :root {
    /* Dark theme (default) */
    --background: 0 0% 4%;
    --foreground: 0 0% 91%;
    --surface: 0 0% 7%;
    --elevated: 0 0% 10%;
    --card: 0 0% 7%;
    --card-foreground: 0 0% 91%;
    --popover: 0 0% 7%;
    --popover-foreground: 0 0% 91%;
    --primary: 152 100% 50%;
    --primary-foreground: 0 0% 4%;
    --secondary: 0 0% 10%;
    --secondary-foreground: 0 0% 85%;
    --muted: 0 0% 16%;
    --muted-foreground: 0 0% 40%;
    --accent-green: 152 100% 50%;
    --accent-yellow: 43 100% 50%;
    --accent-cyan: 192 100% 50%;
    --accent-red: 0 73% 71%;
    --accent: 192 100% 50%;
    --accent-foreground: 0 0% 4%;
    --destructive: 0 73% 71%;
    --destructive-foreground: 0 0% 98%;
    --border: 0 0% 16%;
    --border-strong: 0 0% 23%;
    --input: 0 0% 16%;
    --ring: 152 100% 50%;
    --radius: 0.375rem;
    --code-bg: 0 0% 3%;
    --code-border: 0 0% 16%;
    --code-keyword: 152 100% 50%;
    --code-string: 43 100% 50%;
    --code-comment: 0 0% 40%;
    --code-function: 192 100% 50%;
    --code-type: 0 73% 71%;
    --sidebar-background: 0 0% 5%;
    --sidebar-foreground: 0 0% 90%;
    --sidebar-primary: 152 100% 50%;
    --sidebar-primary-foreground: 0 0% 4%;
    --sidebar-accent: 0 0% 10%;
    --sidebar-accent-foreground: 0 0% 90%;
    --sidebar-border: 0 0% 16%;
    --sidebar-ring: 152 100% 50%;
  }

  .light {
    --background: 40 33% 98%;
    --foreground: 24 10% 10%;
    --surface: 0 0% 100%;
    --elevated: 40 20% 96%;
    --card: 0 0% 100%;
    --card-foreground: 24 10% 10%;
    --popover: 0 0% 100%;
    --popover-foreground: 24 10% 10%;
    --primary: 160 84% 39%;
    --primary-foreground: 0 0% 98%;
    --secondary: 40 20% 94%;
    --secondary-foreground: 24 10% 10%;
    --muted: 40 20% 92%;
    --muted-foreground: 24 8% 45%;
    --accent-green: 160 84% 39%;
    --accent-yellow: 32 95% 44%;
    --accent-cyan: 189 94% 43%;
    --accent-red: 0 72% 51%;
    --accent: 189 94% 43%;
    --accent-foreground: 0 0% 100%;
    --destructive: 0 72% 51%;
    --destructive-foreground: 0 0% 98%;
    --border: 24 6% 91%;
    --border-strong: 24 6% 84%;
    --input: 24 6% 91%;
    --ring: 160 84% 39%;
    --code-bg: 40 20% 96%;
    --code-border: 24 6% 91%;
    --code-keyword: 160 84% 39%;
    --code-string: 32 95% 44%;
    --code-comment: 24 8% 65%;
    --code-function: 189 94% 43%;
    --code-type: 0 72% 51%;
  }
}
```

### 1.3 Extend Tailwind Config

Update `assets/tailwind.config.js` - add to `theme.extend.colors`:

```js
colors: {
  // ... keep existing colors ...
  
  border: "hsl(var(--border))",
  "border-strong": "hsl(var(--border-strong))",
  input: "hsl(var(--input))",
  ring: "hsl(var(--ring))",
  background: "hsl(var(--background))",
  foreground: "hsl(var(--foreground))",
  surface: "hsl(var(--surface))",
  elevated: "hsl(var(--elevated))",
  primary: {
    DEFAULT: "hsl(var(--primary))",
    foreground: "hsl(var(--primary-foreground))",
  },
  secondary: {
    DEFAULT: "hsl(var(--secondary))",
    foreground: "hsl(var(--secondary-foreground))",
  },
  muted: {
    DEFAULT: "hsl(var(--muted))",
    foreground: "hsl(var(--muted-foreground))",
  },
  accent: {
    DEFAULT: "hsl(var(--accent))",
    foreground: "hsl(var(--accent-foreground))",
    green: "hsl(var(--accent-green))",
    yellow: "hsl(var(--accent-yellow))",
    cyan: "hsl(var(--accent-cyan))",
    red: "hsl(var(--accent-red))",
  },
  card: {
    DEFAULT: "hsl(var(--card))",
    foreground: "hsl(var(--card-foreground))",
  },
  code: {
    bg: "hsl(var(--code-bg))",
    border: "hsl(var(--code-border))",
    keyword: "hsl(var(--code-keyword))",
    string: "hsl(var(--code-string))",
    comment: "hsl(var(--code-comment))",
    function: "hsl(var(--code-function))",
    type: "hsl(var(--code-type))",
  },
}
```

Add to `theme.extend`:

```js
borderRadius: {
  lg: "var(--radius)",
  md: "calc(var(--radius) - 2px)",
  sm: "calc(var(--radius) - 4px)",
},
keyframes: {
  "fade-in": {
    from: { opacity: "0", transform: "translateY(10px)" },
    to: { opacity: "1", transform: "translateY(0)" },
  },
},
animation: {
  "fade-in": "fade-in 0.5s ease-out forwards",
},
```

### 1.4 Add Component Utility Classes

Add to `assets/css/app.css`:

```css
@layer components {
  .package-card {
    @apply bg-card border border-border rounded-md p-5 transition-all duration-200;
  }
  .package-card:hover {
    @apply border-border-strong;
  }
  .package-card-core {
    @apply package-card border-t-[3px];
    border-top-color: hsl(var(--accent-green));
  }
  .package-card-ai {
    @apply package-card border-t-[3px];
    border-top-color: hsl(var(--accent-yellow));
  }
  .package-card-foundation {
    @apply package-card border-t-[3px];
    border-top-color: hsl(var(--accent-cyan));
  }
  .package-card-app {
    @apply package-card border-t-[3px];
    border-top-color: hsl(var(--accent-red));
  }

  .badge-core {
    @apply text-[9px] font-bold tracking-wider px-2 py-0.5 rounded;
    color: hsl(var(--accent-green));
    background: hsl(var(--accent-green) / 0.15);
  }
  .badge-ai {
    @apply text-[9px] font-bold tracking-wider px-2 py-0.5 rounded;
    color: hsl(var(--accent-yellow));
    background: hsl(var(--accent-yellow) / 0.15);
  }
  .badge-foundation {
    @apply text-[9px] font-bold tracking-wider px-2 py-0.5 rounded;
    color: hsl(var(--accent-cyan));
    background: hsl(var(--accent-cyan) / 0.15);
  }
  .badge-app {
    @apply text-[9px] font-bold tracking-wider px-2 py-0.5 rounded;
    color: hsl(var(--accent-red));
    background: hsl(var(--accent-red) / 0.15);
  }

  .code-block {
    @apply rounded-md border overflow-x-auto;
    background: hsl(var(--code-bg));
    border-color: hsl(var(--code-border));
  }
  .code-header {
    @apply px-5 py-3 border-b flex items-center justify-between;
    background: hsl(var(--elevated));
    border-color: hsl(var(--code-border));
  }

  .metric-card {
    @apply text-center py-5 px-4;
    background: hsl(var(--surface));
  }

  .feature-card {
    @apply bg-card border border-border rounded-md p-6 transition-all duration-200;
  }
  .feature-card:hover {
    @apply border-primary/50;
  }

  .gradient-text {
    background: linear-gradient(135deg, hsl(var(--accent-green)), hsl(var(--accent-yellow)));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }

  .cta-glow {
    background: hsl(var(--primary) / 0.05);
    border: 1px solid hsl(var(--primary) / 0.2);
  }

  .nav-surface {
    @apply bg-card border border-border rounded-md;
  }
}

@layer utilities {
  .syntax-keyword { color: hsl(var(--code-keyword)); }
  .syntax-string { color: hsl(var(--code-string)); }
  .syntax-comment { color: hsl(var(--code-comment)); }
  .syntax-function { color: hsl(var(--code-function)); }
  .syntax-type { color: hsl(var(--code-type)); }
  .syntax-module { color: hsl(var(--code-type)); }
  .syntax-atom { color: hsl(var(--code-function)); }
  .syntax-number { color: hsl(var(--code-string)); }
  .syntax-operator { color: hsl(var(--muted-foreground)); }

  .text-accent-green { color: hsl(var(--accent-green)); }
  .text-accent-yellow { color: hsl(var(--accent-yellow)); }
  .text-accent-cyan { color: hsl(var(--accent-cyan)); }
  .text-accent-red { color: hsl(var(--accent-red)); }

  .bg-accent-green { background-color: hsl(var(--accent-green)); }
  .bg-accent-yellow { background-color: hsl(var(--accent-yellow)); }
  .bg-accent-cyan { background-color: hsl(var(--accent-cyan)); }
  .bg-accent-red { background-color: hsl(var(--accent-red)); }

  .border-accent-green { border-color: hsl(var(--accent-green)); }
  .border-accent-yellow { border-color: hsl(var(--accent-yellow)); }
  .border-accent-cyan { border-color: hsl(var(--accent-cyan)); }
  .border-accent-red { border-color: hsl(var(--accent-red)); }
}
```

---

## Phase 2: LiveView Components
**Effort: 1-3 hours**

### File Structure

```
lib/agent_jido_web/components/
  jido/
    marketing_layouts.ex     # Layout, header, footer
    marketing_cards.ex       # Package cards, feature cards, metric cards
    marketing_code.ex        # Code block component
    marketing_ecosystem.ex   # Ecosystem-specific partials
```

### 2.1 Marketing Layouts (`marketing_layouts.ex`)

```elixir
defmodule AgentJidoWeb.Jido.MarketingLayouts do
  use AgentJidoWeb, :html

  attr :title, :string, default: "Jido"
  slot :inner_block, required: true

  def marketing_layout(assigns) do
    ~H"""
    <div class="min-h-screen flex flex-col bg-background text-foreground">
      <.header />
      <main class="flex-1">
        <%= render_slot(@inner_block) %>
      </main>
      <.footer />
    </div>
    """
  end

  def header(assigns) do
    ~H"""
    <header class="sticky top-0 z-50 bg-background/80 backdrop-blur-md pt-6 pb-12">
      <div class="container max-w-[1000px] mx-auto px-6">
        <nav class="nav-surface flex justify-between items-center px-6 py-5">
          <!-- Logo -->
          <.link navigate="/" class="flex items-center gap-2.5">
            <div class="w-7 h-7 rounded flex items-center justify-center font-bold text-primary-foreground bg-gradient-to-br from-primary to-accent-yellow text-sm">
              J
            </div>
            <span class="font-bold tracking-wide">JIDO</span>
            <span class="text-muted-foreground text-[11px] ml-1">v0.1.0</span>
          </.link>

          <!-- Desktop Navigation -->
          <div class="hidden md:flex items-center gap-7">
            <.link navigate="/ecosystem" class="text-xs text-secondary-foreground hover:text-foreground">/ecosystem</.link>
            <.link navigate="/partners" class="text-xs text-secondary-foreground hover:text-foreground">/partners</.link>
            <.link navigate="/examples" class="text-xs text-secondary-foreground hover:text-foreground">/examples</.link>
            <.link navigate="/benchmarks" class="text-xs text-secondary-foreground hover:text-foreground">/benchmarks</.link>
            <.link navigate="/docs" class="text-xs text-secondary-foreground hover:text-foreground">/docs</.link>
          </div>

          <!-- CTA -->
          <div class="hidden md:block">
            <.link navigate="/getting-started" class="bg-primary text-primary-foreground hover:bg-primary/90 text-xs font-bold px-4 py-2.5 rounded">
              $ GET STARTED
            </.link>
          </div>
        </nav>
      </div>
    </header>
    """
  end

  def footer(assigns) do
    ~H"""
    <footer class="border-t border-border py-8 mt-16">
      <div class="container max-w-[1000px] mx-auto px-6 text-center text-xs text-muted-foreground">
        <p>© 2024 AgentJido. MIT License.</p>
      </div>
    </footer>
    """
  end
end
```

### 2.2 Marketing Cards (`marketing_cards.ex`)

```elixir
defmodule AgentJidoWeb.Jido.MarketingCards do
  use AgentJidoWeb, :html

  attr :name, :string, required: true
  attr :desc, :string, required: true
  attr :layer, :atom, values: [:core, :ai, :foundation, :app], required: true
  attr :links, :map, default: %{}

  def package_card(assigns) do
    ~H"""
    <div class={"package-card-#{@layer} hover:-translate-y-0.5 cursor-pointer"}>
      <div class="flex justify-between items-start mb-3">
        <span class="text-sm font-bold text-foreground"><%= @name %></span>
        <.layer_badge layer={@layer} />
      </div>
      <p class="text-xs text-muted-foreground leading-relaxed mb-4"><%= @desc %></p>
      <div class="flex gap-2">
        <%= for {label, href} <- @links do %>
          <a href={href} target="_blank" class="text-[10px] px-2 py-1 rounded bg-elevated text-muted-foreground hover:text-primary transition-colors">
            <%= label %>
          </a>
        <% end %>
      </div>
    </div>
    """
  end

  attr :layer, :atom, values: [:core, :ai, :foundation, :app], required: true

  def layer_badge(assigns) do
    ~H"""
    <span class={"badge-#{@layer} uppercase"}><%= @layer %></span>
    """
  end

  attr :value, :string, required: true
  attr :label, :string, required: true
  attr :color_class, :string, default: "text-accent-green"

  def metric_card(assigns) do
    ~H"""
    <div class="metric-card">
      <div class={"text-xl sm:text-[22px] font-bold #{@color_class}"}>
        <%= @value %>
      </div>
      <div class="text-[10px] text-muted-foreground uppercase tracking-wider mt-1.5">
        <%= @label %>
      </div>
    </div>
    """
  end

  slot :inner_block, required: true

  def feature_card(assigns) do
    ~H"""
    <div class="feature-card">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
```

### 2.3 Marketing Code (`marketing_code.ex`)

```elixir
defmodule AgentJidoWeb.Jido.MarketingCode do
  use AgentJidoWeb, :html

  attr :title, :string, default: nil
  attr :language, :string, default: "elixir"
  attr :code, :string, required: true

  def code_block(assigns) do
    ~H"""
    <div class="code-block">
      <%= if @title do %>
        <div class="code-header">
          <div class="flex gap-2">
            <span class="w-2.5 h-2.5 rounded-full bg-accent-red"></span>
            <span class="w-2.5 h-2.5 rounded-full bg-accent-yellow"></span>
            <span class="w-2.5 h-2.5 rounded-full bg-primary"></span>
          </div>
          <span class="text-[10px] text-muted-foreground"><%= @title %></span>
        </div>
      <% end %>
      <pre class="p-5 text-[11px] leading-relaxed overflow-x-auto"><code class={"language-#{@language}"}><%= @code %></code></pre>
    </div>
    """
  end
end
```

---

## Phase 3: Routes & LiveViews
**Effort: 3-8 hours**

### 3.1 Add LiveViews

Create files in `lib/agent_jido_web/live/`:

```
lib/agent_jido_web/live/
  jido_home_live.ex
  jido_ecosystem_live.ex
  jido_getting_started_live.ex
  jido_examples_live.ex
  jido_benchmarks_live.ex
  jido_partners_live.ex
```

### 3.2 Update Router

In `lib/agent_jido_web/router.ex`:

```elixir
scope "/", AgentJidoWeb do
  pipe_through(:browser)

  # New marketing pages
  live "/", JidoHomeLive, :index
  live "/ecosystem", JidoEcosystemLive, :index
  live "/getting-started", JidoGettingStartedLive, :index
  live "/examples", JidoExamplesLive, :index
  live "/benchmarks", JidoBenchmarksLive, :index
  live "/partners", JidoPartnersLive, :index

  # Keep existing routes
  get("/discord", PageController, :discord)
  # ... rest of existing routes
end
```

### 3.3 Example LiveView Structure

```elixir
defmodule AgentJidoWeb.JidoHomeLive do
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts
  import AgentJidoWeb.Jido.MarketingCards
  import AgentJidoWeb.Jido.MarketingCode

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.marketing_layout>
      <div class="container max-w-[1000px] mx-auto px-6">
        <.hero_section />
        <.metrics_strip />
        <.package_ecosystem />
        <.dependency_flow />
        <.install_section />
        <.why_beam_section />
        <.quick_start_code />
        <.cta_section />
      </div>
    </.marketing_layout>
    """
  end

  # Define section components...
end
```

---

## Phase 4: State Management
**Effort: 1-3 hours**

### React useState → LiveView Assigns

| React Pattern | LiveView Pattern |
|---------------|------------------|
| `useState(value)` | `assign(socket, :key, value)` |
| `setX(newValue)` | `handle_event` + `assign` |
| Props drilling | Component attrs |

### Example: Use Case Selector

```elixir
# In mount
def mount(_params, _session, socket) do
  {:ok, assign(socket, selected_use_case: "agents")}
end

# In template
~H"""
<div class="flex gap-2">
  <button phx-click="select_use_case" phx-value-id="agents" 
          class={if @selected_use_case == "agents", do: "bg-primary", else: "bg-muted"}>
    Agents
  </button>
  <button phx-click="select_use_case" phx-value-id="llm_apps" 
          class={if @selected_use_case == "llm_apps", do: "bg-primary", else: "bg-muted"}>
    LLM Apps
  </button>
</div>
"""

# Handle event
def handle_event("select_use_case", %{"id" => id}, socket) do
  {:noreply, assign(socket, selected_use_case: id)}
end
```

### Theme Toggle (Client-Side Only)

Add to `assets/js/app.js`:

```js
const STORAGE_KEY = "jido-theme";

function applyStoredTheme() {
  const html = document.documentElement;
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored === "light") {
    html.classList.add("light");
  } else {
    html.classList.remove("light");
  }
}

applyStoredTheme();

window.toggleTheme = function() {
  const html = document.documentElement;
  const isLight = html.classList.toggle("light");
  localStorage.setItem(STORAGE_KEY, isLight ? "light" : "dark");
};
```

---

## Phase 5: Animation Handling
**Effort: 1-3 hours**

### Framer Motion → CSS

| Framer Motion | CSS/Tailwind Equivalent |
|---------------|-------------------------|
| `initial={{ opacity: 0, y: 20 }}` | Start with `opacity-0 translate-y-2` |
| `animate={{ opacity: 1, y: 0 }}` | Add `animate-fade-in` class |
| `transition={{ duration: 0.5 }}` | `duration-500` |
| `whileHover={{ scale: 1.02 }}` | `hover:scale-[1.02]` |

### Implementation

Most animations use CSS with the `animate-fade-in` keyframe:

```html
<section class="animate-fade-in">
  <!-- Content fades in on load -->
</section>
```

For hover effects:

```html
<div class="package-card-core transform transition-transform duration-200 hover:-translate-y-1">
  <!-- Card lifts on hover -->
</div>
```

### Optional: Scroll Reveal Hook

```js
// assets/js/hooks.js
export const ScrollReveal = {
  mounted() {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate-fade-in');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1 });
    
    observer.observe(this.el);
  }
}
```

---

## Phase 6: Page-by-Page Implementation
**Effort: 1-2 days**

### Priority Order

1. **`/` (Home)** - Hero, metrics, ecosystem preview, CTA
2. **`/ecosystem`** - Package cards, dependency graph, use case selector
3. **`/getting-started`** - Step-by-step guide with code blocks
4. **`/benchmarks`** - Tables, metric cards
5. **`/examples`** - Example cards with filtering
6. **`/partners`** - Partner logos and info

### Page Content Sources

Reference the React components in `jido-dev-relaunch/src/`:

| Page | React Source |
|------|--------------|
| Home | `pages/Index.tsx`, `components/home/*` |
| Ecosystem | `pages/Ecosystem.tsx` |
| Getting Started | `pages/GettingStarted.tsx` |
| Benchmarks | `pages/Benchmarks.tsx` |
| Examples | `pages/Examples.tsx` |
| Partners | `pages/Partners.tsx` |

---

## Phase 7: Docs Integration
**Effort: 1-3 hours**

Re-skin existing docs pages to match the new design:

1. Update docs layout to use `marketing_layout` wrapper
2. Apply new typography and code block styles
3. Add sidebar with new design tokens
4. Keep existing content/routing structure

---

## Checklist

- [ ] Phase 1: CSS variables and Tailwind config
- [ ] Phase 1: Component utility classes
- [ ] Phase 2: Marketing layouts component
- [ ] Phase 2: Marketing cards component
- [ ] Phase 2: Marketing code component
- [ ] Phase 3: Add routes to router.ex
- [ ] Phase 3: Create JidoHomeLive
- [ ] Phase 3: Create JidoEcosystemLive
- [ ] Phase 3: Create JidoGettingStartedLive
- [ ] Phase 3: Create JidoBenchmarksLive
- [ ] Phase 3: Create JidoExamplesLive
- [ ] Phase 3: Create JidoPartnersLive
- [ ] Phase 4: Theme toggle JS
- [ ] Phase 5: CSS animations
- [ ] Phase 6: Port home page content
- [ ] Phase 6: Port ecosystem page content
- [ ] Phase 6: Port remaining pages
- [ ] Phase 7: Re-skin docs pages
