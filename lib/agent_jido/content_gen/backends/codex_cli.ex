defmodule AgentJido.ContentGen.Backends.CodexCLI do
  @moduledoc """
  Codex CLI wrapper backend for generation.
  """

  @behaviour AgentJido.ContentGen.Backends.Backend
  @default_timeout_ms 45_000

  @impl true
  def generate(prompt, opts) when is_binary(prompt) do
    cmd_runner = Keyword.get(opts, :cmd_runner, &System.cmd/3)

    with {:ok, codex_bin} <- find_codex(opts),
         {output, 0} <- run_codex(codex_bin, prompt, opts, cmd_runner) do
      {:ok,
       %{
         text: output,
         meta: %{
           backend: :codex,
           model: Keyword.get(opts, :model),
           command: "codex exec"
         }
       }}
    else
      {:error, reason} ->
        {:error, reason}

      {output, status} ->
        {:error, "codex exited with status #{status}: #{String.slice(output, 0, 500)}"}
    end
  end

  defp find_codex(opts) do
    case Keyword.get(opts, :codex_path) do
      path when is_binary(path) and path != "" ->
        {:ok, path}

      _other ->
        find_codex_on_path()
    end
  end

  defp find_codex_on_path do
    case System.find_executable("codex") do
      nil -> {:error, "codex CLI not found on PATH"}
      path -> {:ok, path}
    end
  end

  defp run_codex(codex_bin, prompt, opts, cmd_runner) do
    cwd = Keyword.get(opts, :cwd, File.cwd!())
    model = Keyword.get(opts, :model)
    extra_args = Keyword.get(opts, :extra_args, [])
    timeout_ms = Keyword.get(opts, :timeout_ms, @default_timeout_ms)

    args =
      ["exec", "--cd", cwd, "--full-auto"] ++
        maybe_model_arg(model) ++ extra_args ++ [prompt]

    cmd_opts = [
      stderr_to_stdout: true,
      env: Keyword.get(opts, :env, [])
    ]

    run_cmd_with_timeout(codex_bin, args, cmd_opts, cmd_runner, timeout_ms)
  end

  defp run_cmd_with_timeout(codex_bin, args, cmd_opts, cmd_runner, timeout_ms) do
    task = Task.async(fn -> cmd_runner.(codex_bin, args, cmd_opts) end)

    case Task.yield(task, timeout_ms) do
      {:ok, result} ->
        result

      {:exit, reason} ->
        {"codex command crashed: #{Exception.format_exit(reason)}", 125}

      nil ->
        Task.shutdown(task, :brutal_kill)
        {"codex command timed out after #{timeout_ms}ms", 124}
    end
  end

  defp maybe_model_arg(model) when is_binary(model) and model != "", do: ["--model", model]
  defp maybe_model_arg(_model), do: []
end
