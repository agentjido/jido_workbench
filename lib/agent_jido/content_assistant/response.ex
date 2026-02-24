defmodule AgentJido.ContentAssistant.Response do
  @moduledoc """
  Unified content assistant response envelope.
  """

  alias AgentJido.ContentAssistant.Result

  @type answer_mode ::
          :llm
          | :deterministic
          | :deterministic_fallback
          | :quota_fallback
          | :no_results
          | :error

  @type retrieval_status :: :success | :fallback | :failure
  @type enhancement_blocked_reason :: :turnstile | :budget | :llm_unconfigured | nil

  @enforce_keys [
    :query,
    :answer_markdown,
    :answer_html,
    :answer_mode,
    :citations,
    :retrieval_status,
    :llm_attempted?,
    :llm_enhanced?,
    :enhancement_blocked_reason,
    :query_log_id
  ]
  defstruct [
    :query,
    :answer_markdown,
    :answer_html,
    :answer_mode,
    :citations,
    :retrieval_status,
    :llm_attempted?,
    :llm_enhanced?,
    :enhancement_blocked_reason,
    :query_log_id,
    related_queries: []
  ]

  @type t :: %__MODULE__{
          query: String.t(),
          answer_markdown: String.t(),
          answer_html: String.t(),
          answer_mode: answer_mode(),
          citations: [Result.t()],
          related_queries: [String.t()],
          retrieval_status: retrieval_status(),
          llm_attempted?: boolean(),
          llm_enhanced?: boolean(),
          enhancement_blocked_reason: enhancement_blocked_reason(),
          query_log_id: Ecto.UUID.t() | nil
        }
end
