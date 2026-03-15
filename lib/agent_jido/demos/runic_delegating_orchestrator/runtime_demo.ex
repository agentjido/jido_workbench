defmodule AgentJido.Demos.RunicDelegatingOrchestrator.RuntimeDemo do
  @moduledoc """
  Deterministic wrapper around the real Runic delegating orchestrator workflow.
  """

  alias AgentJido.Demos.RunicDelegatingOrchestrator.OrchestratorAgent
  alias AgentJido.Demos.RunicResearchStudio.Fixtures
  alias Jido.Agent.Directive.Emit
  alias Jido.Agent.Strategy.State, as: StratState
  alias Jido.Runic.Directive.ExecuteRunnable
  alias Jido.Runic.Introspection
  alias Runic.Workflow
  alias Runic.Workflow.Invokable

  @pipeline_order [:plan_queries, :simulate_search, :build_outline, :draft_article, :edit_and_assemble]

  defstruct selected_topic_id: Fixtures.default_topic_id(),
            selected_topic: nil,
            agent: nil,
            graph: %{nodes: [], edges: []},
            executions: [],
            handoffs: [],
            log: [],
            status: :idle,
            done?: false,
            article_markdown: "",
            takeaway: ""

  @type execution_entry :: %{
          required(:index) => non_neg_integer(),
          required(:target) => :local | {:child, atom()},
          required(:node) => atom(),
          required(:action) => module() | nil,
          required(:status) => atom(),
          required(:input) => map(),
          required(:output) => map() | nil,
          required(:error) => term()
        }

  @type handoff_entry :: %{
          required(:index) => non_neg_integer(),
          required(:tag) => atom(),
          required(:node) => atom(),
          required(:runnable_id) => term(),
          required(:state) => atom(),
          required(:child_module) => module()
        }

  @type t :: %__MODULE__{
          selected_topic_id: String.t(),
          selected_topic: map(),
          agent: Jido.Agent.t(),
          graph: map(),
          executions: [execution_entry()],
          handoffs: [handoff_entry()],
          log: [map()],
          status: atom(),
          done?: boolean(),
          article_markdown: String.t(),
          takeaway: String.t()
        }

  @doc "Returns the deterministic topic catalog used by the delegating example."
  @spec topics() :: [map()]
  def topics, do: Fixtures.catalog()

  @doc "Returns the fixed workflow ordering for rendering the delegating graph."
  @spec pipeline_order() :: [atom()]
  def pipeline_order, do: @pipeline_order

  @doc "Builds a fresh demo state for the selected topic."
  @spec new(String.t() | nil) :: t()
  def new(topic_id \\ nil) do
    selected_topic = Fixtures.fetch!(topic_id || Fixtures.default_topic_id())
    agent = OrchestratorAgent.new()

    %__MODULE__{
      selected_topic_id: selected_topic.id,
      selected_topic: selected_topic,
      agent: agent,
      graph: graph_for(agent)
    }
    |> sync_status()
  end

  @doc "Resets the delegating demo while optionally changing topic."
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

  @doc "Runs the full deterministic delegating workflow."
  @spec run(t()) :: t()
  def run(%__MODULE__{} = demo) do
    demo =
      demo
      |> reset()
      |> append_log("Feed", "Fed the selected topic into the delegating Runic workflow.")

    {agent, directives} =
      strategy_cmd(demo.agent, :runic_feed_signal, %{data: %{topic: demo.selected_topic.title}})

    demo =
      demo
      |> Map.put(:agent, agent)
      |> sync_status()
      |> run_directives(directives)

    productions = productions_for(demo.agent)

    demo
    |> Map.put(:graph, graph_for(demo.agent))
    |> Map.put(:article_markdown, extract_article_markdown(productions))
    |> Map.put(:takeaway, extract_takeaway(productions))
    |> append_log("Complete", "Finished the delegating pipeline with local and child-worker stages.")
    |> sync_status()
  end

  @doc "Returns the completed local node names from the current execution history."
  @spec completed_local_nodes(t()) :: [atom()]
  def completed_local_nodes(%__MODULE__{} = demo) do
    demo.executions
    |> Enum.filter(&(&1.target == :local and &1.status == :completed))
    |> Enum.map(& &1.node)
  end

  @doc "Returns the completed delegated child tags from the current handoff history."
  @spec completed_child_tags(t()) :: [atom()]
  def completed_child_tags(%__MODULE__{} = demo) do
    demo.handoffs
    |> Enum.filter(&(&1.state == :completed))
    |> Enum.map(& &1.tag)
  end

  defp run_directives(%__MODULE__{} = demo, directives) when directives in [nil, []], do: sync_status(demo)

  defp run_directives(%__MODULE__{} = demo, directives) when is_list(directives) do
    Enum.reduce(directives, demo, fn
      %ExecuteRunnable{target: :local} = directive, acc ->
        executed = Invokable.execute(directive.runnable.node, directive.runnable)
        {agent, next_directives} = strategy_cmd(acc.agent, :runic_apply_result, %{runnable: executed})

        acc
        |> Map.put(:agent, agent)
        |> record_execution(executed, :local)
        |> sync_status()
        |> run_directives(next_directives)

      %ExecuteRunnable{target: {:child, tag}} = directive, acc ->
        handle_child_execution(acc, directive, tag)

      %Emit{} = directive, acc ->
        signal_type = Map.get(directive.signal, :type, "runic.workflow.production")
        append_log(acc, "Emit", "Emitted #{signal_type}.")

      _other, acc ->
        acc
    end)
  end

  defp handle_child_execution(%__MODULE__{} = demo, %ExecuteRunnable{} = directive, tag) do
    executor = Map.fetch!(directive.runnable.node, :executor)
    child_module = Map.fetch!(OrchestratorAgent.child_modules(), tag)

    {agent, _spawn_directives} =
      strategy_cmd(demo.agent, :runic_child_dispatch, %{
        tag: tag,
        runnable_id: directive.runnable_id,
        runnable: directive.runnable,
        executor: executor
      })

    demo =
      demo
      |> Map.put(:agent, agent)
      |> record_handoff(tag, directive, :spawn_requested, child_module)
      |> append_log("Delegate", "Assigned #{directive.runnable.node.name} to child #{tag}.")

    {agent, _emit_directives} =
      strategy_cmd(demo.agent, :runic_child_started, %{
        tag: tag,
        pid: self(),
        parent_id: demo.agent.id,
        child_id: "#{tag}-child",
        child_module: child_module,
        meta: %{demo: true}
      })

    demo =
      demo
      |> Map.put(:agent, agent)
      |> record_handoff(tag, directive, :child_started, child_module)
      |> append_log("Child ready", "Child #{tag} accepted #{directive.runnable.node.name}.")

    executed = Invokable.execute(directive.runnable.node, directive.runnable)
    {agent, next_directives} = strategy_cmd(demo.agent, :runic_apply_result, %{runnable: executed})

    demo
    |> Map.put(:agent, agent)
    |> record_execution(executed, {:child, tag})
    |> record_handoff(tag, directive, :completed, child_module)
    |> append_log("Child complete", "Child #{tag} completed #{directive.runnable.node.name}.")
    |> sync_status()
    |> run_directives(next_directives)
  end

  defp strategy_cmd(agent, action, params) do
    OrchestratorAgent.cmd(agent, {action, params})
  end

  defp graph_for(agent) do
    strat = StratState.get(agent, %{})
    workflow = Map.get(strat, :workflow, OrchestratorAgent.build_workflow())
    Introspection.annotated_graph(workflow, strat)
  end

  defp productions_for(agent) do
    agent
    |> current_workflow()
    |> Workflow.raw_productions()
  end

  defp current_workflow(agent) do
    StratState.get(agent, %{})
    |> Map.get(:workflow, OrchestratorAgent.build_workflow())
  end

  defp sync_status(%__MODULE__{} = demo) do
    status = StratState.get(demo.agent, %{}) |> Map.get(:status, :idle)
    %{demo | status: status, done?: status in [:success, :failure]}
  end

  defp record_execution(%__MODULE__{} = demo, runnable, target) do
    entry = %{
      index: length(demo.executions),
      target: target,
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

  defp record_handoff(%__MODULE__{} = demo, tag, %ExecuteRunnable{} = directive, state, child_module) do
    entry = %{
      index: length(demo.handoffs),
      tag: tag,
      node: directive.runnable.node.name,
      runnable_id: directive.runnable_id,
      state: state,
      child_module: child_module
    }

    Map.update!(demo, :handoffs, &(&1 ++ [entry]))
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

  defp log_label(%{target: :local, node: node}), do: "local.#{node}"
  defp log_label(%{target: {:child, tag}, node: node}), do: "child.#{tag}.#{node}"

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
