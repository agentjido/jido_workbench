defmodule Mix.Tasks.Blog.ImportLegacyTest do
  use AgentJido.DataCase, async: false

  import ExUnit.CaptureIO

  alias AgentJido.Blog.Legacy
  alias AgentJido.Blog.SlugAlias
  alias AgentJido.Blog.TagAlias
  alias PhoenixBlog.Post, as: BlogPost

  setup do
    Repo.delete_all(SlugAlias)
    Repo.delete_all(TagAlias)
    Repo.delete_all(BlogPost)
    :ok
  end

  test "dry-run reports import and redirect counts" do
    output =
      capture_io(fn ->
        Mix.Task.reenable("blog.import_legacy")
        Mix.Tasks.Blog.ImportLegacy.run(["--dry-run"])
      end)

    assert output =~ "Legacy posts discovered:"
    assert output =~ "Legacy redirect aliases:"
    assert output =~ "Legacy tag aliases:"
  end

  test "import is idempotent" do
    run_import()

    imported_count = Repo.aggregate(BlogPost, :count)
    slug_alias_count = Repo.aggregate(SlugAlias, :count)
    tag_alias_count = Repo.aggregate(TagAlias, :count)

    assert imported_count == length(Legacy.all_posts())
    assert slug_alias_count > 0
    assert tag_alias_count > 0

    run_import()

    assert Repo.aggregate(BlogPost, :count) == imported_count
    assert Repo.aggregate(SlugAlias, :count) == slug_alias_count
    assert Repo.aggregate(TagAlias, :count) == tag_alias_count
  end

  test "runtime importer is idempotent (release-safe path)" do
    stats_first = AgentJido.Blog.LegacyImporter.import!()
    assert stats_first.created == length(Legacy.all_posts())
    assert stats_first.slug_aliases > 0
    assert stats_first.tag_aliases > 0

    stats_second = AgentJido.Blog.LegacyImporter.import!()
    assert stats_second.created == 0
    assert stats_second.updated == length(Legacy.all_posts())
    assert stats_second.tag_aliases > 0

    assert Repo.aggregate(BlogPost, :count) == length(Legacy.all_posts())
  end

  test "import canonicalizes tags and persists taxonomy metadata" do
    AgentJido.Blog.LegacyImporter.import!()

    req_post = Repo.get_by!(BlogPost, slug: "announcing-req-llm-1-0")
    assert "req_llm" in req_post.tags
    refute "reqllm" in req_post.tags

    capability_theme =
      req_post.body["legacy_capability_theme"] || req_post.body[:legacy_capability_theme]

    content_intent =
      req_post.body["legacy_content_intent"] || req_post.body[:legacy_content_intent]

    assert to_string(capability_theme) == "ai_intelligence"
    assert to_string(content_intent) in ["explanation", "reference", "decision_brief", "tutorial", "case_study", "guide", "cookbook"]

    assert %TagAlias{canonical_tag: "req_llm"} = Repo.get_by!(TagAlias, legacy_tag: "reqllm")
    assert %TagAlias{canonical_tag: "req_llm"} = Repo.get_by!(TagAlias, legacy_tag: "req")
  end

  defp run_import do
    capture_io(fn ->
      Mix.Task.reenable("blog.import_legacy")
      Mix.Tasks.Blog.ImportLegacy.run([])
    end)
  end
end
