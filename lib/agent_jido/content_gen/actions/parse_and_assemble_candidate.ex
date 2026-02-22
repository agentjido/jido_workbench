defmodule AgentJido.ContentGen.Actions.ParseAndAssembleCandidate do
  @moduledoc false

  use Jido.Action,
    name: "content_gen_parse_and_assemble_candidate",
    description: "Parses backend output and assembles candidate page content"

  alias AgentJido.ContentGen.Actions.Helpers
  alias AgentJido.ContentGen.OutputParser
  alias AgentJido.ContentGen.Writer

  @impl true
  def run(%{halted?: true} = context, _runtime_context), do: {:ok, context}

  def run(%{update_mode: :audit_only} = context, _runtime_context) do
    candidate = %{
      frontmatter: (context.existing && context.existing.frontmatter) || %{},
      body_markdown: (context.existing && context.existing.body) || "",
      raw: (context.existing && context.existing.raw) || "",
      citations: [],
      audit_notes: []
    }

    candidate_path =
      Helpers.write_candidate_artifact(context.run_dir, context.entry, context.target.format, candidate.raw)

    diff = Helpers.diff_stats(Helpers.existing_raw(context.existing), candidate.raw)

    {:ok,
     context
     |> Map.put(:candidate, candidate)
     |> Map.put(:candidate_path, candidate_path)
     |> Map.put(:diff, diff)
     |> Map.put(:parse_mode, :json)}
  end

  def run(context, _runtime_context) do
    text = to_string(context.generated_text || "")

    case OutputParser.parse(text) do
      {:error, reason} ->
        failed =
          context
          |> Map.put(:output_excerpt, String.slice(text, 0, 1_200))
          |> Helpers.halt_with_entry_result(:parse_failed, reason, "parse_and_assemble_candidate")

        {:ok, failed}

      {:ok, envelope} ->
        if Helpers.strict_json_required?(context) and envelope.parse_mode != :json do
          failed =
            context
            |> Map.put(:output_excerpt, String.slice(text, 0, 1_200))
            |> Helpers.halt_with_entry_result(
              :parse_failed,
              "strict mode requires JSON envelope output (received #{envelope.parse_mode})",
              "parse_and_assemble_candidate"
            )

          {:ok, failed}
        else
          body_markdown = Helpers.enrich_body_for_audit(envelope.body_markdown, context.entry)

          merged_frontmatter =
            Writer.merge_frontmatter(
              context.existing && context.existing.frontmatter,
              envelope.frontmatter,
              context.entry,
              context.target.route
            )

          rendered = Writer.render_file(merged_frontmatter, body_markdown)

          candidate = %{
            frontmatter: merged_frontmatter,
            body_markdown: body_markdown,
            raw: rendered,
            citations: envelope.citations,
            audit_notes: envelope.audit_notes
          }

          candidate_path =
            Helpers.write_candidate_artifact(context.run_dir, context.entry, context.target.format, rendered)

          diff = Helpers.diff_stats(Helpers.existing_raw(context.existing), rendered)

          {:ok,
           context
           |> Map.put(:parse_mode, envelope.parse_mode)
           |> Map.put(:candidate, candidate)
           |> Map.put(:candidate_path, candidate_path)
           |> Map.put(:diff, diff)}
        end
    end
  end
end
