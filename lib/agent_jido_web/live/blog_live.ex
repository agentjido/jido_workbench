defmodule AgentJidoWeb.BlogLive do
  @moduledoc """
  LiveView-backed blog index, tag listing, and post show pages.
  """
  use AgentJidoWeb, :live_view

  import AgentJidoWeb.Jido.MarketingLayouts

  alias AgentJido.Blog

  @blog_og_image "https://agentjido.xyz/og/blog.png"
  @blog_index_description "Product updates, technical write-ups, and release notes from the Jido project."

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, tags: Blog.all_tags())}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      case socket.assigns.live_action do
        :index -> assign_index(socket)
        :show -> assign_show(socket, params)
        :tag -> assign_tag(socket, params)
      end

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.marketing_layout current_path="/blog">
      <%= case @live_action do %>
        <% :index -> %>
          <.blog_index posts={@posts} tags={@tags} />
        <% :tag -> %>
          <.blog_tag posts={@posts} tags={@tags} tag={@tag} />
        <% :show -> %>
          <.blog_show post={@post} />
      <% end %>
    </.marketing_layout>
    """
  end

  attr :posts, :list, required: true
  attr :tags, :list, required: true

  defp blog_index(assigns) do
    ~H"""
    <div id="blog-index-page" class="container max-w-[1000px] mx-auto px-6 py-12">
      <h1 class="text-3xl font-bold mb-8 text-foreground">Listing all posts</h1>

      <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
        <div class="lg:col-span-3">
          <%= for post <- @posts do %>
            <.post_card post={post} />
          <% end %>
        </div>

        <div class="lg:col-span-1">
          <div class="sticky top-24 bg-card rounded-lg p-6 border border-border">
            <h2 class="text-xl font-bold mb-4 text-foreground">Tags</h2>
            <div class="flex flex-wrap gap-2 mb-6">
              <%= for tag <- @tags do %>
                <.link
                  patch={~p"/blog/tags/#{tag}"}
                  class="inline-block bg-elevated rounded-full px-3 py-1 text-sm text-muted-foreground hover:text-foreground transition-colors"
                >
                  {tag}
                </.link>
              <% end %>
            </div>

            <h2 class="text-xl font-bold mb-4 text-foreground">Follow us</h2>
            <div class="flex gap-4">
              <a
                href="https://github.com/agentjido/jido"
                class="text-muted-foreground hover:text-foreground transition-colors"
              >
                <AgentJidoWeb.Jido.Nav.github_icon class="w-6 h-6" />
              </a>
              <a
                href="https://x.com/agentjido"
                class="text-muted-foreground hover:text-foreground transition-colors"
              >
                <AgentJidoWeb.Jido.Nav.x_icon class="w-6 h-6" />
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :posts, :list, required: true
  attr :tags, :list, required: true
  attr :tag, :string, required: true

  defp blog_tag(assigns) do
    ~H"""
    <div id="blog-tag-page" class="container max-w-[1000px] mx-auto px-6 py-12">
      <div class="mb-6">
        <.link patch={~p"/blog"} class="text-primary hover:opacity-80 flex items-center gap-1 transition-opacity text-sm">
          <.icon name="hero-arrow-left" class="h-4 w-4" /> Back to all posts
        </.link>
      </div>

      <h1 class="text-3xl font-bold mb-8 text-foreground">Posts tagged with "{@tag}"</h1>

      <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
        <div class="lg:col-span-3">
          <%= for post <- @posts do %>
            <.post_card post={post} />
          <% end %>
        </div>

        <div class="lg:col-span-1">
          <div class="sticky top-24 bg-card rounded-lg p-6 border border-border">
            <h2 class="text-xl font-bold mb-4 text-foreground">Tags</h2>
            <div class="flex flex-wrap gap-2 mb-6">
              <%= for tag <- @tags do %>
                <.link
                  patch={~p"/blog/tags/#{tag}"}
                  class={
                    if tag == @tag,
                      do: "inline-block bg-primary text-primary-foreground rounded-full px-3 py-1 text-sm transition-colors",
                      else: "inline-block bg-elevated rounded-full px-3 py-1 text-sm text-muted-foreground hover:text-foreground transition-colors"
                  }
                >
                  {tag}
                </.link>
              <% end %>
            </div>

            <h2 class="text-xl font-bold mb-4 text-foreground">Follow us</h2>
            <div class="flex gap-4 mb-6">
              <a
                href="https://github.com/agentjido/jido"
                class="text-muted-foreground hover:text-foreground transition-colors"
              >
                <AgentJidoWeb.Jido.Nav.github_icon class="w-6 h-6" />
              </a>
              <a
                href="https://x.com/agentjido"
                class="text-muted-foreground hover:text-foreground transition-colors"
              >
                <AgentJidoWeb.Jido.Nav.x_icon class="w-6 h-6" />
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :post, :map, required: true

  defp blog_show(assigns) do
    ~H"""
    <div id="blog-show-page" class="container max-w-[900px] mx-auto px-6 py-12">
      <div class="mb-6">
        <.link patch={~p"/blog"} class="text-primary hover:opacity-80 flex items-center gap-1 transition-opacity text-sm">
          <.icon name="hero-arrow-left" class="h-4 w-4" /> Back to all posts
        </.link>
      </div>

      <article class="bg-card rounded-lg overflow-hidden border border-border">
        <div class="p-8">
          <h1 class="text-3xl md:text-4xl font-bold mb-4 text-foreground">{@post.title}</h1>

          <div class="flex items-center gap-4 text-muted-foreground mb-6 text-sm">
            <div>by {@post.author}</div>
            <div>•</div>
            <div>{format_date(@post.date)}</div>
          </div>

          <div class="flex flex-wrap gap-2 mb-6">
            <%= for tag <- @post.tags do %>
              <.link
                patch={~p"/blog/tags/#{tag}"}
                class="inline-block bg-elevated rounded-full px-3 py-1 text-sm text-muted-foreground hover:text-foreground transition-colors"
              >
                {tag}
              </.link>
            <% end %>
          </div>

          <div class="prose prose-sm max-w-none text-foreground/80">
            {Phoenix.HTML.raw(@post.body)}
          </div>
        </div>
      </article>
    </div>
    """
  end

  attr :post, :map, required: true

  defp post_card(assigns) do
    ~H"""
    <div class="bg-card rounded-lg mb-8 overflow-hidden border border-border">
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-2">
          <.link patch={~p"/blog/#{@post.id}"} class="text-primary hover:opacity-80 transition-opacity">
            {@post.title}
          </.link>
        </h2>
        <div class="text-muted-foreground mb-3">
          by {@post.author} • {format_date(@post.date)}
        </div>
        <div class="prose prose-sm max-w-none mb-4 text-muted-foreground">
          <p>{summary_text(@post)}</p>
        </div>
        <div class="flex flex-wrap gap-2">
          <%= for tag <- @post.tags do %>
            <.link
              patch={~p"/blog/tags/#{tag}"}
              class="inline-block bg-elevated rounded-full px-3 py-1 text-sm text-muted-foreground hover:text-foreground transition-colors"
            >
              {tag}
            </.link>
          <% end %>
        </div>
        <div class="mt-4">
          <.link
            patch={~p"/blog/#{@post.id}"}
            class="inline-flex items-center px-4 py-2 bg-primary text-primary-foreground hover:opacity-90 rounded-md transition-opacity text-sm font-medium"
          >
            Read More
          </.link>
        </div>
      </div>
    </div>
    """
  end

  defp assign_index(socket) do
    assign(socket,
      page_title: "Blog",
      meta_description: @blog_index_description,
      og_image: @blog_og_image,
      posts: Blog.all_posts(),
      tags: Blog.all_tags()
    )
  end

  defp assign_show(socket, %{"slug" => slug}) do
    post = Blog.get_post_by_id!(slug)
    seo = post_seo(post)
    canonical_url = seo_value(seo, :canonical_url)
    og_description = seo_value(seo, :og_description)
    noindex? = seo_value(seo, :noindex) == true

    assign(socket,
      page_title: post.title,
      meta_description: post_meta_description(post),
      og_description: og_description,
      canonical_url: canonical_url,
      robots: if(noindex?, do: ["noindex", "nofollow"]),
      og_image: seo_value(seo, :og_image) || "https://agentjido.xyz/og/blog/#{slug}",
      post: post,
      seo: seo
    )
  end

  defp assign_tag(socket, %{"tag" => tag}) do
    assign(socket,
      page_title: "Blog: #{tag}",
      meta_description: tag_meta_description(tag),
      og_image: @blog_og_image,
      posts: Blog.get_posts_by_tag!(tag),
      tag: tag,
      tags: Blog.all_tags()
    )
  end

  defp format_date(date) do
    Calendar.strftime(date, "%B %d, %Y")
  end

  defp preview(body) do
    body
    |> String.slice(0, 150)
    |> String.split(~r/\s/)
    |> Enum.drop(-1)
    |> Enum.join(" ")
    |> Kernel.<>("...")
  end

  defp summary_text(post) do
    case post.description |> to_string() |> String.trim() do
      "" -> preview(post.body)
      description -> description
    end
  end

  defp tag_meta_description(tag) do
    "Posts tagged with \"#{tag}\" from the Jido blog, including product updates, technical write-ups, and release notes."
  end

  defp post_meta_description(post) do
    post
    |> summary_text()
    |> to_string()
    |> String.trim()
  end

  defp post_seo(post) do
    Map.get(post, :seo, %{}) || %{}
  end

  defp seo_value(seo, key) do
    Map.get(seo, key) || Map.get(seo, Atom.to_string(key))
  end
end
