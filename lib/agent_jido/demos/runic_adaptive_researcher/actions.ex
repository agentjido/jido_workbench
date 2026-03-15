defmodule AgentJido.Demos.RunicAdaptiveResearcher.Actions do
  @moduledoc """
  Deterministic Runic action nodes for the adaptive researcher example.
  """

  alias AgentJido.Demos.RunicAdaptiveResearcher.Fixtures

  defmodule PlanQueries do
    @moduledoc "Builds the deterministic research query set for the selected topic."

    use Jido.Action,
      name: "runic_adaptive_researcher_plan_queries",
      description: "Plans deterministic research queries for the adaptive researcher topic",
      schema: [
        topic: [type: :string, required: true]
      ]

    @impl true
    def run(%{topic: topic}, _context) do
      fixture = Fixtures.fetch_by_topic!(topic)

      {:ok,
       %{
         topic: fixture.title,
         topic_id: fixture.id,
         queries: fixture.queries
       }}
    end
  end

  defmodule SimulateSearch do
    @moduledoc "Returns deterministic research notes and summary richness."

    use Jido.Action,
      name: "runic_adaptive_researcher_simulate_search",
      description: "Builds deterministic source notes and research summary for adaptive phase selection",
      schema: [
        topic: [type: :string, required: true],
        topic_id: [type: :string, required: true],
        queries: [type: {:list, :string}, required: true]
      ]

    @impl true
    def run(%{topic: topic, topic_id: topic_id, queries: queries}, _context) do
      fixture = Fixtures.fetch!(topic_id)

      {:ok,
       %{
         topic: topic,
         topic_id: topic_id,
         queries: queries,
         source_notes: fixture.source_notes,
         research_summary: fixture.research_summary,
         summary_length: String.length(fixture.research_summary)
       }}
    end
  end

  defmodule BuildOutline do
    @moduledoc "Builds the outline for the richer adaptive branch."

    use Jido.Action,
      name: "runic_adaptive_researcher_build_outline",
      description: "Builds the deterministic outline for richer research results",
      schema: [
        topic: [type: :string, required: true],
        topic_id: [type: :string, required: true],
        research_summary: [type: :string, required: true],
        source_notes: [type: :any, required: true]
      ]

    @impl true
    def run(%{topic: topic, topic_id: topic_id, research_summary: research_summary, source_notes: source_notes}, _context) do
      fixture = Fixtures.fetch!(topic_id)

      {:ok,
       %{
         topic: topic,
         topic_id: topic_id,
         research_summary: research_summary,
         source_notes: source_notes,
         outline: fixture.outline
       }}
    end
  end

  defmodule DraftArticle do
    @moduledoc "Builds the draft article for either the full or slim phase-2 workflow."

    use Jido.Action,
      name: "runic_adaptive_researcher_draft_article",
      description: "Builds a deterministic draft from either an outline or a short research summary",
      schema: [
        topic: [type: :string, required: true],
        topic_id: [type: :string, required: true],
        source_notes: [type: :any, required: true],
        research_summary: [type: :string, required: false],
        outline: [type: {:list, :string}, required: false]
      ]

    @impl true
    def run(%{topic: topic, topic_id: topic_id, source_notes: source_notes} = params, _context) do
      fixture = Fixtures.fetch!(topic_id)
      outline = Map.get(params, :outline, [])

      sections =
        case outline do
          [] -> Enum.take(fixture.draft_sections, 2)
          _ -> fixture.draft_sections
        end

      draft_markdown =
        [
          "# #{topic}",
          ""
        ] ++
          Enum.flat_map(sections, fn section ->
            ["## #{section.heading}", "", section.body, ""]
          end)

      {:ok,
       %{
         topic: topic,
         topic_id: topic_id,
         source_notes: source_notes,
         outline: outline,
         research_summary: Map.get(params, :research_summary, fixture.research_summary),
         draft_markdown: Enum.join(draft_markdown, "\n")
       }}
    end
  end

  defmodule EditAndAssemble do
    @moduledoc "Builds the final article artifact for the adaptive example."

    use Jido.Action,
      name: "runic_adaptive_researcher_edit_and_assemble",
      description: "Finishes the deterministic adaptive article artifact with citations and phase metadata",
      schema: [
        topic: [type: :string, required: true],
        topic_id: [type: :string, required: true],
        source_notes: [type: :any, required: true],
        draft_markdown: [type: :string, required: true]
      ]

    @impl true
    def run(%{topic: topic, topic_id: topic_id, source_notes: source_notes, draft_markdown: draft_markdown}, _context) do
      fixture = Fixtures.fetch!(topic_id)

      citations =
        source_notes
        |> Enum.map_join("\n", fn note -> "- #{note.source}: #{note.insight}" end)

      article_markdown =
        [
          draft_markdown,
          "## Research Sources",
          "",
          citations,
          "",
          "## Takeaway",
          "",
          fixture.takeaway
        ]
        |> Enum.join("\n")

      {:ok,
       %{
         topic: topic,
         topic_id: topic_id,
         article_markdown: article_markdown,
         takeaway: fixture.takeaway
       }}
    end
  end
end
