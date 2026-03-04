defmodule AgentJido.Community.ShowcaseTest do
  use ExUnit.Case, async: true

  alias AgentJido.Community.Showcase

  test "loads published showcase projects from markdown" do
    projects = Showcase.all_projects()

    assert length(projects) > 0
    assert Enum.any?(projects, &(&1.slug == "agent-jido-workbench"))
    assert Enum.any?(projects, &(&1.slug == "jido-run"))
    assert Enum.all?(projects, &(&1.status == :live))
  end

  test "get_project!/1 returns structured card fields" do
    project = Showcase.get_project!("agent-jido-workbench")

    assert project.title == "Agent Jido Workbench"
    assert project.description != ""
    assert String.starts_with?(project.project_url, "https://")
    assert is_binary(project.body)
    assert is_list(project.tags)
    assert project.featured
    assert String.contains?(project.path, "/priv/community_showcase/")
  end

  test "missing showcase project raises a not found error" do
    assert Showcase.get_project("does-not-exist") == nil

    assert_raise Showcase.NotFoundError, fn ->
      Showcase.get_project!("does-not-exist")
    end
  end
end
