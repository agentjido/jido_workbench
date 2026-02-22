defmodule AgentJido.ContentGen.LivebookTestGeneratorTest do
  use ExUnit.Case, async: false

  alias AgentJido.ContentGen.LivebookTestGenerator

  test "deterministic_test_path/1 derives stable docs test path from route" do
    assert LivebookTestGenerator.deterministic_test_path("/docs/concepts/agents") ==
             "test/livebooks/docs/concepts_agents_livebook_test.exs"
  end

  test "ensure_test_file/2 creates deterministic file when no existing test references livebook" do
    in_tmp_project(fn ->
      livebook_path = "priv/pages/docs/concepts/agents.livemd"
      :ok = File.mkdir_p(Path.dirname(livebook_path))
      :ok = File.write(livebook_path, "```elixir\nIO.puts(\"ok\")\n```\n")

      assert {:ok, test_file} = LivebookTestGenerator.ensure_test_file(livebook_path, "/docs/concepts/agents")
      assert test_file == "test/livebooks/docs/concepts_agents_livebook_test.exs"
      assert File.exists?(test_file)

      contents = File.read!(test_file)
      assert contents =~ "defmodule AgentJido.Livebooks.Docs.ConceptsAgentsLivebookTest"
      assert contents =~ ~s(livebook: "priv/pages/docs/concepts/agents.livemd")
      assert contents =~ ~s(test "runs cleanly")
    end)
  end

  test "ensure_test_file/2 updates existing file that already references the livebook" do
    in_tmp_project(fn ->
      livebook_path = "priv/pages/docs/concepts/agents.livemd"
      existing_test = "test/livebooks/docs/custom_agents_livebook_test.exs"

      :ok = File.mkdir_p(Path.dirname(livebook_path))
      :ok = File.mkdir_p(Path.dirname(existing_test))
      :ok = File.write(livebook_path, "```elixir\nIO.puts(\"ok\")\n```\n")

      :ok =
        File.write(
          existing_test,
          """
          defmodule Legacy.Test do
            use AgentJido.LivebookCase, livebook: "priv/pages/docs/concepts/agents.livemd"
          end
          """
        )

      assert {:ok, test_file} = LivebookTestGenerator.ensure_test_file(livebook_path, "/docs/concepts/agents")
      assert test_file == existing_test

      contents = File.read!(test_file)
      assert contents =~ "AgentJido.Livebooks.Docs.ConceptsAgentsLivebookTest"
      assert contents =~ ~s(test "runs cleanly")
    end)
  end

  defp in_tmp_project(fun) do
    tmp_dir = Path.join(System.tmp_dir!(), "livebook_test_gen_#{System.unique_integer([:positive])}")
    :ok = File.mkdir_p(tmp_dir)

    try do
      File.cd!(tmp_dir, fun)
    after
      File.rm_rf(tmp_dir)
    end
  end
end
