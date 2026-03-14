defmodule AgentJido.Demos.RunicResearchStudio.RuntimeDemo do
  @moduledoc """
  Pure deterministic wrapper around the research studio Runic workflow.

  This module uses the real `Jido.Runic.Strategy` command surface while keeping
  all example data local and deterministic for documentation/demo purposes.
  """

  alias AgentJido.Demos.RunicResearchStudio.{Fixtures, OrchestratorAgent}
  alias Jido.Agent.Directive.Emit
  alias Jido.Agent.Strategy.State, as: StratState
  alias Jido.Instruction
  alias Jido.Runic.Directive.ExecuteRunnable
  alias Jido.Runic.Introspection
  alias Runic.Workflow
  alias Runic.Workflow.Invokable

  @pipeline_order [:plan_queries, :simulate_search, :build_outline, :draft_article, :edit_and_assemble]

  defstruct mode: :auto,
            selected_topic_id: Fixtures.default_topic_id(),
            selected_topic: nil,
            agent: nil,
            graph: %{nodes: [], edges: []},
            node_map: %{},
            summary: %{total_nodes: 0, facts_produced: 0, satisfied: false, productions: 0},
            productions: [],
            facts: [],
            executions: [],
            log: [],
            step_history: [],
            status: :idle,
            execution_mode: :auto,
            held_count: 0,
            held_nodes: [],
            done?: false,
            article_title: "",
            article_markdown: "",
            takeaway: ""

  @type execution_entry :: %{
          required(:index) => non_neg_integer(),
          required(:node) => atom(),
          required(:action) => module() | nil,
          required(:status) => atom(),
          required(:input) => map(),
          required(:output) => map() | nil,
          required(:error) => term()
        }

  @type t :: %__MODULE__{
          mode: :auto | :step,
          selected_topic_id: String.t(),
          selected_topic: map(),
          agent: Jido.Agent.t(),
          graph: map(),
          node_map: map(),
          summary: map(),
          productions: [map()],
          facts: list(),
          executions: [execution_entry()],
          log: [map()],
          step_history: [map()],
          status: atom(),
          execution_mode: atom(),
          held_count: non_neg_integer(),
          held_nodes: [atom()],
          done?: boolean(),
          article_title: String.t(),
          article_markdown: String.t(),
          takeaway: String.t()
        }

  @doc "Returns the deterministic topic catalog used by both research studio pages."
  @spec topics() :: [map()]
  def topics, do: Fixtures.catalog()

  @doc "Returns the pipeline order used to render graph rows consistently."
  @spec pipeline_order() :: [atom()]
  def pipeline_order, do: @pipeline_order

  @doc "Builds a fresh demo state for either auto mode or step mode."
  @spec new(:auto | :step, String.t() | nil) :: t()
  def new(mode \\ :auto, topic_id \\ nil) when mode in [:auto, :step] do
    selected_topic = Fixtures.fetch!(topic_id || Fixtures.default_topic_id())
    agent = initialize_agent(mode)

    %__MODULE__{
      mode: mode,
      selected_topic_id: selected_topic.id,
      selected_topic: selected_topic,
      agent: agent
    }
    |> refresh_from_agent()
  end

  @doc "Resets the demo while optionally changing topic or mode."
  @spec reset(t(), keyword()) :: t()
  def reset(%__MODULE__{} = demo, opts \\ []) do
    mode = Keyword.get(opts, :mode, demo.mode)
    topic_id = Keyword.get(opts, :topic_id, demo.selected_topic_id)
    new(mode, topic_id)
  end

  @doc "Changes topics by rebuilding the demo state for the current mode."
  @spec select_topic(t(), String.t()) :: t()
  def select_topic(%__MODULE__{} = demo, topic_id) do
    reset(demo, topic_id: topic_id)
  end

  @doc "Runs the full workflow in auto mode for the currently selected topic."
  @spec run_auto(t()) :: t()
  def run_auto(%__MODULE__{} = demo) do
    demo =
      demo
      |> reset(mode: :auto)
      |> append_log("Run", "Fed #{demo.selected_topic.title} into the deterministic auto pipeline.")

    {agent, directives} =
      strategy_cmd(demo.agent, :runic_feed_signal, %{data: %{topic: demo.selected_topic.title}})

    demo =
      demo
      |> Map.put(:agent, agent)
      |> refresh_from_agent()
      |> run_directives(directives)

    append_log(demo, "Complete", completion_detail(demo))
  end

  @doc "Prepares step mode by feeding the selected topic and pausing on held runnables."
  @spec prepare_step(t()) :: t()
  def prepare_step(%__MODULE__{} = demo) do
    demo = reset(demo, mode: :step)

    {agent, directives} =
      strategy_cmd(demo.agent, :runic_feed_signal, %{data: %{topic: demo.selected_topic.title}})

    demo
    |> Map.put(:agent, agent)
    |> refresh_from_agent()
    |> append_log("Prepare", "Fed #{demo.selected_topic.title} and paused with held runnables.")
    |> run_directives(directives)
  end

  @doc "Advances one held batch in step mode."
  @spec step(t()) :: t()
  def step(%__MODULE__{} = demo) do
    {agent, directives} = strategy_cmd(demo.agent, :runic_step, %{})

    demo
    |> Map.put(:agent, agent)
    |> refresh_from_agent()
    |> append_log("Step", "Dispatched the next held runnable batch.")
    |> run_directives(directives)
  end

  @doc "Resumes the step-mode workflow back into auto mode until completion."
  @spec resume(t()) :: t()
  def resume(%__MODULE__{} = demo) do
    {agent, directives} = strategy_cmd(demo.agent, :runic_resume, %{})

    demo =
      demo
      |> Map.put(:agent, agent)
      |> refresh_from_agent()
      |> append_log("Resume", "Switched the workflow back to auto mode and drained remaining runnables.")
      |> run_directives(directives)

    append_log(demo, "Complete", completion_detail(demo))
  end

  defp run_directives(%__MODULE__{} = demo, directives) when directives in [nil, []], do: refresh_from_agent(demo)

  defp run_directives(%__MODULE__{} = demo, directives) when is_list(directives) do
    Enum.reduce(directives, demo, fn
      %ExecuteRunnable{runnable: runnable}, acc ->
        executed = Invokable.execute(runnable.node, runnable)
        {agent, next_directives} = strategy_cmd(acc.agent, :runic_apply_result, %{runnable: executed})

        acc
        |> Map.put(:agent, agent)
        |> record_execution(executed)
        |> refresh_from_agent()
        |> run_directives(next_directives)

      %Emit{} = directive, acc ->
        signal_type = Map.get(directive.signal, :type, "runic.workflow.production")
        append_log(acc, "Emit", "Emitted #{signal_type}.")

      _other, acc ->
        acc
    end)
  end

  defp initialize_agent(mode) do
    agent = OrchestratorAgent.new()

    if mode == :step do
      {agent, _directives} = strategy_cmd(agent, :runic_set_mode, %{mode: :step})
      agent
    else
      agent
    end
  end

  defp strategy_cmd(agent, action, params) do
    instruction = %Instruction{action: action, params: params}
    OrchestratorAgent.cmd(agent, instruction)
  end

  defp record_execution(%__MODULE__{} = demo, runnable) do
    entry = %{
      index: length(demo.executions),
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

  defp refresh_from_agent(%__MODULE__{} = demo) do
    strat = StratState.get(demo.agent, %{})
    workflow = Map.get(strat, :workflow, OrchestratorAgent.build_workflow())
    graph = Introspection.annotated_graph(workflow, strat)
    summary = Introspection.execution_summary(workflow)
    productions = Workflow.raw_productions(workflow)
    facts = Workflow.facts(workflow)
    step_history = strat |> Map.get(:step_history, []) |> Enum.reverse()
    held_runnables = Map.get(strat, :held_runnables, [])

    final_article =
      productions
      |> Enum.find(fn production ->
        is_map(production) and
          (Map.has_key?(production, :article_markdown) or Map.has_key?(production, "article_markdown"))
      end) || %{}

    %{
      demo
      | graph: graph,
        node_map: Introspection.node_map(workflow),
        summary: summary,
        productions: productions,
        facts: facts,
        step_history: step_history,
        status: Map.get(strat, :status, :idle),
        execution_mode: Map.get(strat, :execution_mode, :auto),
        held_count: length(held_runnables),
        held_nodes: Enum.map(held_runnables, & &1.node.name),
        done?: Map.get(strat, :status) in [:success, :failure],
        article_title: Map.get(final_article, :article_title, ""),
        article_markdown: Map.get(final_article, :article_markdown, ""),
        takeaway: Map.get(final_article, :takeaway, "")
    }
  end

  defp append_log(%__MODULE__{} = demo, label, detail) when is_binary(detail) do
    entry = %{label: label, detail: detail}
    %{demo | log: [entry | demo.log] |> Enum.take(40)}
  end

  defp action_module_for(%Jido.Runic.ActionNode{} = node), do: node.action_mod
  defp action_module_for(_node), do: nil

  defp log_label(entry), do: entry.node |> Atom.to_string() |> String.replace("_", " ") |> String.capitalize()

  defp log_detail(%{status: :completed, output: output}) do
    keys = output |> Map.keys() |> Enum.map_join(", ", &to_string/1)
    "Completed with output keys: #{keys}."
  end

  defp log_detail(%{status: :failed, error: error}), do: "Failed with #{inspect(error)}."
  defp log_detail(_entry), do: "Advanced the workflow."

  defp completion_detail(%__MODULE__{} = demo) do
    case demo.status do
      :success ->
        "Workflow completed with #{length(demo.executions)} executed node(s) and #{length(demo.productions)} production artifact(s)."

      :failure ->
        "Workflow ended in failure after #{length(demo.executions)} executed node(s)."

      other ->
        "Workflow is currently #{other}."
    end
  end
end
