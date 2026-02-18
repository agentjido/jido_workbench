defmodule Mix.Tasks.Agentjido.SignalTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  setup do
    original_runtime_flag = System.get_env("AGENTJIDO_RUNTIME_ENABLED")

    Mix.Task.reenable("agentjido.signal")
    System.delete_env("AGENTJIDO_RUNTIME_ENABLED")

    on_exit(fn ->
      Mix.Task.reenable("agentjido.signal")

      if original_runtime_flag do
        System.put_env("AGENTJIDO_RUNTIME_ENABLED", original_runtime_flag)
      else
        System.delete_env("AGENTJIDO_RUNTIME_ENABLED")
      end
    end)

    :ok
  end

  test "self-bootstraps runtime and executes a run" do
    output =
      capture_io(fn ->
        Mix.Tasks.Agentjido.Signal.run(["run", "--mode", "weekly", "--timeout", "30"])
      end)

    assert output =~ "Run completed"
    assert System.get_env("AGENTJIDO_RUNTIME_ENABLED") == "true"
  end
end
