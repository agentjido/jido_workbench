defmodule Mix.Tasks.Blog.ImportLegacyTest do
  use AgentJido.DataCase, async: false

  import ExUnit.CaptureIO

  alias AgentJido.Blog.Legacy
  alias AgentJido.Blog.SlugAlias
  alias PhoenixBlog.Post, as: BlogPost

  setup do
    Repo.delete_all(SlugAlias)
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
  end

  test "import is idempotent" do
    run_import()

    imported_count = Repo.aggregate(BlogPost, :count)
    alias_count = Repo.aggregate(SlugAlias, :count)

    assert imported_count == length(Legacy.all_posts())
    assert alias_count > 0

    run_import()

    assert Repo.aggregate(BlogPost, :count) == imported_count
    assert Repo.aggregate(SlugAlias, :count) == alias_count
  end

  defp run_import do
    capture_io(fn ->
      Mix.Task.reenable("blog.import_legacy")
      Mix.Tasks.Blog.ImportLegacy.run([])
    end)
  end
end
