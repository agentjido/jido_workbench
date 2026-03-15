defmodule AgentJido.Demos.RunicStructuredBranching.Actions do
  @moduledoc """
  Deterministic Runic action nodes for the structured branching example.
  """

  alias AgentJido.Demos.RunicStructuredBranching.Fixtures

  defmodule RouteQuestion do
    @moduledoc "Returns the structured route decision for the selected question."

    use Jido.Action,
      name: "runic_structured_branching_route_question",
      description: "Routes a question into direct, analysis, or safe branch fixtures",
      schema: [
        question: [type: :string, required: true]
      ]

    @impl true
    def run(%{question: question}, _context) do
      prompt = Fixtures.fetch_by_question!(question)

      {:ok,
       %{
         prompt_id: prompt.id,
         question: prompt.question,
         route: prompt.route,
         detail_level: prompt.detail_level,
         confidence: prompt.confidence,
         reasoning: prompt.reasoning
       }}
    end
  end

  defmodule DirectAnswer do
    @moduledoc "Builds the direct-answer branch output."

    use Jido.Action,
      name: "runic_structured_branching_direct_answer",
      description: "Returns the deterministic direct branch answer",
      schema: [
        prompt_id: [type: :string, required: true],
        question: [type: :string, required: true],
        route: [type: {:in, [:direct]}, required: true],
        detail_level: [type: {:in, [:brief, :detailed]}, required: true],
        confidence: [type: :float, required: true],
        reasoning: [type: :string, required: true]
      ]

    @impl true
    def run(%{prompt_id: prompt_id, question: question} = params, _context) do
      prompt = Fixtures.fetch!(prompt_id)

      {:ok,
       params
       |> Map.take([:route, :detail_level, :confidence, :reasoning])
       |> Map.merge(%{
         prompt_id: prompt_id,
         question: question,
         branch_result: prompt.branch_result,
         takeaway: prompt.takeaway
       })}
    end
  end

  defmodule AnalysisPlan do
    @moduledoc "Builds the deterministic analysis plan for the analysis branch."

    use Jido.Action,
      name: "runic_structured_branching_analysis_plan",
      description: "Returns the deterministic analysis checklist for the selected question",
      schema: [
        prompt_id: [type: :string, required: true],
        question: [type: :string, required: true],
        route: [type: {:in, [:analysis]}, required: true],
        detail_level: [type: {:in, [:brief, :detailed]}, required: true],
        confidence: [type: :float, required: true],
        reasoning: [type: :string, required: true]
      ]

    @impl true
    def run(%{prompt_id: prompt_id} = params, _context) do
      prompt = Fixtures.fetch!(prompt_id)

      {:ok,
       params
       |> Map.put(:analysis_plan, prompt.analysis_plan)}
    end
  end

  defmodule AnalysisAnswer do
    @moduledoc "Builds the deterministic analysis-branch answer."

    use Jido.Action,
      name: "runic_structured_branching_analysis_answer",
      description: "Returns the deterministic analysis branch answer with supporting plan output",
      schema: [
        prompt_id: [type: :string, required: true],
        question: [type: :string, required: true],
        route: [type: {:in, [:analysis]}, required: true],
        detail_level: [type: {:in, [:brief, :detailed]}, required: true],
        confidence: [type: :float, required: true],
        reasoning: [type: :string, required: true],
        analysis_plan: [type: {:list, :string}, required: true]
      ]

    @impl true
    def run(%{prompt_id: prompt_id, analysis_plan: analysis_plan} = params, _context) do
      prompt = Fixtures.fetch!(prompt_id)

      {:ok,
       params
       |> Map.take([:prompt_id, :question, :route, :detail_level, :confidence, :reasoning])
       |> Map.merge(%{
         analysis_plan: analysis_plan,
         branch_result: prompt.branch_result,
         takeaway: prompt.takeaway
       })}
    end
  end

  defmodule SafeResponse do
    @moduledoc "Builds the deterministic safety response branch."

    use Jido.Action,
      name: "runic_structured_branching_safe_response",
      description: "Returns the deterministic safety-first branch response",
      schema: [
        prompt_id: [type: :string, required: true],
        question: [type: :string, required: true],
        route: [type: {:in, [:safe]}, required: true],
        detail_level: [type: {:in, [:brief, :detailed]}, required: true],
        confidence: [type: :float, required: true],
        reasoning: [type: :string, required: true]
      ]

    @impl true
    def run(%{prompt_id: prompt_id, question: question} = params, _context) do
      prompt = Fixtures.fetch!(prompt_id)

      {:ok,
       params
       |> Map.take([:route, :detail_level, :confidence, :reasoning])
       |> Map.merge(%{
         prompt_id: prompt_id,
         question: question,
         branch_result: prompt.branch_result,
         takeaway: prompt.takeaway
       })}
    end
  end
end
