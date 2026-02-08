# BENCH_DESIGN.md - Jido Workbench Design System

This document captures the complete design system from the `jido-dev-relaunch` React codebase for implementation in Phoenix LiveView.

---

## Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Spacing & Layout](#spacing--layout)
5. [Border Radius](#border-radius)
6. [Component Classes](#component-classes)
7. [Syntax Highlighting](#syntax-highlighting)
8. [Animations](#animations)
9. [Dark/Light Mode](#darklight-mode)
10. [Sitemap](#sitemap)
11. [Copywriting Reference](#copywriting-reference)
12. [Component Inventory](#component-inventory)
13. [Docs Layout System](#docs-layout-system)
14. [Implementation Guide](#implementation-guide)

---

## Design Philosophy

The design follows a **terminal/code-centric aesthetic**:

- **Dark-first**: Dark mode is the default, with light mode as an option
- **Monospace everywhere**: IBM Plex Mono is used for all text, not just code
- **Hacker feel**: Small caps, tracking-wider labels, terminal-inspired surfaces
- **4-color accent system**: Green (primary), Yellow (AI), Cyan (Foundation), Red (App)
- **Minimal chrome**: Subtle borders, no shadows, flat design

---

## Color System

All colors are defined as HSL CSS custom properties for easy theming.

### Dark Mode (Default) - `:root`

```css
/* Background layers */
--background: 0 0% 4%;        /* #0a0a0a - near black */
--foreground: 0 0% 91%;       /* #e8e8e8 - light grey text */
--surface: 0 0% 7%;           /* #121212 - slightly elevated */
--elevated: 0 0% 10%;         /* #1a1a1a - more elevated */

/* Cards & Popovers */
--card: 0 0% 7%;
--card-foreground: 0 0% 91%;
--popover: 0 0% 7%;
--popover-foreground: 0 0% 91%;

/* Primary - Neon Green */
--primary: 152 100% 50%;      /* #00ff7f - neon green */
--primary-foreground: 0 0% 4%;

/* Secondary */
--secondary: 0 0% 10%;
--secondary-foreground: 0 0% 85%;

/* Muted */
--muted: 0 0% 16%;
--muted-foreground: 0 0% 40%;

/* 4-Color Accent System */
--accent-green: 152 100% 50%;   /* Primary green */
--accent-yellow: 43 100% 50%;   /* AI/LLM - gold */
--accent-cyan: 192 100% 50%;    /* Foundation - cyan */
--accent-red: 0 73% 71%;        /* App layer - coral red */

/* Default accent uses cyan */
--accent: 192 100% 50%;
--accent-foreground: 0 0% 4%;

/* Destructive */
--destructive: 0 73% 71%;
--destructive-foreground: 0 0% 98%;

/* Borders & Input */
--border: 0 0% 16%;
--border-strong: 0 0% 23%;
--input: 0 0% 16%;
--ring: 152 100% 50%;

/* Code block tokens */
--code-bg: 0 0% 3%;
--code-border: 0 0% 16%;
--code-keyword: 152 100% 50%;   /* green - defmodule, def, do, end */
--code-string: 43 100% 50%;     /* yellow - "strings" */
--code-comment: 0 0% 40%;       /* grey - # comments */
--code-function: 192 100% 50%;  /* cyan - function names */
--code-type: 0 73% 71%;         /* red - module names, types */

/* Sidebar */
--sidebar-background: 0 0% 5%;
--sidebar-foreground: 0 0% 90%;
--sidebar-primary: 152 100% 50%;
--sidebar-primary-foreground: 0 0% 4%;
--sidebar-accent: 0 0% 10%;
--sidebar-accent-foreground: 0 0% 90%;
--sidebar-border: 0 0% 16%;
--sidebar-ring: 152 100% 50%;

/* Radius */
--radius: 0.375rem;  /* 6px */
```

### Light Mode - `.light`

```css
--background: 40 33% 98%;       /* warm off-white */
--foreground: 24 10% 10%;       /* near-black text */

--surface: 0 0% 100%;
--elevated: 40 20% 96%;

--card: 0 0% 100%;
--card-foreground: 24 10% 10%;

--popover: 0 0% 100%;
--popover-foreground: 24 10% 10%;

/* Primary - Darker green for light mode */
--primary: 160 84% 39%;
--primary-foreground: 0 0% 98%;

--secondary: 40 20% 94%;
--secondary-foreground: 24 10% 10%;

--muted: 40 20% 92%;
--muted-foreground: 24 8% 45%;

/* Accent colors - darker for light mode */
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

/* Code tokens - darker for light mode */
--code-bg: 40 20% 96%;
--code-border: 24 6% 91%;
--code-keyword: 160 84% 39%;
--code-string: 32 95% 44%;
--code-comment: 24 8% 65%;
--code-function: 189 94% 43%;
--code-type: 0 72% 51%;
```

### Accent Color Semantic Meaning

| Accent | HSL (Dark) | Usage |
|--------|------------|-------|
| Green | `152 100% 50%` | Primary actions, Core packages, success states |
| Yellow | `43 100% 50%` | AI/LLM packages, warnings, highlights |
| Cyan | `192 100% 50%` | Foundation packages, links, info states |
| Red | `0 73% 71%` | App packages, destructive actions, errors |

---

## Typography

### Font Stack

```css
font-family: 'IBM Plex Mono', ui-monospace, monospace;
```

**Import in HTML head:**
```html
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500;600;700&display=swap">
```

### Type Scale

| Purpose | Classes | Example |
|---------|---------|---------|
| Hero headline | `text-4xl sm:text-[42px] font-bold leading-tight tracking-tight` | "From LLM calls to autonomous agents" |
| Section title | `text-2xl font-bold` or `text-lg font-bold` | "Single-Node Benchmarks" |
| Body text | `text-[15px] leading-relaxed` or `text-sm` | Paragraph copy |
| Small text | `text-xs` (12px) | Navigation links, descriptions |
| Micro text | `text-[11px]` or `text-[10px]` | Labels, badges, version numbers |
| Code | `text-[13px]` or `text-[11px]` | Code blocks |

### Label Style

For section headers and badges:
```css
text-[11px] font-semibold tracking-widest uppercase
/* or */
text-xs font-bold tracking-wider
```

---

## Spacing & Layout

### Container

```css
container: {
  center: true,
  padding: "1.5rem",  /* 24px */
  screens: {
    "2xl": "1000px",  /* max-width */
  },
}
```

### Section Spacing

| Element | Spacing |
|---------|---------|
| Between sections | `mb-16` (64px) |
| Section content | `mb-12` (48px) |
| Between cards | `gap-3` or `gap-4` (12-16px) |
| Card padding | `p-5` or `p-6` (20-24px) |

### Common Patterns

```html
<!-- Page section -->
<section class="mb-16">
  <div class="flex justify-between items-center mb-6">
    <span class="font-bold text-sm tracking-wider">SECTION TITLE</span>
    <a class="text-primary text-xs hover:underline">view all →</a>
  </div>
  <!-- content -->
</section>

<!-- Hero badge -->
<div class="inline-block bg-primary/10 border border-primary/30 px-4 py-2 rounded mb-6">
  <span class="text-primary text-[11px] font-semibold tracking-widest">
    BEAM-NATIVE AGENT ECOSYSTEM
  </span>
</div>
```

---

## Border Radius

```css
--radius: 0.375rem;  /* 6px base */

/* Tailwind mapping */
rounded-lg: var(--radius);           /* 6px */
rounded-md: calc(var(--radius) - 2px);  /* 4px */
rounded-sm: calc(var(--radius) - 4px);  /* 2px */
```

Most components use `rounded-md` or `rounded`.

---

## Component Classes

### Package Cards (with colored top border)

```css
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
```

### Badges

```css
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
```

### Code Blocks

```css
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
```

### Metric Card

```css
.metric-card {
  @apply text-center py-5 px-4;
  background: hsl(var(--surface));
}
```

### Feature Card

```css
.feature-card {
  @apply bg-card border border-border rounded-md p-6 transition-all duration-200;
}

.feature-card:hover {
  @apply border-primary/50;
}
```

### CTA Glow

```css
.cta-glow {
  background: hsl(var(--primary) / 0.05);
  border: 1px solid hsl(var(--primary) / 0.2);
}
```

### Nav Surface

```css
.nav-surface {
  @apply bg-card border border-border rounded-md;
}
```

### Gradient Text

```css
.gradient-text {
  background: linear-gradient(135deg, hsl(var(--accent-green)), hsl(var(--accent-yellow)));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
```

---

## Syntax Highlighting

```css
/* Token classes */
.syntax-keyword { color: hsl(var(--code-keyword)); }   /* green - def, defmodule, do, end */
.syntax-string { color: hsl(var(--code-string)); }     /* yellow - "strings" */
.syntax-comment { color: hsl(var(--code-comment)); }   /* grey - # comments */
.syntax-function { color: hsl(var(--code-function)); } /* cyan - function names */
.syntax-type { color: hsl(var(--code-type)); }         /* red - Module names, types */
.syntax-module { color: hsl(var(--code-type)); }       /* same as type */
.syntax-atom { color: hsl(var(--code-function)); }     /* cyan - :atoms */
.syntax-number { color: hsl(var(--code-string)); }     /* yellow - numbers */
.syntax-operator { color: hsl(var(--muted-foreground)); } /* grey - operators */

/* Accent color utilities */
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
```

---

## Animations

### Keyframes (Tailwind config)

```javascript
keyframes: {
  "accordion-down": {
    from: { height: "0" },
    to: { height: "var(--radix-accordion-content-height)" },
  },
  "accordion-up": {
    from: { height: "var(--radix-accordion-content-height)" },
    to: { height: "0" },
  },
  "fade-in": {
    from: { opacity: "0", transform: "translateY(10px)" },
    to: { opacity: "1", transform: "translateY(0)" },
  },
},
animation: {
  "accordion-down": "accordion-down 0.2s ease-out",
  "accordion-up": "accordion-up 0.2s ease-out",
  "fade-in": "fade-in 0.5s ease-out forwards",
},
```

### Usage

```html
<!-- Fade in on mount -->
<div class="animate-fade-in">...</div>

<!-- With delay (add custom utilities or inline styles) -->
<div class="animate-fade-in" style="animation-delay: 0.1s">...</div>
```

---

## Dark/Light Mode

### Implementation

Dark mode is the default. Light mode is activated by adding `.light` class to `<html>`.

```javascript
// In <head> before CSS loads (prevents FOUC)
(function() {
  try {
    var saved = localStorage.getItem("theme");
    var prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    if (saved === "light" || (!saved && !prefersDark)) {
      document.documentElement.classList.add("light");
    }
  } catch (e) {}
})();
```

### Toggle UI

Fixed position toggle in header:

```html
<div class="fixed top-4 right-4 z-[100] flex gap-1 bg-surface border border-border rounded p-1">
  <button class="px-3 py-1.5 rounded text-[10px] font-semibold" data-theme="dark">DARK</button>
  <button class="px-3 py-1.5 rounded text-[10px] font-semibold" data-theme="light">LIGHT</button>
</div>
```

---

## Sitemap

### Main Navigation

| Route | Page | Layout |
|-------|------|--------|
| `/` | Home (Index) | Main Layout |
| `/ecosystem` | Package Ecosystem | Main Layout |
| `/partners` | Partners & Integrations | Main Layout |
| `/examples` | Production Examples | Main Layout |
| `/benchmarks` | Benchmarks & Proof | Main Layout |
| `/getting-started` | Getting Started | Main Layout |

### Docs Navigation

| Route | Page | Layout |
|-------|------|--------|
| `/docs` | Docs Index (Introduction) | Docs Layout (3-column) |
| `/docs/installation` | Installation | Docs Layout |
| `/docs/quickstart` | Quick Start | Docs Layout |

### Header Navigation Links

```
/ecosystem  /partners  /examples  /benchmarks  /docs
```

Plus: "Premium Support" mailto link and "$ GET STARTED" CTA button.

---

## Copywriting Reference

### Home Page (Index)

#### Hero Section

**Badge:** `BEAM-NATIVE AGENT ECOSYSTEM`

**Headline:**
```
From LLM calls to
autonomous agents
```
(with colored spans: "LLM calls" in cyan, "autonomous agents" in green)

**Subheadline:**
```
7 composable packages. One unified stack.
Run 10,000+ agents on a single BEAM node.
```

**CTAs:**
- Primary: `EXPLORE ECOSYSTEM →` (green)
- Secondary: `VIEW BENCHMARKS` (yellow outline)

#### Metrics Strip

| Value | Label | Color |
|-------|-------|-------|
| 10,000+ | agents/node | green |
| ~200MB | RAM @ 5k agents | yellow |
| <1ms | message latency | cyan |
| 7 | packages | red |

#### Package Ecosystem Section

**Header:** `PACKAGE ECOSYSTEM` / `4 layers • composable by design`

**Packages by Layer:**

**App Layer (Red):**
- `jido_coder` - AI coding agent with file operations, git integration, and test execution

**AI Layer (Yellow):**
- `jido_ai` - LLM-powered agents with token/cost tracking, tool calling, and streaming
- `jido_behaviortree` - Behavior tree execution for complex agent decision-making

**Core Layer (Green):**
- `jido` - BEAM-native bot framework. OTP supervision, isolated processes, 10k+ agents per node
- `jido_action` - Schema-based action validation. Required fields, defaults, type constraints
- `jido_signal` - Pub/sub signaling between agents. Decoupled coordination via message-passing

**Foundation Layer (Cyan):**
- `req_llm` - HTTP client for LLM APIs. Built on Req with retries, rate limiting, streaming
- `llmdb` - Model registry and metadata. Token limits, pricing, capabilities for all major providers

#### Why BEAM-Native Section

**Header:** `WHY BEAM-NATIVE?`

| Icon | Title | Description |
|------|-------|-------------|
| ◉ (green) | Isolated Processes | Each agent runs in its own BEAM process with isolated state. No shared memory, no locks. |
| ⟳ (yellow) | OTP Supervision | When agents crash, supervisors restart them in milliseconds. No external orchestrator needed. |
| ⚡ (cyan) | Native Concurrency | Preemptive scheduler handles 10k+ agents per node. True parallelism on multi-core. |

#### Install Section

**Header:** `CHOOSE YOUR STACK`

**Tabs:**
- FULL AI STACK → `:jido_coder`
- BOTS ONLY → `:jido`
- CUSTOM → mix and match

#### CTA Section

```
Ready to build?
Start with the getting started guide or explore production examples.

[$ mix jido.new my_app]  [READ THE DOCS]
```

---

### Ecosystem Page

**Badge:** `PACKAGE ECOSYSTEM`

**Headline:**
```
Most agent frameworks are monoliths.
Jido is composable.
```

**Subheadline:**
```
Use the full stack or pick the packages you need. Foundation packages for LLM handling,
core framework for autonomy, and specialized packages for AI and coding workflows.
```

**Quick Stats:**
- 7 packages
- 4 layers
- 0 forced deps

**Sections:**
- Dependency Graph (ASCII art)
- Why This Architecture? (tabbed: FOR ELIXIR/OTP DEVS / FROM OTHER ECOSYSTEMS)
- Pick Your Use Case (interactive)
- Composability In Action (code examples)
- When NOT to Use (warning box)
- Quick Reference (table)
- Production Notes (3-column grid)

---

### Partners Page

**Badge:** `PARTNERS & INTEGRATIONS`

**Headline:**
```
Building the future of
Elixir AI infrastructure
```

**Featured Partner: Ash Framework**

**Why Ash + Jido:**
- Declarative Resources
- Extension System
- Data Layer Integration
- Policy-Driven Agents
- Reactor Workflows
- Code Generation

**Ecosystem Integrations:**
| Name | Status | Description |
|------|--------|-------------|
| Phoenix | Compatible | Works seamlessly in Phoenix applications |
| LiveView | Compatible | Real-time agent UIs with LiveView |
| Oban | Planned | Background job integration for agent tasks |
| Broadway | Planned | Data pipeline processing with agents |
| Commanded | Exploring | Event sourcing with autonomous agents |
| Nx/Bumblebee | Exploring | Local ML model execution |

---

### Examples Page

**Headline:**
```
Production Examples
```

**Subheadline:**
```
These examples focus on behavior under load—agent counts, latency, memory—not toy REPL demos.
All examples are real projects or Livebooks you can run.
```

**Examples:**
1. Tool-Using Multi-Agent Research Swarm
2. Long-Lived Planning Agents
3. Streaming Log Processing
4. Cost-Aware LLM Agent Coordination
5. Multi-Node Deployment

Each with metrics and production notes.

---

### Benchmarks Page

**Headline:**
```
Benchmarks & Proof
```

**Subheadline:**
```
Claims about concurrency and resilience are cheap; these are the numbers Jido actually hits on real hardware.
```

**Summary Metrics:**
- 10,000 agents on 2-core, 4GB VM
- < 1ms median message latency
- ~20KB memory per idle agent

**Single-Node Benchmarks Table:**
| Agents | Memory | CPU | Environment |
|--------|--------|-----|-------------|
| 1,000 | 40MB | 5% | 2-core, 4GB |
| 5,000 | 180MB | 12% | 2-core, 4GB |
| 10,000 | 350MB | 22% | 4-core, 8GB |

**Multi-Node Scenarios:**
- Failover time when node dies: < 2s
- Throughput impact during outage: 33% (1 of 3 nodes)
- Agent redistribution time: < 5s

---

### Footer

**Columns:**
- Brand: Logo, tagline "BEAM-native agent framework for Elixir", status indicator, copyright
- Company: About, Blog, Careers, Contact, Partners
- Resources: Docs, Changelog, Examples, Community, Benchmarks
- Social: Discord, GitHub, x.com, LinkedIn, YouTube (with SVG icons)
- Packages: Hex, HexDocs, jido, jido_ai, req_llm

**Bottom Bar:**
- MIT License | Privacy Policy | Terms of Service
- Jido v0.1.0

---

## Component Inventory

### Components to Port

#### Layout Components

| React Component | LiveView Equivalent | Notes |
|-----------------|---------------------|-------|
| `Layout` | `layouts/site.html.heex` | Main site wrapper with Header + Footer |
| `Header` | Function component | Sticky nav, scroll shrink effect, theme toggle |
| `Footer` | Function component | 6-column grid with social icons |
| `DocsLayout` | `layouts/docs.html.heex` | 3-column docs layout |
| `DocsHeader` | Function component | Separate header for docs |
| `DocsSidebar` | LiveComponent | Collapsible left nav with sections |
| `DocsRightSidebar` | Function component | TOC with scroll spy |

#### Home Page Components

| React Component | Purpose |
|-----------------|---------|
| `HeroSection` | Badge, headline, subheadline, CTAs |
| `MetricsStrip` | 4-column metrics display |
| `PackageEcosystem` | Package cards in 3 rows |
| `DependencyFlow` | ASCII dependency graph |
| `InstallSection` | Tabbed code block with COPY button |
| `WhyBeamSection` | 3-column feature cards |
| `QuickStartCode` | Code example with syntax highlighting |
| `CTASection` | CTA box with glow effect |

#### Docs Components

| React Component | Purpose |
|-----------------|---------|
| `DocsSecondaryNav` | Secondary navigation bar |
| `DocsBreadcrumb` | Breadcrumb navigation |
| `DocsPrevNext` | Previous/Next navigation |
| `DocsCodeExample` | Code block with header and COPY |
| `DocsAskAI` | AI search button |
| `DocsSearch` | Search modal |

#### Card Components

| React Component | Purpose |
|-----------------|---------|
| `IconCard` | Icon + title + description card |
| `NumberedCard` | Numbered step card (1, 2, 3, 4) |
| `QuickstartCard` | Emoji + title card |

#### UI Primitives

| React Component | Notes |
|-----------------|-------|
| `Button` | Multiple variants: default, outline, ghost, secondary |
| `Badge` | Used for layer indicators |
| `CodeBlock` | Wrapper with header and copy functionality |
| `Tabs` | Tab navigation pattern |

---

## Docs Layout System

### Structure

```
┌─────────────────────────────────────────────────────────────┐
│                       DocsHeader                            │
├─────────────────────────────────────────────────────────────┤
│                     DocsSecondaryNav                        │
├──────────────┬──────────────────────────────┬───────────────┤
│              │                              │               │
│  DocsSidebar │      Main Content            │ DocsRight     │
│  (260px)     │      (max-w-900px)           │ Sidebar       │
│              │                              │ (200px)       │
│  Collapsible │  - Breadcrumb                │               │
│  sections    │  - Page content              │ - On This     │
│  with items  │  - Prev/Next                 │   Page (TOC)  │
│              │                              │ - Quick Links │
│              │                              │ - Edit link   │
│              │                              │               │
├──────────────┴──────────────────────────────┴───────────────┤
│                       Simple Footer                          │
└─────────────────────────────────────────────────────────────┘
```

### DocsHeader

- Logo (J gradient box) + "JIDO" + "Docs" badge
- Nav: /docs, /examples, /benchmarks, /ecosystem
- Search box with ⌘K
- "Ask AI" button (primary glow)
- GitHub, Hex links

### DocsSidebar

**Sections with collapsible items:**
- Getting Started (default open)
  - Introduction, Installation, Quick Start, Core Concepts, Production Checklist
- Packages
  - jido (CORE badge), jido_action, jido_signal, req_llm (FOUNDATION), llmdb, jido_ai (AI), jido_coder (APP)
- Agents
- Actions & Signals
- AI & LLMs
- Production
- Reference

### DocsRightSidebar

- "ON THIS PAGE" with anchor links to section IDs
- QUICK LINKS box: HexDocs, GitHub, Hex.pm
- "Edit this page →" link

### DocsIndex Page Structure

1. Breadcrumb (Docs / Getting Started / Introduction)
2. Hero: Title + description + quick install CTA
3. Get Started: 4 numbered cards
4. Package Ecosystem: 4 icon cards
5. Quickstarts: 6 emoji cards (3-column)
6. Explore the Docs: 6 icon cards (3-column)
7. Quick Example: Code block + metrics strip
8. Join the Community: CTA box with Discord/GitHub

---

## Implementation Guide

### Phoenix/LiveView Mapping

1. **Tailwind Setup**
   - Port `tailwind.config.ts` to Phoenix's Tailwind config
   - Copy all CSS custom properties and component classes to `app.css`
   - Add IBM Plex Mono font import to `root.html.heex`

2. **Layouts**
   - Create `layouts/site.html.heex` for marketing pages
   - Create `layouts/docs.html.heex` for documentation
   - Use function components for Header, Footer, etc.

3. **Function Components** (in `core_components.ex` or `components/ui.ex`)
   ```elixir
   def package_card(assigns)
   def badge(assigns)
   def code_block(assigns)
   def icon_card(assigns)
   def numbered_card(assigns)
   def quickstart_card(assigns)
   def metrics_strip(assigns)
   ```

4. **LiveComponents**
   - `DocsSidebarLive` - for collapse/expand state
   - (Most other components can be function components)

5. **Client-Side JS**
   - Theme toggle (pure JS, no LiveView)
   - Mobile menu toggle
   - Code copy button
   - Optional: scroll spy for right sidebar TOC

6. **Routes**
   ```elixir
   scope "/", AgentJidoWeb do
     pipe_through :browser
     
     get "/", PageController, :home
     live "/ecosystem", EcosystemLive
     live "/partners", PartnersLive
     live "/examples", ExamplesLive
     live "/benchmarks", BenchmarksLive
     live "/getting-started", GettingStartedLive
   end
   
   scope "/docs", AgentJidoWeb.Docs do
     pipe_through [:browser, :docs_layout]
     
     live "/", IndexLive
     live "/installation", InstallationLive
     live "/quickstart", QuickstartLive
     # ... etc
   end
   ```

### Priority Order for Implementation

1. **Phase 1: Foundation**
   - CSS custom properties (colors, code tokens)
   - Component classes (package-card, badge, code-block, etc.)
   - Typography setup (IBM Plex Mono)
   - Dark/light mode toggle

2. **Phase 2: Layout**
   - Main layout (Header + Footer)
   - Basic navigation

3. **Phase 3: Home Page**
   - Hero section
   - Metrics strip
   - Package ecosystem cards
   - CTA sections

4. **Phase 4: Content Pages**
   - Ecosystem, Partners, Examples, Benchmarks

5. **Phase 5: Docs System**
   - Docs layout (3-column)
   - Sidebar navigation
   - Right sidebar TOC
   - Docs index page

---

## Quick Reference: Key Classes

```css
/* Backgrounds */
bg-background, bg-surface, bg-elevated, bg-card, bg-code-bg

/* Text */
text-foreground, text-muted-foreground, text-secondary-foreground
text-primary, text-accent-green, text-accent-yellow, text-accent-cyan, text-accent-red

/* Borders */
border-border, border-border-strong, border-primary/30

/* Components */
.package-card-core, .package-card-ai, .package-card-foundation, .package-card-app
.badge-core, .badge-ai, .badge-foundation, .badge-app
.code-block, .code-header
.metric-card, .feature-card
.cta-glow, .nav-surface, .gradient-text

/* Syntax */
.syntax-keyword, .syntax-string, .syntax-comment, .syntax-function, .syntax-type
```
