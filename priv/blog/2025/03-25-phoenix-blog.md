%{
title: "Building a Phoenix Blog",
author: "Mike Hostetler",
tags: ~w(phoenix blog elixir),
description: "A guide to building a blog with Phoenix Framework"
}

---

# Building a Phoenix Blog

Phoenix Framework makes it easy to build a blog with its powerful features. In this post, we'll explore how to use NimblePublisher to create a blog with minimal effort.

## Getting Started

First, you'll need to add NimblePublisher to your dependencies:

```elixir
def deps do
  [
    {:nimble_publisher, "~> 0.1.3"}
  ]
end
```

## Setting Up the Blog Module

Create a module to manage your blog posts:

```elixir
defmodule MyApp.Blog do
  alias MyApp.Blog.Post

  use NimblePublisher,
    build: Post,
    from: Application.app_dir(:my_app, "priv/blog/**/*.md"),
    as: :posts,
    highlighters: [:makeup_elixir, :makeup_js]

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  def all_posts, do: @posts
  def all_tags, do: @tags
end
```

## Creating Post Models

Define your post struct:

```elixir
defmodule MyApp.Blog.Post do
  @enforce_keys [:id, :author, :title, :body, :description, :tags, :date]
  defstruct [:id, :author, :title, :body, :description, :tags, :date]

  def build(filename, attrs, body) do
    # Parse the filename to extract the date and ID
    # ...
    struct!(__MODULE__, [id: id, date: date, body: body] ++ Map.to_list(attrs))
  end
end
```

## Next Steps

With these components in place, you can now:

1. Add blog posts as Markdown files in your priv/blog directory
2. Create controllers and templates to display your posts
3. Implement features like pagination, search, and comments

Stay tuned for more Phoenix tips and tricks! 