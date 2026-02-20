defmodule AgentJido.OGImage.ResolverTest do
  use ExUnit.Case, async: true

  alias AgentJido.Blog
  alias AgentJido.Ecosystem
  alias AgentJido.Examples
  alias AgentJido.OGImage.Resolver
  alias AgentJido.Pages

  test "resolves top-level marketing route metadata" do
    {:ok, descriptor} = Resolver.resolve_path("/features")

    assert descriptor.template == :marketing
    assert descriptor.title == "Jido Features"
    assert descriptor.cache_key =~ "v3:path=/features:hash="
  end

  test "resolves blog posts to blog_post descriptors" do
    slug = Blog.all_posts() |> hd() |> Map.get(:id)

    {:ok, descriptor} = Resolver.resolve_path("/blog/#{slug}")

    assert descriptor.template == :blog_post
    assert descriptor.resolved_path == "/blog/#{slug}"
    assert descriptor.title != ""
  end

  test "resolves examples to example descriptors" do
    slug = Examples.all_examples() |> hd() |> Map.get(:slug)

    {:ok, descriptor} = Resolver.resolve_path("/examples/#{slug}")

    assert descriptor.template == :example
    assert descriptor.resolved_path == "/examples/#{slug}"
  end

  test "resolves ecosystem packages to ecosystem descriptors" do
    id = Ecosystem.public_packages() |> hd() |> Map.get(:id)

    {:ok, descriptor} = Resolver.resolve_path("/ecosystem/#{id}")

    assert descriptor.template == :ecosystem_package
    assert descriptor.resolved_path == "/ecosystem/#{id}"
  end

  test "resolves docs detail pages to docs templates" do
    docs_path =
      Pages.pages_by_category(:docs)
      |> Enum.map(&Pages.route_for/1)
      |> Enum.find(&(&1 != "/docs"))
      |> Kernel.||("/docs")

    {:ok, descriptor} = Resolver.resolve_path(docs_path)

    assert descriptor.template == :docs_page
    assert descriptor.resolved_path == docs_path
  end

  test "unknown paths resolve to not_found descriptor" do
    {:ok, descriptor} = Resolver.resolve_path("/totally/missing/path")

    assert descriptor.template == :not_found
    assert descriptor.title == "Page Not Found"
  end

  test "cache key changes when descriptor hash input changes" do
    {:ok, first} = Resolver.resolve_path("/totally/missing/path-a")
    {:ok, second} = Resolver.resolve_path("/totally/missing/path-b")

    refute first.content_hash == second.content_hash
    refute first.cache_key == second.cache_key
  end
end
