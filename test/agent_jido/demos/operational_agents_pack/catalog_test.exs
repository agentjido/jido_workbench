defmodule AgentJido.Demos.OperationalAgentsPack.CatalogTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.OperationalAgentsPack.Catalog

  test "local entries resolve to real deterministic examples with source files" do
    entries = Catalog.local_entries()

    assert length(entries) == 3

    assert Enum.map(entries, & &1.slug) == [
             "jido-ai-task-execution-workflow",
             "schedule-directive-agent",
             "persistence-storage-agent"
           ]

    assert Enum.all?(entries, fn entry ->
             entry.demo_mode == :real and entry.source_files != [] and Enum.all?(entry.source_files, &File.exists?/1)
           end)
  end

  test "default_local_entry returns the first deterministic operational example" do
    entry = Catalog.default_local_entry()

    assert entry.id == "task-execution"
    assert entry.title == "Jido.AI Task Execution Workflow"
  end

  test "upstream refs preserve the original operational pack concepts" do
    refs = Catalog.upstream_refs()

    assert Enum.map(refs, & &1.id) == ["api-smoke-test", "issue-triage", "release-notes"]
    assert Enum.any?(refs, &String.contains?(&1.href, "api_smoke_test_agent.ex"))
    assert Enum.any?(refs, &String.contains?(&1.href, "issue_triage_agent.ex"))
    assert Enum.any?(refs, &String.contains?(&1.href, "release_notes_agent.ex"))
  end
end
