defmodule AgentJido.Demos.RunicResearchStudio.Actions do
  @moduledoc """
  Deterministic Runic action nodes for the research studio examples.
  """

  alias AgentJido.Demos.RunicResearchStudio.Fixtures

  defmodule PlanQueries do
    @moduledoc "Build a deterministic research query set for the chosen topic."

    use Jido.Action,
      name: "runic_research_studio_plan_queries",
      description: "Plans deterministic research queries for the selected topic",
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
         queries: fixture.queries,
         outline_seed: fixture.outline_seed
       }}
    end
  end

  defmodule SimulateSearch do
    @moduledoc "Return deterministic research notes for the planned queries."

    use Jido.Action,
      name: "runic_research_studio_simulate_search",
      description: "Builds deterministic source notes and research summary for the topic",
      schema: [
        topic: [type: :string, required: true],
        queries: [type: {:list, :string}, required: true]
      ]

    @impl true
    def run(%{topic: topic, queries: queries}, _context) do
      fixture = Fixtures.fetch_by_topic!(topic)

      research_summary =
        fixture.source_notes
        |> Enum.map_join("\n\n", fn note ->
          "#{note.source}: #{note.insight}"
        end)

      {:ok,
       %{
         topic: fixture.title,
         topic_id: fixture.id,
         queries: queries,
         source_notes: fixture.source_notes,
         research_summary: research_summary
       }}
    end
  end

  defmodule BuildOutline do
    @moduledoc "Assemble the deterministic article outline from research notes."

    use Jido.Action,
      name: "runic_research_studio_build_outline",
      description: "Builds a deterministic article outline from the research notes",
      schema: [
        topic: [type: :string, required: true],
        research_summary: [type: :string, required: true],
        source_notes: [type: :any, required: true]
      ]

    @impl true
    def run(%{topic: topic, research_summary: research_summary, source_notes: source_notes}, _context) do
      fixture = Fixtures.fetch_by_topic!(topic)

      {:ok,
       %{
         topic: fixture.title,
         topic_id: fixture.id,
         research_summary: research_summary,
         source_notes: source_notes,
         outline: fixture.outline
       }}
    end
  end

  defmodule DraftArticle do
    @moduledoc "Draft a deterministic markdown article from the final outline."

    use Jido.Action,
      name: "runic_research_studio_draft_article",
      description: "Builds a deterministic article draft from outline sections",
      schema: [
        topic: [type: :string, required: true],
        outline: [type: {:list, :string}, required: true],
        source_notes: [type: :any, required: true]
      ]

    @impl true
    def run(%{topic: topic, outline: outline, source_notes: source_notes}, _context) do
      fixture = Fixtures.fetch_by_topic!(topic)

      draft_markdown =
        [
          "# #{fixture.title}",
          ""
        ] ++
          Enum.flat_map(fixture.draft_sections, fn section ->
            ["## #{section.heading}", "", section.body, ""]
          end)

      {:ok,
       %{
         topic: fixture.title,
         topic_id: fixture.id,
         outline: outline,
         source_notes: source_notes,
         draft_markdown: Enum.join(draft_markdown, "\n")
       }}
    end
  end

  defmodule EditAndAssemble do
    @moduledoc "Apply the final editorial pass and return the published article artifact."

    use Jido.Action,
      name: "runic_research_studio_edit_and_assemble",
      description: "Finishes the deterministic article artifact with citations and a takeaway",
      schema: [
        topic: [type: :string, required: true],
        draft_markdown: [type: :string, required: true],
        source_notes: [type: :any, required: true]
      ]

    @impl true
    def run(%{topic: topic, draft_markdown: draft_markdown, source_notes: source_notes}, _context) do
      fixture = Fixtures.fetch_by_topic!(topic)

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
         topic: fixture.title,
         topic_id: fixture.id,
         article_title: fixture.title,
         article_markdown: article_markdown,
         takeaway: fixture.takeaway
       }}
    end
  end
end
