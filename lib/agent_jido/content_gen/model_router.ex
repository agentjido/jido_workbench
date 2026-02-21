defmodule AgentJido.ContentGen.ModelRouter do
  @moduledoc """
  Rule-based backend/model routing for content generation.
  """

  @default_req_llm_model "google:gemini-2.5-pro"

  @spec choose(struct(), map(), map()) :: %{backend: :codex | :req_llm, model: String.t() | nil, reason: String.t()}
  def choose(entry, target, opts) do
    forced_backend = Map.get(opts, :backend, :auto)
    forced_model = Map.get(opts, :model)

    backend =
      case forced_backend do
        :codex -> :codex
        :req_llm -> :req_llm
        _other -> auto_backend(entry, target)
      end

    model =
      cond do
        is_binary(forced_model) and forced_model != "" -> forced_model
        backend == :req_llm -> @default_req_llm_model
        true -> nil
      end

    %{backend: backend, model: model, reason: decision_reason(entry, target, forced_backend, backend)}
  end

  defp auto_backend(entry, target) do
    cond do
      target.format == :livemd ->
        :codex

      String.starts_with?(target.route, "/docs/reference") ->
        :req_llm

      String.starts_with?(target.route, "/docs/guides") ->
        :codex

      entry.section in ["build", "training"] ->
        :codex

      true ->
        :req_llm
    end
  end

  defp decision_reason(_entry, _target, forced_backend, backend) when forced_backend in [:codex, :req_llm] do
    "forced_backend_#{backend}"
  end

  defp decision_reason(entry, target, _forced_backend, _backend) do
    cond do
      target.format == :livemd -> "livemd_prefers_codex"
      String.starts_with?(target.route, "/docs/reference") -> "reference_prefers_req_llm"
      String.starts_with?(target.route, "/docs/guides") -> "guides_prefers_codex"
      entry.section in ["build", "training"] -> "section_prefers_codex"
      true -> "fallback_req_llm"
    end
  end
end
