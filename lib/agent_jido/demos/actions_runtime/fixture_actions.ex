defmodule AgentJido.Demos.ActionsRuntime.FixtureHelpers do
  @moduledoc false

  @spec usage(non_neg_integer(), non_neg_integer()) :: map()
  def usage(input_tokens, output_tokens) do
    %{
      input_tokens: input_tokens,
      output_tokens: output_tokens,
      total_tokens: input_tokens + output_tokens
    }
  end

  @spec compact_whitespace(String.t()) :: String.t()
  def compact_whitespace(text) when is_binary(text) do
    text
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
  end
end

defmodule AgentJido.Demos.ActionsRuntime.FixtureChatAction do
  @moduledoc """
  Deterministic stand-in for a chat-style runtime action envelope.
  """

  use Jido.Action,
    name: "fixture_llm_chat",
    description: "Return a deterministic chat response envelope",
    category: "ai",
    tags: ["llm", "fixture", "chat"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        prompt: Zoi.string(description: "The prompt to answer")
      })

  alias AgentJido.Demos.ActionsRuntime.FixtureHelpers

  @impl true
  def run(params, _context) do
    prompt = FixtureHelpers.compact_whitespace(params[:prompt])

    {:ok,
     %{
       text: "Elixir keeps concurrency manageable because processes, supervisors, and message passing are built into the runtime. Prompt: #{prompt}",
       model: "fixture:haiku",
       usage: FixtureHelpers.usage(18, 26)
     }}
  end
end

defmodule AgentJido.Demos.ActionsRuntime.FixtureCompleteAction do
  @moduledoc """
  Deterministic stand-in for a completion-style runtime action envelope.
  """

  use Jido.Action,
    name: "fixture_llm_complete",
    description: "Return a deterministic completion response envelope",
    category: "ai",
    tags: ["llm", "fixture", "completion"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        prompt: Zoi.string(description: "The completion prefix")
      })

  alias AgentJido.Demos.ActionsRuntime.FixtureHelpers

  @impl true
  def run(params, _context) do
    prompt = FixtureHelpers.compact_whitespace(params[:prompt])

    {:ok,
     %{
       text: "#{prompt} process isolation, supervision trees, and message passing that recover cleanly from failures.",
       model: "fixture:haiku",
       usage: FixtureHelpers.usage(14, 22)
     }}
  end
end

defmodule AgentJido.Demos.ActionsRuntime.FixtureGenerateObjectAction do
  @moduledoc """
  Deterministic stand-in for a generate-object runtime envelope.
  """

  use Jido.Action,
    name: "fixture_llm_generate_object",
    description: "Return a deterministic object-generation envelope",
    category: "ai",
    tags: ["llm", "fixture", "structured-output"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        prompt: Zoi.string(description: "Prompt describing the object to return")
      })

  alias AgentJido.Demos.ActionsRuntime.FixtureHelpers

  @impl true
  def run(_params, _context) do
    {:ok,
     %{
       object: %{
         title: "Jido AI roadmap",
         confidence: 0.93,
         status: "ready_for_review"
       },
       model: "fixture:haiku",
       usage: FixtureHelpers.usage(20, 18)
     }}
  end
end

defmodule AgentJido.Demos.ActionsRuntime.FixturePlanAction do
  @moduledoc """
  Deterministic plan action for local runtime demos.
  """

  use Jido.Action,
    name: "fixture_planning_plan",
    description: "Return a deterministic plan from a goal",
    category: "ai",
    tags: ["planning", "fixture"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        goal: Zoi.string(description: "The goal to plan"),
        constraints: Zoi.list(Zoi.string(), description: "Constraints") |> Zoi.default([]),
        resources: Zoi.list(Zoi.string(), description: "Resources") |> Zoi.default([])
      })

  alias AgentJido.Demos.ActionsRuntime.FixtureHelpers

  @impl true
  def run(params, _context) do
    steps = [
      "Define onboarding scope",
      "Build the first-time user path",
      "Instrument analytics and launch behind a flag"
    ]

    plan_text =
      """
      Goal: #{params[:goal]}
      Constraints: #{Enum.join(params[:constraints], ", ")}
      Resources: #{Enum.join(params[:resources], ", ")}
      """
      |> FixtureHelpers.compact_whitespace()

    {:ok,
     %{
       plan: plan_text,
       steps: steps,
       goal: params[:goal],
       model: "fixture:planner",
       usage: FixtureHelpers.usage(24, 28)
     }}
  end
end

defmodule AgentJido.Demos.ActionsRuntime.FixtureDecomposeAction do
  @moduledoc """
  Deterministic decomposition action for local runtime demos.
  """

  use Jido.Action,
    name: "fixture_planning_decompose",
    description: "Return a deterministic task decomposition",
    category: "ai",
    tags: ["planning", "fixture", "decompose"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        goal: Zoi.string(description: "The goal to decompose"),
        max_depth: Zoi.integer(description: "Requested decomposition depth") |> Zoi.default(3),
        context: Zoi.string(description: "Optional extra context") |> Zoi.optional()
      })

  alias AgentJido.Demos.ActionsRuntime.FixtureHelpers

  @impl true
  def run(params, _context) do
    {:ok,
     %{
       decomposition: [
         %{level: 1, task: "Product design"},
         %{level: 2, task: "Build signup steps"},
         %{level: 2, task: "Add event tracking"}
       ],
       goal: params[:goal],
       max_depth: params[:max_depth],
       model: "fixture:planner",
       usage: FixtureHelpers.usage(19, 17)
     }}
  end
end

defmodule AgentJido.Demos.ActionsRuntime.FixturePrioritizeAction do
  @moduledoc """
  Deterministic prioritization action for local runtime demos.
  """

  use Jido.Action,
    name: "fixture_planning_prioritize",
    description: "Return a deterministic prioritization of tasks",
    category: "ai",
    tags: ["planning", "fixture", "prioritize"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        tasks: Zoi.list(Zoi.string(), description: "Tasks to prioritize"),
        criteria: Zoi.string(description: "Prioritization criteria")
      })

  alias AgentJido.Demos.ActionsRuntime.FixtureHelpers

  @impl true
  def run(params, _context) do
    prioritized =
      params[:tasks]
      |> Enum.with_index(1)
      |> Enum.map(fn {task, rank} ->
        %{task: task, rank: rank, reason: "Ranked by #{FixtureHelpers.compact_whitespace(params[:criteria])}"}
      end)

    {:ok,
     %{
       prioritized_tasks: prioritized,
       criteria: params[:criteria],
       model: "fixture:planner",
       usage: FixtureHelpers.usage(16, 15)
     }}
  end
end

defmodule AgentJido.Demos.ActionsRuntime.FixtureAnalyzeAction do
  @moduledoc """
  Deterministic reasoning analyze action for local runtime demos.
  """

  use Jido.Action,
    name: "fixture_reasoning_analyze",
    description: "Return deterministic analysis text",
    category: "ai",
    tags: ["reasoning", "fixture", "analysis"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        input: Zoi.string(description: "Input to analyze"),
        analysis_type: Zoi.atom(description: "Analysis type") |> Zoi.default(:summary)
      })

  alias AgentJido.Demos.ActionsRuntime.FixtureHelpers

  @impl true
  def run(params, _context) do
    {:ok,
     %{
       result:
         "Summary analysis: support volume stayed flat while churn rose, which points to onboarding or pricing issues rather than incident-driven dissatisfaction.",
       analysis_type: params[:analysis_type],
       model: "fixture:reasoner",
       usage: FixtureHelpers.usage(20, 23)
     }}
  end
end

defmodule AgentJido.Demos.ActionsRuntime.FixtureInferAction do
  @moduledoc """
  Deterministic reasoning infer action for local runtime demos.
  """

  use Jido.Action,
    name: "fixture_reasoning_infer",
    description: "Return deterministic inference output",
    category: "ai",
    tags: ["reasoning", "fixture", "inference"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        premises: Zoi.string(description: "Premises to reason over"),
        question: Zoi.string(description: "Question to answer")
      })

  alias AgentJido.Demos.ActionsRuntime.FixtureHelpers

  @impl true
  def run(params, _context) do
    {:ok,
     %{
       result: "Yes. If every production incident requires a postmortem and INC-42 is a production incident, the postmortem requirement applies.",
       premises: params[:premises],
       question: params[:question],
       model: "fixture:reasoner",
       usage: FixtureHelpers.usage(18, 19)
     }}
  end
end

defmodule AgentJido.Demos.ActionsRuntime.FixtureExplainAction do
  @moduledoc """
  Deterministic reasoning explain action for local runtime demos.
  """

  use Jido.Action,
    name: "fixture_reasoning_explain",
    description: "Return deterministic explanation output",
    category: "ai",
    tags: ["reasoning", "fixture", "explain"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        topic: Zoi.string(description: "Topic to explain"),
        audience: Zoi.string(description: "Audience receiving the explanation"),
        detail_level: Zoi.atom(description: "Detail level") |> Zoi.default(:intermediate),
        include_examples: Zoi.boolean(description: "Whether to include examples") |> Zoi.default(true)
      })

  alias AgentJido.Demos.ActionsRuntime.FixtureHelpers

  @impl true
  def run(params, _context) do
    {:ok,
     %{
       result:
         "Supervision trees group processes so failures restart only the affected part of the system. A GenServer crashing under a DynamicSupervisor can restart without taking the whole app down.",
       topic: params[:topic],
       audience: params[:audience],
       detail_level: params[:detail_level],
       model: "fixture:reasoner",
       usage: FixtureHelpers.usage(17, 24)
     }}
  end
end

defmodule AgentJido.Demos.ActionsRuntime.FixtureRunStrategyAction do
  @moduledoc """
  Deterministic reasoning strategy runner for local runtime demos.
  """

  use Jido.Action,
    name: "fixture_reasoning_run_strategy",
    description: "Return deterministic strategy-run output",
    category: "ai",
    tags: ["reasoning", "fixture", "strategy"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        strategy: Zoi.atom(description: "Reasoning strategy") |> Zoi.default(:cot),
        prompt: Zoi.string(description: "Prompt for the strategy run")
      })

  alias AgentJido.Demos.ActionsRuntime.FixtureHelpers

  @impl true
  def run(params, _context) do
    {:ok,
     %{
       result: "Recommendation: launch behind a feature flag, measure activation weekly, and keep a manual rollback checklist ready.",
       strategy: params[:strategy],
       trace: [
         "Identify the safest rollout option",
         "Choose one measurable checkpoint",
         "Add a fallback before general availability"
       ],
       model: "fixture:reasoner",
       usage: FixtureHelpers.usage(22, 20)
     }}
  end
end

defmodule AgentJido.Demos.ActionsRuntime.FixtureCallWithToolsAction do
  @moduledoc """
  Deterministic stand-in for a tool-calling round trip with auto execution.
  """

  use Jido.Action,
    name: "fixture_tool_calling_call_with_tools",
    description: "Return a deterministic tool-calling conversation result",
    category: "ai",
    tags: ["tool-calling", "fixture", "runtime"],
    vsn: "1.0.0",
    schema:
      Zoi.object(%{
        prompt: Zoi.string(description: "Prompt to route through tool calling"),
        tools: Zoi.list(Zoi.string(), description: "Allowed tool names") |> Zoi.default([]),
        auto_execute: Zoi.boolean(description: "Whether to auto-execute tool calls") |> Zoi.default(true),
        max_turns: Zoi.integer(description: "Maximum turns") |> Zoi.default(5)
      })

  alias AgentJido.Demos.ActionsRuntime.{ConvertTemperatureAction, FixtureHelpers}
  alias Jido.AI.Actions.ToolCalling.ExecuteTool

  @impl true
  def run(params, context) do
    tools = Map.merge(%{ConvertTemperatureAction.name() => ConvertTemperatureAction}, Map.get(context, :tools, %{}))
    context = Map.put(context, :tools, tools)

    arguments = %{"value" => 72.0, "from" => "fahrenheit", "to" => "celsius"}

    {:ok, executed} =
      Jido.Exec.run(
        ExecuteTool,
        %{tool_name: ConvertTemperatureAction.name(), params: arguments},
        context
      )

    {:ok,
     %{
       type: :final,
       content: "Converted 72F to 22.2C using convert_temperature. For a quick errand, a light jacket is enough.",
       prompt: params[:prompt],
       tool_calls: [
         %{id: "tc_runtime_1", name: ConvertTemperatureAction.name(), arguments: arguments}
       ],
       tool_results: [executed],
       turns: 2,
       model: "fixture:tool-router",
       usage: FixtureHelpers.usage(21, 18)
     }}
  end
end
