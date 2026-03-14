defmodule AgentJido.Demos.ActionsRuntimeDemo do
  @moduledoc """
  Deterministic `Jido.Exec.run/3` walkthrough for the public actions runtime demo.
  """

  alias AgentJido.Demos.ActionsRuntime.{
    ConvertTemperatureAction,
    FixtureAnalyzeAction,
    FixtureCallWithToolsAction,
    FixtureChatAction,
    FixtureCompleteAction,
    FixtureDecomposeAction,
    FixtureExplainAction,
    FixtureGenerateObjectAction,
    FixtureInferAction,
    FixturePlanAction,
    FixturePrioritizeAction,
    FixtureRunStrategyAction
  }

  alias Jido.AI.Actions.Quota.{GetStatus, Reset}
  alias Jido.AI.Actions.Retrieval.{ClearMemory, RecallMemory, UpsertMemory}
  alias Jido.AI.Actions.ToolCalling.{ExecuteTool, ListTools}
  alias Jido.AI.Quota.Store, as: QuotaStore
  alias Jido.AI.Retrieval.Store, as: RetrievalStore

  @retrieval_namespace "actions_runtime_demo"
  @quota_scope "actions_runtime_demo"
  @quota_window_ms 60_000

  @families [
    %{
      id: "llm",
      title: "LLM envelopes",
      description: "Chat, complete, and generate-object envelopes through deterministic fixture actions."
    },
    %{
      id: "tool_calling",
      title: "Tool calling",
      description: "List tools, execute a deterministic conversion tool, and complete a fixture call_with_tools round trip."
    },
    %{
      id: "planning",
      title: "Planning",
      description: "Plan, decompose, and prioritize work through deterministic planning fixtures."
    },
    %{
      id: "reasoning",
      title: "Reasoning",
      description: "Analyze, infer, explain, and run one strategy with deterministic reasoning fixtures."
    },
    %{
      id: "retrieval",
      title: "Retrieval",
      description: "Use the shipped retrieval actions against the in-process memory store."
    },
    %{
      id: "quota",
      title: "Quota usage and reset",
      description: "Use the shipped quota actions against the in-process quota store."
    }
  ]

  @spec families() :: [map()]
  def families, do: @families

  @spec run_all() :: [map()]
  def run_all do
    Enum.map(@families, &run_family(&1.id))
  end

  @spec run_family(String.t() | atom()) :: map()
  def run_family(family) when is_atom(family), do: run_family(Atom.to_string(family))

  def run_family("llm") do
    calls = [
      run_call("Chat", FixtureChatAction, %{prompt: "Summarize Elixir in one sentence."}),
      run_call("Complete", FixtureCompleteAction, %{prompt: "The key feature of OTP is"}),
      run_call("GenerateObject", FixtureGenerateObjectAction, %{prompt: "Return title/confidence for note: Jido AI roadmap"})
    ]

    package_result(
      "llm",
      "LLM envelopes",
      "Three deterministic fixture actions return the same envelope shape you inspect when calling runtime actions directly.",
      calls
    )
  end

  def run_family("tool_calling") do
    context = tool_context()

    calls = [
      run_call("ListTools", ListTools, %{include_schema: true}, context),
      run_call(
        "ExecuteTool",
        ExecuteTool,
        %{
          tool_name: ConvertTemperatureAction.name(),
          params: %{"value" => 72.0, "from" => "fahrenheit", "to" => "celsius"}
        },
        context
      ),
      run_call(
        "CallWithTools",
        FixtureCallWithToolsAction,
        %{
          prompt: "Use convert_temperature for 72F to C and explain.",
          tools: [ConvertTemperatureAction.name()],
          auto_execute: true,
          max_turns: 5
        },
        context
      )
    ]

    package_result(
      "tool_calling",
      "Tool calling",
      "The demo keeps the real runtime entrypoint, uses the shipped list/execute actions, and swaps in one deterministic auto-executed tool round trip.",
      calls
    )
  end

  def run_family("planning") do
    calls = [
      run_call(
        "Plan",
        FixturePlanAction,
        %{
          goal: "Ship v1 onboarding flow",
          constraints: ["Two engineers", "Six-week timeline"],
          resources: ["Existing auth service", "Hosted Postgres"]
        }
      ),
      run_call(
        "Decompose",
        FixtureDecomposeAction,
        %{
          goal: "Ship v1 onboarding flow",
          max_depth: 3,
          context: "B2B SaaS onboarding"
        }
      ),
      run_call(
        "Prioritize",
        FixturePrioritizeAction,
        %{
          tasks: ["Design onboarding steps", "Implement analytics events", "Write migration docs"],
          criteria: "Customer impact first, then dependency risk"
        }
      )
    ]

    package_result(
      "planning",
      "Planning",
      "The planning family stays deterministic while preserving the direct runtime call pattern for plan, decompose, and prioritize.",
      calls
    )
  end

  def run_family("reasoning") do
    calls = [
      run_call(
        "Analyze",
        FixtureAnalyzeAction,
        %{
          input: "Customer churn increased 18% this quarter while support volume stayed flat.",
          analysis_type: :summary
        }
      ),
      run_call(
        "Infer",
        FixtureInferAction,
        %{
          premises: "All production incidents trigger a postmortem. Incident INC-42 was a production incident.",
          question: "Should INC-42 have a postmortem?"
        }
      ),
      run_call(
        "Explain",
        FixtureExplainAction,
        %{
          topic: "GenServer supervision trees",
          detail_level: :intermediate,
          audience: "backend engineers",
          include_examples: true
        }
      ),
      run_call(
        "RunStrategy",
        FixtureRunStrategyAction,
        %{
          strategy: :cot,
          prompt: "Recommend one rollout option and include a fallback in three bullets."
        }
      )
    ]

    package_result(
      "reasoning",
      "Reasoning",
      "Analyze, infer, explain, and run_strategy all exercise real runtime calls while staying deterministic for the site demo.",
      calls
    )
  end

  def run_family("retrieval") do
    :ok = RetrievalStore.ensure_table!()
    _ = Jido.Exec.run(ClearMemory, %{namespace: @retrieval_namespace}, %{})

    calls = [
      run_call(
        "UpsertMemory",
        UpsertMemory,
        %{
          namespace: @retrieval_namespace,
          id: "seattle_weekly",
          text: "Seattle mornings are cooler this week with intermittent rain.",
          metadata: %{source: "weekly_summary", region: "pnw"}
        }
      ),
      run_call(
        "UpsertMemory",
        UpsertMemory,
        %{
          namespace: @retrieval_namespace,
          id: "gear_note",
          text: "Keep a light shell ready for Seattle commutes when rain bands move in.",
          metadata: %{source: "gear_note", region: "pnw"}
        }
      ),
      run_call(
        "RecallMemory",
        RecallMemory,
        %{namespace: @retrieval_namespace, query: "seattle rain outlook", top_k: 2}
      ),
      run_call("ClearMemory", ClearMemory, %{namespace: @retrieval_namespace})
    ]

    package_result(
      "retrieval",
      "Retrieval",
      "This family uses the shipped retrieval actions directly against the in-process store, so the site demo and your local runtime calls are the same surface.",
      calls
    )
  end

  def run_family("quota") do
    :ok = QuotaStore.ensure_table!()
    :ok = QuotaStore.reset(@quota_scope)
    _ = QuotaStore.add_usage(@quota_scope, 180, @quota_window_ms)
    _ = QuotaStore.add_usage(@quota_scope, 240, @quota_window_ms)

    context = %{
      plugin_state: %{
        quota: %{
          scope: @quota_scope,
          window_ms: @quota_window_ms,
          max_requests: 5,
          max_total_tokens: 1_000
        }
      }
    }

    calls = [
      run_call("GetStatus", GetStatus, %{}, context),
      run_call("Reset", Reset, %{scope: @quota_scope}, context),
      run_call("GetStatus After Reset", GetStatus, %{}, context)
    ]

    package_result(
      "quota",
      "Quota usage and reset",
      "The quota family uses the shipped actions directly and shows the before/reset/after flow against the in-process quota store.",
      calls
    )
  end

  def run_family(other) do
    raise ArgumentError, "unsupported actions runtime family: #{inspect(other)}"
  end

  defp package_result(id, title, summary, calls) do
    %{
      id: id,
      title: title,
      summary: summary,
      calls: calls,
      succeeded: Enum.all?(calls, &match?(%{status: :ok}, &1))
    }
  end

  defp run_call(label, module, params, context \\ %{}) do
    case Jido.Exec.run(module, params, context) do
      {:ok, result} ->
        %{
          label: label,
          module: inspect(module),
          params: params,
          result: result,
          status: :ok
        }

      {:error, reason} ->
        %{
          label: label,
          module: inspect(module),
          params: params,
          result: %{error: inspect(reason)},
          status: :error
        }
    end
  end

  defp tool_context do
    %{tools: %{ConvertTemperatureAction.name() => ConvertTemperatureAction}}
  end
end
