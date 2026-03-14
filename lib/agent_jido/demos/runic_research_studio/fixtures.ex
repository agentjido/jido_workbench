defmodule AgentJido.Demos.RunicResearchStudio.Fixtures do
  @moduledoc """
  Deterministic topic fixtures for the Runic research studio examples.
  """

  @topics [
    %{
      id: "elixir-concurrency",
      title: "Elixir Concurrency",
      queries: [
        "BEAM process model and actor isolation",
        "GenServer and supervision patterns in Elixir",
        "Telemetry and observability for concurrent Elixir systems"
      ],
      outline_seed: [
        "Why Elixir concurrency feels different",
        "OTP primitives that keep work isolated",
        "Operational habits for observable systems"
      ],
      source_notes: [
        %{
          source: "beam-book",
          insight: "The BEAM keeps millions of processes lightweight by isolating heaps and scheduling reductions instead of OS threads."
        },
        %{
          source: "otp-design-principles",
          insight: "Supervision trees turn crash recovery into an architectural choice instead of an afterthought."
        },
        %{
          source: "telemetry-guides",
          insight: "Telemetry hooks let teams trace message throughput, queue depth, and restart behavior without rewriting business logic."
        }
      ],
      outline: [
        "A runtime built for isolated work",
        "Supervision as the control plane",
        "What good observability looks like in production"
      ],
      draft_sections: [
        %{
          heading: "A runtime built for isolated work",
          body:
            "Elixir concurrency starts with the BEAM scheduler, which treats processes as cheap units of work instead of heavyweight OS constructs. That design gives systems room to fan out work aggressively while keeping failure domains narrow and predictable."
        },
        %{
          heading: "Supervision as the control plane",
          body:
            "OTP supervision turns concurrency from raw message passing into an operable system. Workers can crash, restart, and rejoin the larger workflow without forcing the whole service into a bad state."
        },
        %{
          heading: "What good observability looks like in production",
          body:
            "Telemetry, tracing, and queue-level metrics tell you whether concurrency is helping or just hiding backpressure. Teams that instrument restart reasons, mailbox growth, and stage latency can tune workflows before incidents escalate."
        }
      ],
      takeaway: "Concurrency pays off when isolation, supervision, and observability are designed together."
    },
    %{
      id: "fly-bluegreen",
      title: "Blue-Green Deployments on Fly.io",
      queries: [
        "Fly.io bluegreen deployment strategy behavior",
        "Release verification gates for staged Phoenix deploys",
        "Rollback considerations for blue green application releases"
      ],
      outline_seed: [
        "What blue-green buys you on Fly.io",
        "How release validation changes the rollout shape",
        "Where rollback confidence comes from"
      ],
      source_notes: [
        %{
          source: "fly-deploy-docs",
          insight: "Blue-green deploys stand up a full candidate environment before traffic shifts, which narrows the blast radius of regressions."
        },
        %{
          source: "release-checklist",
          insight: "Health checks, migrations, and route verification need to pass before the cutover is considered complete."
        },
        %{
          source: "ops-playbook",
          insight: "Rollback confidence comes from having a stable prior environment still available while the new release is being observed."
        }
      ],
      outline: [
        "Standing up the green environment",
        "Proving the release before switching traffic",
        "Keeping rollback boring"
      ],
      draft_sections: [
        %{
          heading: "Standing up the green environment",
          body:
            "Blue-green on Fly.io starts by bringing up a full replacement environment that can run the new release under realistic conditions. The important property is isolation: you can inspect health and runtime behavior before users see the change."
        },
        %{
          heading: "Proving the release before switching traffic",
          body:
            "A careful deployment flow runs migrations, app health checks, and route-level smoke tests before declaring the release ready. That turns staging verification into a production safety gate instead of a loose recommendation."
        },
        %{
          heading: "Keeping rollback boring",
          body:
            "Rollback is faster and less dramatic when the previous environment remains intact during the observation window. Teams can reverse traffic without rebuilding the old state from scratch."
        }
      ],
      takeaway: "Blue-green works best when validation and rollback are treated as first-class release steps."
    },
    %{
      id: "jido-skills-runtime",
      title: "Jido Skills Runtime",
      queries: [
        "Jido skills manifest loading and registry usage",
        "Prompt composition from SKILL.md assets",
        "Operational boundaries for workbench-first builder skills"
      ],
      outline_seed: [
        "What a skills runtime actually manages",
        "Why registry-backed prompts matter",
        "Where checked-in skills help contributors move faster"
      ],
      source_notes: [
        %{
          source: "skills-loader",
          insight: "A skills runtime needs to resolve manifests from both modules and file-backed SKILL.md assets without losing provenance."
        },
        %{
          source: "prompt-rendering",
          insight:
            "Registry-backed prompt composition keeps tool permissions and instructions auditable instead of scattering them across ad hoc examples."
        },
        %{
          source: "workbench-guides",
          insight:
            "Checked-in builder skills are most useful when they encode repeatable contributor workflows such as example authoring and ecosystem package page updates."
        }
      ],
      outline: [
        "Manifest loading and provenance",
        "Prompt rendering as a runtime contract",
        "Contributor workflows the workbench can standardize"
      ],
      draft_sections: [
        %{
          heading: "Manifest loading and provenance",
          body:
            "A useful skills runtime does more than find files on disk. It keeps enough metadata to explain where a skill came from, which tools it expects, and how it should be reloaded or versioned."
        },
        %{
          heading: "Prompt rendering as a runtime contract",
          body:
            "When prompts are assembled from a registry of validated skills, the resulting instructions stay inspectable. That makes it easier to reason about tool grants, narrative guidance, and drift between docs and implementation."
        },
        %{
          heading: "Contributor workflows the workbench can standardize",
          body:
            "Builder skills are valuable when they encode the work contributors already repeat: scaffolding agents, creating package pages, and turning source repos into runnable examples with consistent evidence."
        }
      ],
      takeaway: "A good skills runtime keeps provenance, prompt assembly, and contributor workflows aligned."
    }
  ]

  @doc "Returns the deterministic topic catalog for the research studio demos."
  @spec catalog() :: [map()]
  def catalog, do: @topics

  @doc "Returns the default topic id."
  @spec default_topic_id() :: String.t()
  def default_topic_id, do: "elixir-concurrency"

  @doc "Fetches a topic fixture by stable id."
  @spec fetch!(String.t()) :: map()
  def fetch!(id) when is_binary(id) do
    Enum.find(@topics, &(&1.id == id)) ||
      raise ArgumentError, "unknown runic research studio topic id: #{inspect(id)}"
  end

  @doc "Fetches a topic fixture by either stable id or display title."
  @spec fetch_by_topic!(String.t()) :: map()
  def fetch_by_topic!(topic) when is_binary(topic) do
    normalized = normalize(topic)

    Enum.find(@topics, fn entry ->
      normalize(entry.id) == normalized or normalize(entry.title) == normalized
    end) ||
      raise ArgumentError, "unknown runic research studio topic: #{inspect(topic)}"
  end

  defp normalize(value), do: value |> String.downcase() |> String.trim()
end
