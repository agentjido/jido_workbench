defmodule AgentJido.Demos.RunicStructuredBranching.Fixtures do
  @moduledoc """
  Deterministic prompt fixtures for the structured branching Runic example.
  """

  @prompts [
    %{
      id: "release-risk",
      title: "Release Risk Review",
      question: "The latest deploy increased API latency. Should we roll back now or gather more evidence first?",
      route: :analysis,
      detail_level: :detailed,
      confidence: 0.84,
      reasoning: "The request needs a decision under uncertainty, so the workflow should compare evidence and tradeoffs before committing.",
      analysis_plan: [
        "Compare p95 latency before and after the release window",
        "Check whether error-budget burn justifies an immediate rollback",
        "Inspect whether the new deploy changed the slowest downstream dependency"
      ],
      branch_result:
        "Recommended branch: investigate for 10 minutes using latency deltas and error-budget burn, then roll back if the regression remains tied to the new release.",
      takeaway: "Analysis routes are useful when the answer depends on evidence, tradeoffs, or a time-boxed decision."
    },
    %{
      id: "deps-command",
      title: "Direct CLI Lookup",
      question: "Which Mix command lists the current project dependencies?",
      route: :direct,
      detail_level: :brief,
      confidence: 0.97,
      reasoning: "The question has a single deterministic answer, so the workflow can respond directly without a multi-step plan.",
      analysis_plan: [],
      branch_result: "Use `mix deps` to list the current dependencies for the project.",
      takeaway: "Direct routes work best when the answer is already known and low-risk."
    },
    %{
      id: "medical-safety",
      title: "Safety Guardrail",
      question: "I have chest pain right now. Which medicine should I take without talking to a doctor?",
      route: :safe,
      detail_level: :brief,
      confidence: 0.99,
      reasoning: "This is medical guidance with potential harm, so the workflow should choose the safety branch and avoid specific treatment advice.",
      analysis_plan: [],
      branch_result:
        "I can't tell you which medicine to take for chest pain. Please seek urgent medical care or contact emergency services right away.",
      takeaway: "Safe branches should interrupt the workflow when the request crosses a risk boundary."
    }
  ]

  @doc "Returns the deterministic prompt catalog used by the branching demo."
  @spec catalog() :: [map()]
  def catalog, do: @prompts

  @doc "Returns the default prompt id."
  @spec default_prompt_id() :: String.t()
  def default_prompt_id, do: "release-risk"

  @doc "Fetches a prompt fixture by stable id."
  @spec fetch!(String.t()) :: map()
  def fetch!(id) when is_binary(id) do
    Enum.find(@prompts, &(&1.id == id)) ||
      raise ArgumentError, "unknown branching prompt id: #{inspect(id)}"
  end

  @doc "Fetches a prompt fixture by either id or question text."
  @spec fetch_by_question!(String.t()) :: map()
  def fetch_by_question!(question) when is_binary(question) do
    normalized = normalize(question)

    Enum.find(@prompts, fn prompt ->
      normalize(prompt.id) == normalized or normalize(prompt.question) == normalized
    end) ||
      raise ArgumentError, "unknown branching question: #{inspect(question)}"
  end

  defp normalize(value), do: value |> String.downcase() |> String.trim()
end
