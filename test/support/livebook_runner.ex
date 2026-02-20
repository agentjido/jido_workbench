defmodule AgentJido.TestSupport.LivebookRunner do
  @moduledoc """
  Minimal helper for executing `.livemd` Elixir code cells inside ExUnit tests.
  """

  @default_timeout 60_000

  @doc """
  Executes a livebook file and returns `:ok` or `{:error, reason}`.

  Options:
  - `:timeout` (default: `60000`)
  - `:skip_mix_install` (default: `true`)
  """
  @spec run_file(String.t(), keyword()) :: :ok | {:error, term()}
  def run_file(path, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    skip_mix_install = Keyword.get(opts, :skip_mix_install, true)

    task = Task.async(fn -> do_run_file(path, skip_mix_install) end)

    case Task.yield(task, timeout) || Task.shutdown(task, :brutal_kill) do
      {:ok, :ok} ->
        :ok

      {:ok, {:error, reason}} ->
        {:error, reason}

      {:exit, reason} ->
        {:error, {:exit, reason}}

      nil ->
        {:error, :timeout}
    end
  end

  defp do_run_file(path, skip_mix_install) do
    script =
      path
      |> File.read!()
      |> extract_code_cells()
      |> maybe_drop_mix_install(skip_mix_install)
      |> Enum.join("\n\n")

    if String.trim(script) == "" do
      :ok
    else
      Code.eval_string(script, [], file: path)
      :ok
    end
  rescue
    e ->
      {:error, Exception.format(:error, e, __STACKTRACE__)}
  catch
    kind, reason ->
      {:error, Exception.format(kind, reason, __STACKTRACE__)}
  end

  defp extract_code_cells(content) do
    ~r/```elixir[^\n]*\n(.*?)```/s
    |> Regex.scan(content, capture: :all_but_first)
    |> List.flatten()
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp maybe_drop_mix_install(cells, true) do
    Enum.reject(cells, &String.contains?(&1, "Mix.install"))
  end

  defp maybe_drop_mix_install(cells, false), do: cells
end
