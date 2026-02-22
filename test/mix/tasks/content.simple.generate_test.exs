defmodule Mix.Tasks.Content.Simple.GenerateTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  defmodule StubOrchestrator do
    @spec run(map(), keyword()) :: {:ok, map()}
    def run(opts, _runtime_opts) do
      send(self(), {:simple_generate_opts, opts})

      {:ok,
       %{
         entry_id: opts.entry,
         route: "/docs/concepts/agents",
         target_path: "priv/pages/docs/concepts/agents.livemd",
         format: :livemd,
         parse_mode: :json,
         dry_run: opts.dry_run,
         written?: not opts.dry_run,
         planner_model: opts.planner_model || "planner-default",
         writer_model: opts.writer_model || "writer-default",
         livebook_test_file: nil,
         warnings: []
       }}
    end
  end

  setup do
    Mix.Task.reenable("content.simple.generate")
    original = Application.get_env(:agent_jido, :content_simple_orchestrator)
    Application.put_env(:agent_jido, :content_simple_orchestrator, StubOrchestrator)

    on_exit(fn ->
      Mix.Task.reenable("content.simple.generate")

      if is_nil(original) do
        Application.delete_env(:agent_jido, :content_simple_orchestrator)
      else
        Application.put_env(:agent_jido, :content_simple_orchestrator, original)
      end
    end)

    :ok
  end

  test "requires --entry" do
    assert_raise Mix.Error, ~r/--entry is required/, fn ->
      capture_io(fn ->
        Mix.Tasks.Content.Simple.Generate.run([])
      end)
    end
  end

  test "rejects invalid options" do
    assert_raise Mix.Error, ~r/Invalid options/, fn ->
      capture_io(fn ->
        Mix.Tasks.Content.Simple.Generate.run(["--not-a-real-option"])
      end)
    end
  end

  test "defaults docs entries to livemd format" do
    output =
      capture_io(fn ->
        Mix.Tasks.Content.Simple.Generate.run(["--entry", "docs/agents", "--dry-run"])
      end)

    assert_received {:simple_generate_opts, opts}
    assert opts.docs_format == :livemd
    assert output =~ "Status: success"
    assert output =~ "Written: false"
  end

  test "uses tag format for non-docs entries by default" do
    capture_io(fn ->
      Mix.Tasks.Content.Simple.Generate.run(["--entry", "build/installation", "--dry-run"])
    end)

    assert_received {:simple_generate_opts, opts}
    assert opts.docs_format == :tag
  end
end
