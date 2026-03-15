defmodule AgentJido.Demos.RunicAdaptiveResearcher.RuntimeDemo do
  @moduledoc """
  Deterministic wrapper around the real Runic adaptive researcher workflow.
  """

  alias AgentJido.Demos.RunicAdaptiveResearcher.{Fixtures, OrchestratorAgent}
  alias Jido.Agent.Directive.Emit
  alias Jido.Agent.Strategy.State, as: StratState
  alias Jido.Runic.Directive.ExecuteRunnable
  alias Jido.Runic.Introspection
  alias Runic.Workflow
  alias Runic.Workflow.Invokable

  @phase_1_order [:plan_queries, :simulate_search]
  @phase_2_orders %{
    phase_2_full: [:build_outline, :draft_article, :edit_and_assemble],
    phase_2_slim: [:draft_article, :edit_and_assemble]
  }

  defstruct selected_topic_id: Fixtures.default_topic_id(),
            selected_topic: nil,
            agent: nil,
            phase_1_graph: %{nodes: [], edges: []},
            phase_1_productions: [],
            phase_2_graph: %{nodes: [], edges: []},
            phase_2_productions: [],
            phase_2_type: nil,
            selected_workflow: nil,
            executions: [],
            log: [],
            status: :idle,
            done?: false,
            summary_length: 0,
            article_markdown: "",
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
          selected_topic_id: String.t(),
          selected_topic: map(),
          agent: Jido.Agent.t(),
          phase_1_graph: map(),
          phase_1_productions: [map()],
          phase_2_graph: map(),
          phase_2_productions: [map()],
          phase_2_type: atom() | nil,
          selected_workflow: atom() | nil,
          executions: [execution_entry()],
          log: [map()],
          status: atom(),
          done?: boolean(),
          summary_length: non_neg_integer(),
          article_markdown: String.t(),
          takeaway: String.t()
        }

  @doc "Returns the deterministic topic catalog used by the adaptive researcher demo."
  @spec topics() :: [map()]
  def topics, do: Fixtures.catalog()

  @doc "Builds a fresh demo state for the selected topic."
  @spec new(String.t() | nil) :: t()
  def new(topic_id \\ nil) do
    selected_topic = Fixtures.fetch!(topic_id || Fixtures.default_topic_id())
    agent = OrchestratorAgent.new()

    %__MODULE__{
      selected_topic_id: selected_topic.id,
      selected_topic: selected_topic,
      agent: agent,
      phase_1_graph: graph_for(agent, &OrchestratorAgent.build_phase_1/0)
    }
    |> sync_status()
  end

  @doc "Resets the adaptive researcher demo while optionally changing topic."
  @spec reset(t(), keyword()) :: t()
  def reset(%__MODULE__{} = demo, opts \\ []) do
    topic_id = Keyword.get(opts, :topic_id, demo.selected_topic_id)
    new(topic_id)
  end

  @doc "Changes the selected topic by rebuilding the demo state."
  @spec select_topic(t(), String.t()) :: t()
  def select_topic(%__MODULE__{} = demo, topic_id) do
    reset(demo, topic_id: topic_id)
  end

  @doc "Runs the full deterministic adaptive researcher example."
  @spec run(t()) :: t()
  def run(%__MODULE__{} = demo) do
    demo =
      demo
      |> reset()
      |> append_log("Research", "Fed the selected topic into the phase-1 research workflow.")

    {agent, directives} =
      strategy_cmd(demo.agent, :runic_feed_signal, %{data: %{topic: demo.selected_topic.title}})

    demo =
      demo
      |> Map.put(:agent, agent)
      |> sync_status()
      |> run_directives(directives)

    phase_1_productions = productions_for(demo.agent)
    phase_2_type = OrchestratorAgent.phase_2_type(phase_1_productions)
    phase_2_workflow = OrchestratorAgent.build_phase_2(phase_1_productions)
    phase_2_input = reshape_for_phase_2(phase_1_productions, phase_2_type)

    {agent, []} = strategy_cmd(demo.agent, :runic_set_workflow, %{workflow: phase_2_workflow})

    demo =
      demo
      |> Map.put(:agent, agent)
      |> Map.put(:phase_1_graph, graph_for(demo.agent, &OrchestratorAgent.build_phase_1/0))
      |> Map.put(:phase_1_productions, phase_1_productions)
      |> Map.put(:phase_2_type, phase_2_type)
      |> Map.put(:selected_workflow, phase_2_workflow.name)
      |> Map.put(:summary_length, extract_summary_length(phase_1_productions))
      |> Map.put(:phase_2_graph, graph_for(agent, fn -> phase_2_workflow end))
      |> append_log("Select phase", "Applied runic.set_workflow to #{phase_2_workflow.name}.")
      |> sync_status()

    {agent, directives} = strategy_cmd(demo.agent, :runic_feed_signal, %{data: phase_2_input})

    demo =
      demo
      |> Map.put(:agent, agent)
      |> sync_status()
      |> run_directives(directives)

    phase_2_productions = productions_for(demo.agent)

    demo
    |> Map.put(:phase_2_graph, graph_for(demo.agent, fn -> phase_2_workflow end))
    |> Map.put(:phase_2_productions, phase_2_productions)
    |> Map.put(:article_markdown, extract_article_markdown(phase_2_productions))
    |> Map.put(:takeaway, extract_takeaway(phase_2_productions))
    |> append_log("Complete", completion_detail(phase_2_type, phase_2_workflow.name))
    |> sync_status()
  end

  @doc "Returns the fixed ordering for the phase-1 adaptive DAG."
  @spec phase_1_order() :: [atom()]
  def phase_1_order, do: @phase_1_order

  @doc "Returns the fixed ordering for the selected phase-2 adaptive DAG."
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

  defp reshape_for_phase_2(productions, :full) do
    %{
      topic: extract_topic(productions),
      topic_id: extract_topic_id(productions),
      research_summary: extract_summary(productions),
      source_notes: extract_source_notes(productions)
    }
  end

  defp reshape_for_phase_2(productions, :slim) do
    %{
      topic: extract_topic(productions),
      topic_id: extract_topic_id(productions),
      source_notes: extract_source_notes(productions),
      research_summary: extract_summary(productions),
      outline: [extract_summary(productions)]
    }
  end

  defp extract_topic(productions) do
    Enum.find_value(productions, "Unknown Topic", fn
      %{topic: topic} when is_binary(topic) -> topic
      _ -> nil
    end)
  end

  defp extract_topic_id(productions) do
    Enum.find_value(productions, Fixtures.default_topic_id(), fn
      %{topic_id: topic_id} when is_binary(topic_id) -> topic_id
      _ -> nil
    end)
  end

  defp extract_summary(productions) do
    Enum.find_value(productions, "", fn
      %{research_summary: summary} when is_binary(summary) -> summary
      _ -> nil
    end)
  end

  defp extract_summary_length(productions), do: extract_summary(productions) |> String.length()

  defp extract_source_notes(productions) do
    Enum.find_value(productions, [], fn
      %{source_notes: source_notes} when is_list(source_notes) -> source_notes
      _ -> nil
    end)
  end

  defp extract_article_markdown(productions) do
    Enum.find_value(productions, "", fn
      %{article_markdown: article_markdown} when is_binary(article_markdown) -> article_markdown
      _ -> nil
    end)
  end

  defp extract_takeaway(productions) do
    Enum.find_value(productions, "", fn
      %{takeaway: takeaway} when is_binary(takeaway) -> takeaway
      _ -> nil
    end)
  end

  defp completion_detail(phase_2_type, workflow_name) do
    "Completed the #{phase_2_type} adaptive branch using #{workflow_name}."
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
