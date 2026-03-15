defmodule AgentJido.Community.ShowcaseTest do
  use ExUnit.Case, async: true

  alias AgentJido.Community.Showcase

  test "loads published showcase projects from markdown" do
    projects = Showcase.all_projects()

    assert Enum.any?(projects)
    assert Enum.any?(projects, &(&1.slug == "loomkin"))
    assert Enum.any?(projects, &(&1.slug == "screentour"))
    refute Enum.any?(projects, &(&1.slug == "agent-jido-workbench"))
    refute Enum.any?(projects, &(&1.slug == "jido-run"))
    assert Enum.all?(projects, &(&1.status == :live))
  end

  test "get_project!/1 returns structured card fields" do
    project = Showcase.get_project!("loomkin")

    assert project.title == "Loomkin"
    assert project.description != ""
    assert String.starts_with?(project.project_url, "https://")
    assert is_binary(project.body)
    assert is_list(project.tags)
    refute project.featured
    assert String.contains?(project.path, "/priv/community_showcase/")
  end

  test "missing showcase project raises a not found error" do
    assert Showcase.get_project("does-not-exist") == nil

    assert_raise Showcase.NotFoundError, fn ->
      Showcase.get_project!("does-not-exist")
    end
  end
end
