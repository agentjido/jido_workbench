defmodule AgentJido.LivebookDocsCoverageTest do
  use ExUnit.Case, async: true

  alias AgentJido.Pages

  @runnable_docs_livebooks [
    "priv/pages/docs/getting-started/first-agent.livemd",
    "priv/pages/docs/getting-started/first-llm-agent.livemd",
    "priv/pages/docs/guides/building-a-weather-agent.livemd",
    "priv/pages/docs/guides/cookbook/chat-response.livemd",
    "priv/pages/docs/guides/debugging-and-troubleshooting.livemd",
    "priv/pages/docs/guides/error-handling-and-recovery.livemd",
    "priv/pages/docs/guides/persistence-and-checkpoints.livemd",
    "priv/pages/docs/guides/testing-agents-and-actions.livemd",
    "priv/pages/docs/learn/ai-chat-agent.livemd",
    "priv/pages/docs/learn/first-workflow.livemd",
    "priv/pages/docs/learn/memory-and-retrieval-augmented-agents.livemd",
    "priv/pages/docs/learn/multi-agent-orchestration.livemd",
    "priv/pages/docs/learn/parent-child-agent-hierarchies.livemd",
    "priv/pages/docs/learn/plugins-and-composable-agents.livemd",
    "priv/pages/docs/learn/reasoning-strategies-compared.livemd",
    "priv/pages/docs/learn/sensors-and-real-time-events.livemd",
    "priv/pages/docs/learn/state-machines-with-fsm.livemd",
    "priv/pages/docs/learn/task-planning-and-execution.livemd"
  ]

  @reference_only_livebooks [
    "priv/pages/docs/learn/ai-agent-with-tools.livemd",
    "priv/pages/docs/reference/why-not-just-a-genserver.livemd"
  ]

  defp docs_livebooks do
    Path.wildcard("priv/pages/docs/**/*.livemd")
    |> Enum.sort()
  end

  defp drift_test_livebooks do
    Path.wildcard(Path.expand("test/livebooks/docs/*_livebook_test.exs", File.cwd!()))
    |> Enum.map(&File.read!/1)
    |> Enum.map(fn source ->
      [_, relative_path] = Regex.run(~r/livebook:\s*"([^"]+)"/, source)
      relative_path
    end)
    |> Enum.sort()
  end

  defp docs_pages_by_source do
    Pages.pages_by_category(:docs)
    |> Map.new(fn page -> {normalize_source_path(page.source_path), page} end)
  end

  defp normalize_source_path(source_path) do
    [_, suffix] = String.split(source_path, "/priv/pages/", parts: 2)
    Path.join("priv/pages", suffix)
  end

  test "all current docs livebooks are classified as runnable or reference-only" do
    expected =
      (@runnable_docs_livebooks ++ @reference_only_livebooks)
      |> Enum.sort()

    assert docs_livebooks() == expected
  end

  test "runnable docs livebooks expose runnable metadata" do
    pages = docs_pages_by_source()

    Enum.each(@runnable_docs_livebooks, fn source_path ->
      page = Map.fetch!(pages, source_path)

      assert page.is_livebook
      assert page.livebook.runnable
    end)
  end

  test "reference-only livebooks remain non-runnable until explicitly promoted" do
    pages = docs_pages_by_source()

    Enum.each(@reference_only_livebooks, fn source_path ->
      page = Map.fetch!(pages, source_path)

      assert page.is_livebook
      refute Map.get(page.livebook, :runnable, false)
    end)
  end

  test "each runnable docs livebook has a matching drift test" do
    assert drift_test_livebooks() == Enum.sort(@runnable_docs_livebooks)
  end
end
