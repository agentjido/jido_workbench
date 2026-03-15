defmodule AgentJido.Demos.OperationalAgentsPack.Catalog do
  @moduledoc """
  Deterministic catalog for the operational agents pack overview page.

  This page is intentionally an index, not a runnable "one pack does everything"
  demo. It links to narrower deterministic examples that already exist in the
  workbench and preserves upstream source references for the original Jido.AI
  operational agents.
  """

  alias AgentJido.Examples

  @local_entries [
    %{
      id: "task-execution",
      slug: "jido-ai-task-execution-workflow",
      operational_focus: "Release lifecycle coordination",
      why: "Use this when you want a deterministic stand-in for release or handoff workflows with explicit task state transitions.",
      capabilities: ["task seeding", "task start/complete", "workflow lifecycle", "operator-friendly state view"]
    },
    %{
      id: "schedule-directive",
      slug: "schedule-directive-agent",
      operational_focus: "Scheduled follow-up and remediation",
      why: "Use this when operational work needs delayed follow-up, reminders, or retry windows instead of immediate execution.",
      capabilities: ["schedule directives", "future dispatch", "safe deferred work", "operational timing control"]
    },
    %{
      id: "persistence-storage",
      slug: "persistence-storage-agent",
      operational_focus: "Durable state and recovery",
      why: "Use this when the operational workflow must survive restarts and preserve agent state across runs.",
      capabilities: ["durable storage", "state inspection", "restart continuity", "recovery-friendly demos"]
    }
  ]

  @upstream_refs [
    %{
      id: "api-smoke-test",
      title: "API Smoke Test Agent",
      label: "api smoke test agent",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/agents/api_smoke_test_agent.ex",
      description: "ReAct-driven API endpoint testing and debugging.",
      focus: "external verification and endpoint diagnostics"
    },
    %{
      id: "issue-triage",
      title: "Issue Triage Agent",
      label: "issue triage agent",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/agents/issue_triage_agent.ex",
      description: "Secure token injection pattern and safe GitHub operations.",
      focus: "triage workflows and safe repo automation"
    },
    %{
      id: "release-notes",
      title: "Release Notes Agent",
      label: "release notes agent",
      href: "https://github.com/agentjido/jido_ai/blob/main/lib/examples/agents/release_notes_agent.ex",
      description: "Graph-of-Thoughts synthesis for release note generation.",
      focus: "structured release synthesis and editorial review"
    }
  ]

  @type local_entry :: %{
          required(:id) => String.t(),
          required(:slug) => String.t(),
          required(:title) => String.t(),
          required(:route) => String.t(),
          required(:description) => String.t(),
          required(:difficulty) => atom(),
          required(:demo_mode) => atom(),
          required(:source_files) => [String.t()],
          required(:operational_focus) => String.t(),
          required(:why) => String.t(),
          required(:capabilities) => [String.t()]
        }

  @type upstream_ref :: %{
          required(:id) => String.t(),
          required(:title) => String.t(),
          required(:label) => String.t(),
          required(:href) => String.t(),
          required(:description) => String.t(),
          required(:focus) => String.t()
        }

  @doc "Returns the local deterministic examples this index promotes."
  @spec local_entries() :: [local_entry()]
  def local_entries do
    Enum.map(@local_entries, fn entry ->
      example = Examples.get_example!(entry.slug)

      entry
      |> Map.put(:title, example.title)
      |> Map.put(:route, "/examples/#{example.slug}")
      |> Map.put(:description, example.description)
      |> Map.put(:difficulty, example.difficulty)
      |> Map.put(:demo_mode, example.demo_mode)
      |> Map.put(:source_files, example.source_files)
    end)
  end

  @doc "Returns the upstream operational source references preserved from the original page."
  @spec upstream_refs() :: [upstream_ref()]
  def upstream_refs, do: @upstream_refs

  @doc "Returns the default local example entry."
  @spec default_local_entry() :: local_entry()
  def default_local_entry do
    local_entries() |> List.first()
  end

  @doc "Fetches one local entry by id or raises."
  @spec local_entry!(String.t()) :: local_entry()
  def local_entry!(id) when is_binary(id) do
    Enum.find(local_entries(), &(&1.id == id)) ||
      raise ArgumentError, "unknown operational catalog entry: #{inspect(id)}"
  end
end
