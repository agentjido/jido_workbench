defmodule AgentJido.ContentGen.ModelRouter do
  @moduledoc """
  Fixed ReqLLM planner/writer model policy for content generation.
  """

  @default_planner_model "anthropic:claude-sonnet-4-5"
  @default_writer_model "google:gemini-2.5-pro"

  # Compatibility aliases for previously configured values that are not present
  # in the current ReqLLM model registry.
  @legacy_model_aliases %{
    "anthropic:claude-sonnet-4.6" => "anthropic:claude-sonnet-4-5",
    "google:gemini-3.1-pro" => "google:gemini-2.5-pro"
  }

  @spec choose(struct(), map(), map()) :: %{
          backend: :req_llm,
          model: String.t(),
          planner_model: String.t(),
          writer_model: String.t(),
          pipeline: :two_pass,
          reason: String.t()
        }
  def choose(_entry, _target, opts) do
    forced_backend = Map.get(opts, :backend, :req_llm)

    planner_model =
      Application.get_env(:agent_jido, :content_gen_planner_model, @default_planner_model)
      |> normalize_model()

    writer_model =
      Application.get_env(:agent_jido, :content_gen_writer_model, @default_writer_model)
      |> normalize_model()

    %{
      backend: :req_llm,
      model: writer_model,
      planner_model: planner_model,
      writer_model: writer_model,
      pipeline: :two_pass,
      reason: decision_reason(forced_backend)
    }
  end

  defp decision_reason(:req_llm), do: "forced_backend_req_llm_two_pass"
  defp decision_reason(:auto), do: "auto_normalized_to_req_llm_two_pass"
  defp decision_reason(:codex), do: "codex_requested_but_req_llm_enforced_two_pass"
  defp decision_reason(other), do: "backend_#{inspect(other)}_normalized_to_req_llm_two_pass"

  defp normalize_model(model) when is_binary(model) do
    model
    |> String.trim()
    |> case do
      "" -> nil
      normalized -> Map.get(@legacy_model_aliases, normalized, normalized)
    end
  end

  defp normalize_model(_), do: nil
end
