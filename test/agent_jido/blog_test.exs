defmodule AgentJido.BlogTest do
  use ExUnit.Case, async: true

  alias AgentJido.Blog

  test "all_posts returns static posts with canonicalized slugs" do
    post_ids = Blog.all_posts() |> Enum.map(& &1.id)

    assert "jido-2-0-is-here" in post_ids
    assert "introducing-req-llm" in post_ids
    assert "announcing-req-llm-1-0" in post_ids
    assert "jido-signal" in post_ids

    refute "introducing-req_llm" in post_ids
    refute "announcing-req_llm-1_0" in post_ids
    refute "jido_signal" in post_ids
  end

  test "get_published_post_by_slug!/1 resolves legacy filename slugs to canonical slugs" do
    post = Blog.get_published_post_by_slug!("introducing-req_llm")

    assert post.id == "introducing-req-llm"
    assert post.title == "Introducing ReqLLM: Req Plugins for LLM Interactions"
  end

  test "get_post_by_id!/1 returns canonical static post" do
    post = Blog.get_post_by_id!("announcing-req-llm-1-0")

    assert post.id == "announcing-req-llm-1-0"
    assert post.author == "Mike Hostetler"
    assert post.source_path =~ "/priv/blog/2025/11-03-announcing-req_llm-1_0.livemd"
  end

  test "get_post_by_id!/1 returns newly added static post" do
    post = Blog.get_post_by_id!("jido-2-0-is-here")

    assert post.title == "Jido 2.0 is now available"
    assert post.author == "Mike Hostetler"
    assert post.source_path =~ "/priv/blog/2026/03-04-jido-2-0-is-here.md"
  end

  test "get_published_post_by_slug!/1 raises for missing posts" do
    assert_raise Blog.NotFoundError, fn ->
      Blog.get_published_post_by_slug!("missing-post")
    end
  end

  test "source/0 reports static content" do
    assert Blog.source() == :static
  end
end
