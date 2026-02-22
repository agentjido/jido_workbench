defmodule AgentJido.ContentGen.CodexCLIBackendTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentGen.Backends.CodexCLI

  test "passes prompt as codex exec argument and does not use unsupported :input option" do
    prompt = "Generate docs for /build/installation"
    test_pid = self()

    cmd_runner = fn bin, args, opts ->
      send(test_pid, {:cmd_called, bin, args, opts})
      {"ok-output", 0}
    end

    assert {:ok, result} =
             CodexCLI.generate(prompt,
               codex_path: "/usr/local/bin/codex",
               cwd: "/tmp/project",
               model: "gpt-5",
               extra_args: ["--skip-git-repo-check"],
               env: [{"FOO", "bar"}],
               cmd_runner: cmd_runner
             )

    assert_receive {:cmd_called, "/usr/local/bin/codex", args, opts}
    assert args == ["exec", "--cd", "/tmp/project", "--full-auto", "--model", "gpt-5", "--skip-git-repo-check", prompt]
    assert Keyword.get(opts, :stderr_to_stdout) == true
    assert Keyword.get(opts, :env) == [{"FOO", "bar"}]
    refute Keyword.has_key?(opts, :max_buffer)
    refute Keyword.has_key?(opts, :input)

    assert result.text == "ok-output"
    assert result.meta.backend == :codex
    assert result.meta.model == "gpt-5"
  end

  test "returns structured error when codex exits non-zero" do
    cmd_runner = fn _bin, _args, _opts -> {"bad-output", 2} end

    assert {:error, reason} =
             CodexCLI.generate("prompt",
               codex_path: "/usr/local/bin/codex",
               cmd_runner: cmd_runner
             )

    assert reason =~ "codex exited with status 2"
    assert reason =~ "bad-output"
  end

  test "times out when codex command hangs" do
    cmd_runner = fn _bin, _args, _opts ->
      Process.sleep(100)
      {"late-output", 0}
    end

    assert {:error, reason} =
             CodexCLI.generate("prompt",
               codex_path: "/usr/local/bin/codex",
               cmd_runner: cmd_runner,
               timeout_ms: 10
             )

    assert reason =~ "codex exited with status 124"
    assert reason =~ "timed out"
  end
end
