defmodule AgentJido.Community.ShowcaseTest do
  use ExUnit.Case, async: true

  alias AgentJido.Community.Showcase

  test "loads published showcase projects from markdown" do
    projects = Showcase.all_projects()

    assert Enum.any?(projects)
    assert Enum.any?(projects, &(&1.slug == "loomkin"))
    assert Enum.any?(projects, &(&1.slug == "screentour"))
    refute Enum.any?(projects, &(&1.slug == "agent-jido-workbench"))
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

  test "draft showcase entries stay hidden unless drafts are requested" do
    assert Showcase.get_project("agent-jido-workbench") == nil

    project = Showcase.get_project!("agent-jido-workbench", include_drafts: true)

    assert project.title == "Agent Jido Workbench"
    assert project.status == :draft
    assert project.featured
    assert String.starts_with?(project.project_url, "https://")

    assert Showcase.project_count(include_drafts: true) == Showcase.project_count() + 1

    assert Enum.any?(Showcase.all_projects(include_drafts: true), &(&1.slug == "agent-jido-workbench"))
    assert Enum.any?(Showcase.featured_projects(include_drafts: true), &(&1.slug == "agent-jido-workbench"))
  end

  test "missing showcase project raises a not found error" do
    assert Showcase.get_project("does-not-exist") == nil

    assert_raise Showcase.NotFoundError, fn ->
      Showcase.get_project!("does-not-exist")
    end
  end
end
