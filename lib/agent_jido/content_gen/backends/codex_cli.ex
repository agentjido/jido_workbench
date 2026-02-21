defmodule AgentJido.ContentGen.Backends.CodexCLI do
  @moduledoc """
  Codex CLI wrapper backend for generation.
  """

  @behaviour AgentJido.ContentGen.Backends.Backend

  @impl true
  def generate(prompt, opts) when is_binary(prompt) do
    with {:ok, codex_bin} <- find_codex(),
         {output, 0} <- run_codex(codex_bin, prompt, opts) do
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

  defp find_codex do
    case System.find_executable("codex") do
      nil -> {:error, "codex CLI not found on PATH"}
      path -> {:ok, path}
    end
  end

  defp run_codex(codex_bin, prompt, opts) do
    cwd = Keyword.get(opts, :cwd, File.cwd!())
    model = Keyword.get(opts, :model)
    extra_args = Keyword.get(opts, :extra_args, [])

    args =
      ["exec", "--cd", cwd, "--full-auto"] ++
        maybe_model_arg(model) ++ extra_args ++ ["-"]

    System.cmd(codex_bin, args,
      input: prompt,
      stderr_to_stdout: true,
      env: Keyword.get(opts, :env, []),
      max_buffer: 20_000_000
    )
  end

  defp maybe_model_arg(model) when is_binary(model) and model != "", do: ["--model", model]
  defp maybe_model_arg(_model), do: []
end
