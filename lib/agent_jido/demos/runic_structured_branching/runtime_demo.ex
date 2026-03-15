defmodule AgentJido.Demos.RunicStructuredBranching.RuntimeDemo do
  @moduledoc """
  Deterministic wrapper around the real Runic structured branching workflow.
  """

  alias AgentJido.Demos.RunicStructuredBranching.{Fixtures, OrchestratorAgent}
  alias Jido.Agent.Directive.Emit
  alias Jido.Agent.Strategy.State, as: StratState
  alias Jido.Runic.Directive.ExecuteRunnable
  alias Jido.Runic.Introspection
  alias Runic.Workflow
  alias Runic.Workflow.Invokable

  @phase_1_order [:route_question]
  @phase_2_orders %{
    phase_2_direct: [:direct_answer],
    phase_2_analysis: [:analysis_plan, :analysis_answer],
    phase_2_safe: [:safe_response]
  }

  defstruct selected_prompt_id: Fixtures.default_prompt_id(),
            selected_prompt: nil,
            agent: nil,
            phase_1_graph: %{nodes: [], edges: []},
            phase_1_productions: [],
            phase_2_graph: %{nodes: [], edges: []},
            phase_2_productions: [],
            decision: nil,
            selected_branch: nil,
            selected_workflow: nil,
            executions: [],
            log: [],
            status: :idle,
            done?: false,
            branch_result: "",
            takeaway: ""

  @type execution_entry :: %{
          required(:index) => non_neg_integer(),
          required(:workflow) => atom(),
          required(:node) => atom(),
          required(:action) => module() | nil,
          required(:status) => atom(),
          required(:input) => map(),
          required(:output) => map() | nil,
          required(:error) => term()
        }

  @type t :: %__MODULE__{
          selected_prompt_id: String.t(),
          selected_prompt: map(),
          agent: Jido.Agent.t(),
          phase_1_graph: map(),
          phase_1_productions: [map()],
          phase_2_graph: map(),
          phase_2_productions: [map()],
          decision: map() | nil,
          selected_branch: atom() | nil,
          selected_workflow: atom() | nil,
          executions: [execution_entry()],
          log: [map()],
          status: atom(),
          done?: boolean(),
          branch_result: String.t(),
          takeaway: String.t()
        }

  @doc "Returns the deterministic question catalog used by the branching demo."
  @spec prompts() :: [map()]
  def prompts, do: Fixtures.catalog()

  @doc "Builds a fresh demo state for the selected prompt."
  @spec new(String.t() | nil) :: t()
  def new(prompt_id \\ nil) do
    selected_prompt = Fixtures.fetch!(prompt_id || Fixtures.default_prompt_id())
    agent = OrchestratorAgent.new()

    %__MODULE__{
      selected_prompt_id: selected_prompt.id,
      selected_prompt: selected_prompt,
      agent: agent,
      phase_1_graph: graph_for(agent, &OrchestratorAgent.build_phase_1/0)
    }
    |> sync_status()
  end

  @doc "Resets the branching demo while optionally changing the selected prompt."
  @spec reset(t(), keyword()) :: t()
  def reset(%__MODULE__{} = demo, opts \\ []) do
    prompt_id = Keyword.get(opts, :prompt_id, demo.selected_prompt_id)
    new(prompt_id)
  end

  @doc "Changes the selected prompt by rebuilding the demo state."
  @spec select_prompt(t(), String.t()) :: t()
  def select_prompt(%__MODULE__{} = demo, prompt_id) do
    reset(demo, prompt_id: prompt_id)
  end

  @doc "Runs the full deterministic branching example for the selected prompt."
  @spec run(t()) :: t()
  def run(%__MODULE__{} = demo) do
    demo =
      demo
      |> reset()
      |> append_log("Route", "Fed the selected question into the real Runic routing workflow.")

    {agent, directives} =
      strategy_cmd(demo.agent, :runic_feed_signal, %{data: %{question: demo.selected_prompt.question}})

    demo =
      demo
      |> Map.put(:agent, agent)
      |> sync_status()
      |> run_directives(directives)

    phase_1_productions = productions_for(demo.agent)
    decision = extract_decision(phase_1_productions, demo.selected_prompt.question)
    phase_2_workflow = OrchestratorAgent.build_phase_2(decision.route)

    {agent, []} = strategy_cmd(demo.agent, :runic_set_workflow, %{workflow: phase_2_workflow})

    demo =
      demo
      |> Map.put(:agent, agent)
      |> Map.put(:phase_1_graph, graph_for(demo.agent, &OrchestratorAgent.build_phase_1/0))
      |> Map.put(:phase_1_productions, phase_1_productions)
      |> Map.put(:decision, decision)
      |> Map.put(:selected_branch, decision.route)
      |> Map.put(:selected_workflow, phase_2_workflow.name)
      |> Map.put(:phase_2_graph, graph_for(agent, fn -> phase_2_workflow end))
      |> append_log("Select branch", "Applied runic.set_workflow to #{phase_2_workflow.name}.")
      |> sync_status()

    {agent, directives} = strategy_cmd(demo.agent, :runic_feed_signal, %{data: decision})

    demo =
      demo
      |> Map.put(:agent, agent)
      |> sync_status()
      |> run_directives(directives)

    phase_2_productions = productions_for(demo.agent)

    demo
    |> Map.put(:phase_2_graph, graph_for(demo.agent, fn -> phase_2_workflow end))
    |> Map.put(:phase_2_productions, phase_2_productions)
    |> Map.put(:branch_result, extract_branch_result(phase_2_productions))
    |> Map.put(:takeaway, extract_takeaway(phase_2_productions))
    |> append_log("Complete", completion_detail(decision.route, phase_2_workflow.name))
    |> sync_status()
  end

  @doc "Returns the fixed ordering for the phase-1 routing graph."
  @spec phase_1_order() :: [atom()]
  def phase_1_order, do: @phase_1_order

  @doc "Returns the fixed ordering for a selected phase-2 branch workflow."
  @spec phase_2_order(atom() | nil) :: [atom()]
  def phase_2_order(workflow_name), do: Map.get(@phase_2_orders, workflow_name, [])

  defp run_directives(%__MODULE__{} = demo, directives) when directives in [nil, []], do: sync_status(demo)

  defp run_directives(%__MODULE__{} = demo, directives) when is_list(directives) do
    Enum.reduce(directives, demo, fn
      %ExecuteRunnable{runnable: runnable}, acc ->
        executed = Invokable.execute(runnable.node, runnable)
        {agent, next_directives} = strategy_cmd(acc.agent, :runic_apply_result, %{runnable: executed})

        acc
        |> Map.put(:agent, agent)
        |> record_execution(executed)
        |> sync_status()
        |> run_directives(next_directives)

      %Emit{} = directive, acc ->
        signal_type = Map.get(directive.signal, :type, "runic.workflow.production")
        append_log(acc, "Emit", "Emitted #{signal_type}.")

      _other, acc ->
        acc
    end)
  end

  defp strategy_cmd(agent, action, params) do
    OrchestratorAgent.cmd(agent, {action, params})
  end

  defp record_execution(%__MODULE__{} = demo, runnable) do
    workflow_name = workflow_name(demo.agent)

    entry = %{
      index: length(demo.executions),
      workflow: workflow_name,
      node: runnable.node.name,
      action: action_module_for(runnable.node),
      status: runnable.status,
      input: runnable.input_fact.value,
      output: if(runnable.status == :completed, do: runnable.result.value, else: nil),
      error: if(runnable.status == :failed, do: runnable.error, else: nil)
    }

    demo
    |> Map.update!(:executions, &(&1 ++ [entry]))
    |> append_log(log_label(entry), log_detail(entry))
  end

  defp sync_status(%__MODULE__{} = demo) do
    status = StratState.get(demo.agent, %{}) |> Map.get(:status, :idle)
    %{demo | status: status, done?: status in [:success, :failure]}
  end

  defp graph_for(agent, fallback_workflow_fun) do
    strat = StratState.get(agent, %{})
    workflow = Map.get(strat, :workflow, fallback_workflow_fun.())
    Introspection.annotated_graph(workflow, strat)
  end

  defp productions_for(agent) do
    agent
    |> current_workflow(&OrchestratorAgent.build_phase_1/0)
    |> Workflow.raw_productions()
  end

  defp current_workflow(agent, fallback_workflow_fun) do
    StratState.get(agent, %{})
    |> Map.get(:workflow, fallback_workflow_fun.())
  end

  defp workflow_name(agent) do
    agent
    |> current_workflow(&OrchestratorAgent.build_phase_1/0)
    |> Map.fetch!(:name)
  end

  defp extract_decision(productions, fallback_question) do
    decision =
      Enum.find(productions, fn
        %{route: route} when route in [:direct, :analysis, :safe] -> true
        _ -> false
      end) || %{}

    %{
      prompt_id: Map.get(decision, :prompt_id),
      question: Map.get(decision, :question, fallback_question),
      route: Map.get(decision, :route, :analysis),
      detail_level: Map.get(decision, :detail_level, :brief),
      confidence: Map.get(decision, :confidence, 0.5),
      reasoning: Map.get(decision, :reasoning, "No routing rationale provided.")
    }
  end

  defp extract_branch_result(productions) do
    Enum.find_value(productions, "", fn
      %{branch_result: result} when is_binary(result) -> result
      _ -> nil
    end)
  end

  defp extract_takeaway(productions) do
    Enum.find_value(productions, "", fn
      %{takeaway: takeaway} when is_binary(takeaway) -> takeaway
      _ -> nil
    end)
  end

  defp completion_detail(route, workflow_name) do
    "Completed the #{route} branch using #{workflow_name}."
  end

  defp log_label(entry), do: "#{entry.workflow}.#{entry.node}"

  defp log_detail(%{status: :completed, output: output}) do
    "Completed with keys #{output_keys(output)}."
  end

  defp log_detail(%{status: :failed, error: error}) do
    "Failed with #{inspect(error)}."
  end

  defp log_detail(entry) do
    "Finished with status #{entry.status}."
  end

  defp output_keys(output) when is_map(output) do
    output
    |> Map.keys()
    |> Enum.map_join(", ", &to_string/1)
  end

  defp output_keys(_output), do: "none"

  defp append_log(%__MODULE__{} = demo, label, detail) do
    entry = %{label: label, detail: detail}
    Map.update!(demo, :log, &([entry | &1] |> Enum.take(24)))
  end

  defp action_module_for(node), do: Map.get(node, :action_mod)
end
