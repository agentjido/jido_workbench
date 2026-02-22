defmodule AgentJidoWeb.ContentGenerator.EntryStatus do
  @moduledoc """
  Derives generated-artifact and verification statuses for dashboard entries.
  """

  alias AgentJido.ContentGen.PathResolver

  @type artifact_status :: :missing | :generated | :stale | :unknown
  @type verify_status :: :passed | :failed | :skipped | :unknown

  @spec derive(map(), map() | nil, keyword()) :: map()
  def derive(entry, latest_run_entry, opts \\ []) do
    page_index = Keyword.get(opts, :page_index, PathResolver.page_index())
    docs_format = Keyword.get(opts, :docs_format, :tag)

    case PathResolver.resolve(entry, page_index: page_index, docs_format: docs_format) do
      {:ok, target} ->
        artifact_exists? = File.exists?(target.read_path)
        artifact_mtime = if artifact_exists?, do: file_mtime(target.read_path), else: nil
        plan_mtime = file_mtime(entry.path)

        artifact_status = artifact_status(artifact_exists?, plan_mtime, artifact_mtime)
        verify_status = verify_status(latest_run_entry)

        %{
          artifact_status: artifact_status,
          verify_status: verify_status,
          entry_health: entry_health(artifact_status, verify_status),
          target_path: target.target_path,
          read_path: target.read_path,
          format: target.format,
          artifact_exists?: artifact_exists?,
          artifact_mtime: artifact_mtime,
          plan_mtime: plan_mtime,
          stale?: artifact_status == :stale,
          last_run_id: latest_run_entry && latest_run_entry.run_id,
          last_run_at: latest_run_entry && latest_run_entry.generated_at
        }

      {:skip, _reason, _payload} ->
        verify_status = verify_status(latest_run_entry)

        %{
          artifact_status: :unknown,
          verify_status: verify_status,
          entry_health: entry_health(:unknown, verify_status),
          target_path: nil,
          read_path: nil,
          format: nil,
          artifact_exists?: false,
          artifact_mtime: nil,
          plan_mtime: file_mtime(entry.path),
          stale?: false,
          last_run_id: latest_run_entry && latest_run_entry.run_id,
          last_run_at: latest_run_entry && latest_run_entry.generated_at
        }
    end
  end

  defp artifact_status(false, _plan_mtime, _artifact_mtime), do: :missing

  defp artifact_status(true, %DateTime{} = plan_mtime, %DateTime{} = artifact_mtime) do
    if DateTime.compare(plan_mtime, artifact_mtime) == :gt, do: :stale, else: :generated
  end

  defp artifact_status(true, _plan_mtime, _artifact_mtime), do: :generated

  defp verify_status(nil), do: :unknown

  defp verify_status(latest_run_entry) do
    status = latest_run_entry |> Map.get(:verification, %{}) |> Map.get(:status)

    case to_string(status || "") |> String.trim() |> String.downcase() do
      "passed" -> :passed
      "failed" -> :failed
      "skipped" -> :skipped
      _other -> :unknown
    end
  end

  defp entry_health(:generated, :passed), do: :healthy
  defp entry_health(_artifact_status, :failed), do: :critical
  defp entry_health(:stale, _verify_status), do: :attention
  defp entry_health(:missing, _verify_status), do: :attention
  defp entry_health(_artifact_status, _verify_status), do: :neutral

  defp file_mtime(path) when is_binary(path) do
    case File.stat(path, time: :posix) do
      {:ok, stat} -> DateTime.from_unix!(stat.mtime)
      {:error, _reason} -> nil
    end
  end

  defp file_mtime(_path), do: nil
end
