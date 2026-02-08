# Sitemap Documentation

## Current Status

**No XML sitemap is currently implemented** in the Jido Workbench codebase.

While the codebase has an RSS feed for blog posts at `/feed`, there is no `/sitemap.xml` endpoint for search engine crawlers.

---

## Existing XML Feed: RSS

The codebase implements an **RSS feed** for blog posts (not a sitemap):

- **Endpoint:** `GET /feed`
- **Content-Type:** `application/rss+xml`
- **Controller:** `lib/agent_jido_web/controllers/blog_controller.ex:56`
- **Template:** `lib/agent_jido_web/controllers/blog_html/feed.xml.eex`

### RSS Feed Implementation

**Controller (`blog_controller.ex`):**
```elixir
def feed(conn, _params) do
  posts = Blog.all_posts()

  conn
  |> put_resp_content_type("application/xml")
  |> render(:feed, posts: posts)
end
```

**Route (`router.ex:62`):**
```elixir
get "/feed", BlogController, :feed
```

---

## Site Structure (For Future Sitemap)

The following routes exist that should be included in a sitemap:

### Marketing Pages
| Route | LiveView Module | Priority |
|-------|-----------------|----------|
| `/` | `AgentJidoWeb.JidoHomeLive` | High |
| `/ecosystem` | `AgentJidoWeb.JidoEcosystemLive` | Medium |
| `/getting-started` | `AgentJidoWeb.JidoGettingStartedLive` | High |
| `/examples` | `AgentJidoWeb.JidoExamplesLive` | Medium |
| `/benchmarks` | `AgentJidoWeb.JidoBenchmarksLive` | Low |
| `/partners` | `AgentJidoWeb.JidoPartnersLive` | Low |

### Documentation
| Route Pattern | Source | Priority |
|---------------|--------|----------|
| `/docs/*` | `AgentJido.Documentation` | High |

### Blog
| Route Pattern | Controller | Priority |
|---------------|------------|----------|
| `/blog/*` | `BlogController` | Medium |

### Catalog (if enabled)
| Route Pattern | Controller |
|---------------|------------|
| `/catalog/*` | `CatalogController` |

---

## Implementation Guide

To add a proper XML sitemap to the application:

### 1. Create a Sitemap Controller

Create `lib/agent_jido_web/controllers/sitemap_controller.ex`:

```elixir
defmodule AgentJidoWeb.SitemapController do
  use AgentJidoWeb, :controller

  def index(conn, _params) do
    urls = [
      # Static pages
      %{loc: ~p"/", lastmod: nil, changefreq: "weekly", priority: 1.0},
      %{loc: ~p"/ecosystem", lastmod: nil, changefreq: "monthly", priority: 0.8},
      # ... add all static routes
    ]

    # Add blog posts
    blog_posts = Blog.all_posts()
    blog_urls = Enum.map(blog_posts, fn post ->
      %{
        loc: ~p"/blog/#{post.id}",
        lastmod: post.date,
        changefreq: "monthly",
        priority: 0.6
      }
    end)

    # Add documentation pages
    docs_urls = Documentation.list_pages() |> Enum.map(fn page ->
      %{
        loc: ~p"/docs/#{page.slug}",
        lastmod: page.updated_at,
        changefreq: "weekly",
        priority: 0.8
      }
    end)

    conn
    |> put_resp_content_type("application/xml")
    |> render(:sitemap, urls: urls ++ blog_urls ++ docs_urls)
  end
end
```

### 2. Create the Sitemap Template

Create `lib/agent_jido_web/controllers/sitemap_html.ex`:

```elixir
defmodule AgentJidoWeb.SitemapHTML do
  use AgentJidoWeb, :html

  def sitemap(assigns) do
    ~H"""
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <%= for url <- @urls do %>
        <url>
          <loc><%= url |> Map.get(:loc) |> AgentJidoWeb.Endpoint.url() %></loc>
          <%= if url.lastmod do %>
            <lastmod><%= url.lastmod |> NaiveDateTime.to_iso8601() %></lastmod>
          <% end %>
          <changefreq><%= url.changefreq %></changefreq>
          <priority><%= url.priority %></priority>
        </url>
      <% end %>
    </urlset>
    """
  end
end
```

### 3. Add the Route

Add to `lib/agent_jido_web/router.ex`:

```elixir
get "/sitemap.xml", SitemapController, :index
```

### 4. Add to robots.txt

Ensure `priv/static/robots.txt` references the sitemap:

```
User-agent: *
Allow: /

Sitemap: https://your-domain.com/sitemap.xml
```

---

## Design Document Reference

The planned sitemap structure is documented in `BENCH_DESIGN.md:502` under the Sitemap section, which outlines the marketing routes and docs navigation hierarchy.
