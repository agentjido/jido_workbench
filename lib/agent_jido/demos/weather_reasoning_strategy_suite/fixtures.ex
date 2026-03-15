defmodule AgentJido.Demos.WeatherReasoningStrategySuite.Fixtures do
  @moduledoc """
  Deterministic fixtures for the weather reasoning strategy comparison lab.
  """

  @strategy_profiles %{
    react: %{
      id: :react,
      name: "ReAct",
      style: "Reason/act loop with explicit tool boundaries",
      latency: "medium",
      output_shape: "fact-check, then recommendation",
      best_for: "Weather flows that genuinely need tool calls or live data refreshes",
      tradeoff: "Needs well-scoped Actions and clear retry policy"
    },
    cod: %{
      id: :cod,
      name: "CoD",
      style: "Minimal drafting with fast refinement",
      latency: "low",
      output_shape: "compressed answer with quick rationale",
      best_for: "Fast first-pass guidance when brevity matters",
      tradeoff: "Can skip nuance or hedge too aggressively"
    },
    aot: %{
      id: :aot,
      name: "AoT",
      style: "Algorithmic decomposition into explicit checks",
      latency: "medium",
      output_shape: "procedural checklist",
      best_for: "Threshold-driven or formula-like weather decisions",
      tradeoff: "Feels rigid on open-ended planning prompts"
    },
    cot: %{
      id: :cot,
      name: "CoT",
      style: "Linear step-by-step reasoning",
      latency: "medium",
      output_shape: "ordered factors and conclusion",
      best_for: "Single recommendation decisions that need transparent reasoning",
      tradeoff: "Explores one path rather than multiple options"
    },
    tot: %{
      id: :tot,
      name: "ToT",
      style: "Branching exploration with candidate scoring",
      latency: "high",
      output_shape: "multiple options with ranking",
      best_for: "Comparing alternate plans under uncertainty",
      tradeoff: "More orchestration and explanation overhead"
    },
    got: %{
      id: :got,
      name: "GoT",
      style: "Interdependent graph of considerations",
      latency: "high",
      output_shape: "dependency-aware synthesis",
      best_for: "Complex planning where constraints interact",
      tradeoff: "Harder to explain and maintain than simpler strategies"
    },
    trm: %{
      id: :trm,
      name: "TRM",
      style: "Answer, critique, then revise",
      latency: "high",
      output_shape: "reviewed recommendation with explicit self-check",
      best_for: "Higher-stakes weather or safety decisions",
      tradeoff: "Costs an extra reflection pass"
    },
    adaptive: %{
      id: :adaptive,
      name: "Adaptive",
      style: "Meta-selection over available strategies",
      latency: "medium-high",
      output_shape: "chosen strategy plus routed output",
      best_for: "Mixed workloads where callers should not choose strategy manually",
      tradeoff: "Adds routing logic before the answer is produced"
    }
  }

  @type badge :: %{
          required(:strategy_id) => atom(),
          required(:label) => String.t(),
          required(:reason) => String.t()
        }

  @type strategy_entry :: %{
          required(:id) => atom(),
          required(:name) => String.t(),
          required(:style) => String.t(),
          required(:latency) => String.t(),
          required(:output_shape) => String.t(),
          required(:best_for) => String.t(),
          required(:tradeoff) => String.t(),
          required(:fit) => String.t(),
          required(:why) => String.t(),
          required(:sample) => String.t()
        }

  @type preset :: %{
          required(:id) => String.t(),
          required(:title) => String.t(),
          required(:question) => String.t(),
          required(:summary) => String.t(),
          required(:recommendation) => badge(),
          required(:fastest) => badge(),
          required(:exploratory) => badge(),
          required(:strategies) => [strategy_entry()]
        }

  @doc "Returns the default preset shown in the comparison lab."
  @spec default_preset_id() :: String.t()
  def default_preset_id, do: "commute-window"

  @doc "Returns the full deterministic comparison catalog."
  @spec catalog() :: [preset()]
  def catalog do
    [
      %{
        id: "commute-window",
        title: "Commuter Decision",
        question: "Should I bike or drive to work if it is 45°F with a 30% chance of rain and a 20-minute commute?",
        summary: "One practical recommendation with moderate uncertainty and a clear personal tradeoff.",
        recommendation: badge(:cot, "CoT keeps the answer transparent without spending extra effort exploring branches."),
        fastest: badge(:cod, "CoD is the quickest way to ship a concise recommendation when the user just wants the call."),
        exploratory: badge(:tot, "ToT is useful if you want multiple commute options rather than one recommendation."),
        strategies: [
          strategy_entry(
            :react,
            "Strong",
            "Great if the answer depends on fetching the latest forecast before deciding.",
            "Check the weather tool, verify the rain window, then recommend biking only if the rain risk stays outside commute time."
          ),
          strategy_entry(
            :cod,
            "Strong",
            "Fast and concise when the user wants a short recommendation with one or two reasons.",
            "Bike if you can tolerate cool air and carry a shell; otherwise drive if rain tolerance is low."
          ),
          strategy_entry(
            :aot,
            "Situational",
            "Useful if you want an explicit threshold rule for temperature, rain, and commute length.",
            "If rain chance stays below 40%, wind is manageable, and travel time is under 25 minutes, biking remains acceptable."
          ),
          strategy_entry(
            :cot,
            "Best fit",
            "Linear reasoning makes the commute factors easy to audit and explain.",
            "Rain risk is modest, the commute is short, and 45°F is manageable with layers, so biking is reasonable if you are comfortable carrying a light shell."
          ),
          strategy_entry(
            :tot,
            "Situational",
            "Helpful only if you want to compare bike, drive, and hybrid options side by side.",
            "Option A bike with shell, option B transit plus walk, option C drive; score each by comfort, speed, and rain tolerance."
          ),
          strategy_entry(
            :got,
            "Overkill",
            "The dependency graph adds complexity without much payoff for a short commute decision.",
            "Link temperature, precipitation timing, clothing insulation, and arrival flexibility before synthesizing a recommendation."
          ),
          strategy_entry(
            :trm,
            "Situational",
            "Valuable if the recommendation must be especially cautious or self-reviewed.",
            "Initial answer says bike; reflection step adds the caveat that uncertain rain timing could justify driving if punctuality is critical."
          ),
          strategy_entry(
            :adaptive,
            "Strong",
            "Good if this prompt lives inside a mixed assistant that routes many different weather requests.",
            "Route this commute prompt to CoT, then return the step-by-step recommendation with the chosen strategy noted."
          )
        ]
      },
      %{
        id: "weekend-trip",
        title: "Weekend Trip Planning",
        question: "Plan a weekend hiking trip for Portland with changing mountain weather, backup indoor options, and a packing list.",
        summary: "Several viable plans exist, and the answer should compare alternatives instead of locking into one too early.",
        recommendation: badge(:tot, "ToT shines when the user needs multiple weather-resilient plans ranked against each other."),
        fastest: badge(:cod, "CoD can draft a quick shortlist, but it will miss richer branch comparison."),
        exploratory: badge(:got, "GoT is strongest if you want linked constraints like route, shelter, travel time, and gear to interact."),
        strategies: [
          strategy_entry(
            :react,
            "Strong",
            "Useful when you want the planner to pull fresh conditions and trail facts before responding.",
            "Fetch forecast and trail data, then propose one primary trail plan plus one fallback museum itinerary."
          ),
          strategy_entry(
            :cod,
            "Strong",
            "Good for a quick shortlist when the user values speed over a full comparison matrix.",
            "Pack layers, waterproof shells, and pick one low-risk trail plus one indoor backup."
          ),
          strategy_entry(
            :aot,
            "Situational",
            "Works if you want to encode explicit packing and go or no-go thresholds.",
            "Check rainfall, wind, travel time, and elevation in sequence before generating the final plan."
          ),
          strategy_entry(
            :cot,
            "Strong",
            "Provides a clear recommendation but still tends to settle on one primary plan.",
            "Explain the forecast, walk through gear implications, then recommend a single best trip outline."
          ),
          strategy_entry(
            :tot,
            "Best fit",
            "This prompt benefits from branching into multiple weekend plans and ranking them.",
            "Generate three plans across low, medium, and high weather risk, then score them by resilience and fun."
          ),
          strategy_entry(
            :got,
            "Strong",
            "GoT is compelling when route, shelter, packing, and transport constraints affect each other.",
            "Build a dependency graph across trail exposure, shelter availability, drive time, and rain gear before deciding."
          ),
          strategy_entry(
            :trm,
            "Situational",
            "Useful when you want a final plan reviewed for missing safety caveats.",
            "Draft the trip, critique exposure and backup coverage, then revise the weekend recommendation."
          ),
          strategy_entry(
            :adaptive,
            "Strong",
            "A good mixed-workload surface because this prompt should likely route to ToT or GoT automatically.",
            "Recognize planning complexity, route to ToT, and return the ranked trip options with backup plans."
          )
        ]
      },
      %{
        id: "storm-operations",
        title: "Storm Operations Call",
        question: "Should a school district delay outdoor sports if a spring storm may bring hail, lightning, and shifting arrival times?",
        summary: "The response is higher stakes and benefits from explicit self-review rather than a quick first-pass answer.",
        recommendation: badge(:trm, "TRM adds a deliberate critique pass before making a weather safety recommendation."),
        fastest: badge(:react, "ReAct is the fastest route if live alert checks matter more than comparative reasoning."),
        exploratory: badge(:adaptive, "Adaptive is useful when the same operations assistant handles both simple and high-stakes prompts."),
        strategies: [
          strategy_entry(
            :react,
            "Strong",
            "Great when the system must check current advisories, radar, and district policies first.",
            "Query alerts and district rules, then recommend delaying play if lightning timing overlaps the event window."
          ),
          strategy_entry(
            :cod,
            "Overkill",
            "A fast draft is risky here because the prompt needs careful safety framing.",
            "Delay if uncertainty stays high, but the compressed rationale may under-explain hail and lightning thresholds."
          ),
          strategy_entry(
            :aot,
            "Strong",
            "Helpful when the district wants explicit threshold checks for hail, lightning, and timing windows.",
            "Evaluate alert severity, confidence interval, and safe shelter availability before the final recommendation."
          ),
          strategy_entry(
            :cot,
            "Strong",
            "A transparent step-by-step answer works if one final recommendation is still enough.",
            "Walk through storm timing, severity, shelter access, and consequence of being wrong before recommending delay or cancellation."
          ),
          strategy_entry(
            :tot,
            "Situational",
            "Useful if leadership wants multiple operating plans, but it is not always necessary.",
            "Compare proceed, delay, and cancel options with clear safety and logistics scores."
          ),
          strategy_entry(
            :got,
            "Situational",
            "Worth it when transportation, staffing, shelters, and weather timing interact heavily.",
            "Link bus schedules, field drainage, staffing coverage, and storm arrival into one synthesis graph."
          ),
          strategy_entry(
            :trm,
            "Best fit",
            "The self-review pass is a good match for a safety-sensitive call with uncertain timing.",
            "Initial answer recommends delay; reflection confirms lightning uncertainty and tight shelter margins justify the safer call."
          ),
          strategy_entry(
            :adaptive,
            "Strong",
            "Strong option when the assistant should decide whether to route to CoT, ToT, or TRM on its own.",
            "Classify this as high stakes, route to TRM, and return a safety-first recommendation with the selected strategy noted."
          )
        ]
      }
    ]
  end

  @doc "Fetches a preset by id or raises."
  @spec fetch!(String.t() | nil) :: preset()
  def fetch!(nil), do: fetch!(default_preset_id())

  def fetch!(id) when is_binary(id) do
    Enum.find(catalog(), &(&1.id == id)) ||
      raise ArgumentError, "unknown weather reasoning preset: #{inspect(id)}"
  end

  @doc "Fetches one strategy row from a preset or raises."
  @spec strategy!(preset(), atom()) :: strategy_entry()
  def strategy!(preset, strategy_id) when is_map(preset) and is_atom(strategy_id) do
    Enum.find(preset.strategies, &(&1.id == strategy_id)) ||
      raise ArgumentError, "unknown strategy #{inspect(strategy_id)} for preset #{inspect(preset.id)}"
  end

  defp badge(strategy_id, reason) do
    %{strategy_id: strategy_id, label: strategy_name(strategy_id), reason: reason}
  end

  defp strategy_entry(strategy_id, fit, why, sample) do
    @strategy_profiles
    |> Map.fetch!(strategy_id)
    |> Map.merge(%{fit: fit, why: why, sample: sample})
  end

  defp strategy_name(strategy_id) do
    @strategy_profiles
    |> Map.fetch!(strategy_id)
    |> Map.fetch!(:name)
  end
end
