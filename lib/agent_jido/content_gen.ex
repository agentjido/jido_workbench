defmodule AgentJido.ContentGen do
  @moduledoc """
  Content generation helpers for converting content-plan entries into page files.

  This namespace powers `mix content.plan.generate` and is intentionally
  review-first with dry-run defaults.
  """

  @type backend_id :: :auto | :codex | :req_llm
  @type update_mode :: :improve | :regenerate | :audit_only

  @default_statuses [:outline, :draft]
  @default_batch_size 10
  @non_file_backed_routes ["/features", "/examples"]

  @spec default_statuses() :: [atom()]
  def default_statuses, do: @default_statuses

  @spec default_batch_size() :: pos_integer()
  def default_batch_size, do: @default_batch_size

  @spec non_file_backed_routes() :: [String.t()]
  def non_file_backed_routes, do: @non_file_backed_routes

  @spec non_file_backed_route?(String.t()) :: boolean()
  def non_file_backed_route?(route) when is_binary(route), do: route in @non_file_backed_routes

  @spec normalize_route(String.t()) :: String.t()
  def normalize_route(route) when is_binary(route) do
    route
    |> String.trim()
    |> String.replace(~r/[?#].*$/, "")
    |> trim_trailing_slash()
    |> case do
      "" ->
        "/"

      normalized ->
        if String.starts_with?(normalized, "/"), do: normalized, else: "/" <> normalized
    end
  end

  defp trim_trailing_slash("/"), do: "/"

  defp trim_trailing_slash(route) do
    if String.ends_with?(route, "/"), do: String.trim_trailing(route, "/"), else: route
  end

  @spec run_dir(String.t()) :: String.t()
  def run_dir(run_id) when is_binary(run_id), do: Path.join(["tmp", "content_gen", "runs", run_id])
end
