defmodule AgentJido.Demos.RunicAdaptiveResearcher.Fixtures do
  @moduledoc """
  Deterministic topic fixtures for the adaptive Runic researcher example.
  """

  @topics [
    %{
      id: "incident-retro-rich",
      title: "Incident Retrospective Narrative",
      queries: [
        "Timeline of the customer-facing latency regression",
        "Operational tradeoffs between rollback and mitigation",
        "Signals that show whether the incident is stabilizing"
      ],
      research_summary:
        "The incident timeline shows a deploy-correlated latency increase, a temporary mitigation that reduced user impact, and three follow-up areas that need synthesis across telemetry, release logs, and rollback criteria. Teams reviewing this topic need a structured narrative rather than a one-line digest so the adaptive workflow should keep the outline step and preserve the richer research context.",
      source_notes: [
        %{
          source: "incident-timeline",
          insight: "Latency rose within four minutes of the deploy and dropped after the feature flag was rolled back."
        },
        %{
          source: "slo-review",
          insight:
            "The rollback decision hinged on error-budget burn, not just raw latency, because the mitigation reduced the user-visible blast radius."
        },
        %{
          source: "ops-retro",
          insight: "Teams still needed a narrative that tied timeline, mitigation, and next actions together for the follow-up review."
        }
      ],
      outline: [
        "What changed and how the issue surfaced",
        "Why mitigation bought time before rollback",
        "What the retrospective should lock in next"
      ],
      draft_sections: [
        %{
          heading: "What changed and how the issue surfaced",
          body:
            "The regression appeared immediately after the deploy, which makes the release itself the first place to investigate. The useful detail is not just that latency rose, but how quickly the system signaled a change in user-visible behavior."
        },
        %{
          heading: "Why mitigation bought time before rollback",
          body:
            "Mitigation mattered because it reduced the immediate blast radius while the team compared telemetry, rollout details, and rollback cost. That bought enough time to avoid an impulsive decision while still protecting the error budget."
        },
        %{
          heading: "What the retrospective should lock in next",
          body:
            "A strong retrospective captures the timeline, the mitigation tradeoff, and the signals that should trigger a faster rollback next time. That narrative shape is why the adaptive workflow keeps the outline step for richer research results."
        }
      ],
      takeaway: "Rich research results justify a fuller writing workflow because the synthesis itself becomes part of the output."
    },
    %{
      id: "release-brief-slim",
      title: "Release Brief Digest",
      queries: [
        "Primary change shipped in the release",
        "One user-visible impact worth noting",
        "Single follow-up task after deploy"
      ],
      research_summary: "The release shipped one visible improvement and one follow-up task.",
      source_notes: [
        %{
          source: "release-summary",
          insight: "The release reduced onboarding friction by removing one approval screen."
        }
      ],
      outline: ["Release summary", "User impact", "Follow-up"],
      draft_sections: [
        %{
          heading: "Release summary",
          body:
            "This release removed one approval screen from the onboarding flow, which makes the user-facing change easy to explain without a large research narrative."
        },
        %{
          heading: "User impact",
          body: "The main impact is a shorter setup path, so the summary can stay compact and skip a longer outline step."
        }
      ],
      takeaway: "Thin research results can skip the outline stage and still produce a useful final brief."
    }
  ]

  @doc "Returns the deterministic topic catalog used by the adaptive researcher demo."
  @spec catalog() :: [map()]
  def catalog, do: @topics

  @doc "Returns the default topic id."
  @spec default_topic_id() :: String.t()
  def default_topic_id, do: "incident-retro-rich"

  @doc "Fetches a topic fixture by stable id."
  @spec fetch!(String.t()) :: map()
  def fetch!(id) when is_binary(id) do
    Enum.find(@topics, &(&1.id == id)) ||
      raise ArgumentError, "unknown adaptive researcher topic id: #{inspect(id)}"
  end

  @doc "Fetches a topic fixture by either id or topic title."
  @spec fetch_by_topic!(String.t()) :: map()
  def fetch_by_topic!(topic) when is_binary(topic) do
    normalized = normalize(topic)

    Enum.find(@topics, fn entry ->
      normalize(entry.id) == normalized or normalize(entry.title) == normalized
    end) ||
      raise ArgumentError, "unknown adaptive researcher topic: #{inspect(topic)}"
  end

  defp normalize(value), do: value |> String.downcase() |> String.trim()
end
