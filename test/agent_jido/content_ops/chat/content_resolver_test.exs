defmodule AgentJido.ContentOps.Chat.ContentResolverTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentOps.Chat.ContentResolver

  @pages [
    %{id: "getting-started", title: "Getting Started", path: "/docs/getting-started"},
    %{id: "agent-lifecycle", title: "Agent Lifecycle", path: "/docs/agent-lifecycle"}
  ]

  @entries [
    %{id: "orchestration/runic", slug: "runic", title: "Runic Orchestration", destination_route: "/build/runic"},
    %{id: "chat/bridge", slug: "chat-bridge", title: "Chat Bridge", destination_route: "/build/chat-bridge"}
  ]

  test "resolve/2 returns exact page match by id" do
    assert {:ok, target} = ContentResolver.resolve("getting-started", pages: @pages, entries: @entries)
    assert target.type == :page
    assert target.id == "getting-started"
  end

  test "resolve/2 returns exact content plan match by id" do
    assert {:ok, target} = ContentResolver.resolve("orchestration/runic", pages: @pages, entries: @entries)
    assert target.type == :content_plan
    assert target.id == "orchestration/runic"
  end

  test "resolve/2 fuzzy-resolves strong single match" do
    assert {:ok, target} = ContentResolver.resolve("agent lifecycle", pages: @pages, entries: @entries)
    assert target.id == "agent-lifecycle"
  end

  test "resolve/2 returns ambiguous for close fuzzy matches" do
    pages = [
      %{id: "agent-loop", title: "Agent Loop", path: "/docs/agent-loop"},
      %{id: "agent-loops", title: "Agent Loops", path: "/docs/agent-loops"}
    ]

    assert {:ambiguous, candidates} = ContentResolver.resolve("agent loop", pages: pages, entries: [])
    assert length(candidates) >= 2
  end

  test "resolve/2 returns not_found when no candidate matches" do
    assert {:error, :not_found} = ContentResolver.resolve("totally-unknown", pages: @pages, entries: @entries)
  end
end
