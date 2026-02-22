defmodule AgentJido.ContentGen.Actions.GenerateDraftEnvelope do
  @moduledoc false

  use Jido.Action,
    name: "content_gen_generate_draft_envelope",
    description: "Generates final draft envelope via fixed writer model"

  alias AgentJido.ContentGen.Actions.Helpers
  alias AgentJido.ContentGen.PromptBuilder
  alias AgentJido.ContentGen.Prompts

  @impl true
  def run(%{halted?: true} = context, _runtime_context), do: {:ok, context}

  def run(%{update_mode: :audit_only} = context, _runtime_context), do: {:ok, context}

  def run(%{backend_decision: nil} = context, _runtime_context) do
    failed =
      Helpers.halt_with_entry_result(
        context,
        :generation_failed,
        "backend decision missing before writer pass",
        "generate_draft_envelope"
      )

    {:ok, failed}
  end

  def run(context, _runtime_context) do
    prompt_opts = context.prompt_opts || Helpers.generation_prompt_opts(context.existing, context.opts)

    prompt =
      PromptBuilder.build_writing_pass(
        context.entry,
        context.target,
        prompt_opts,
        context.structure_plan || %{}
      )

    backend_opts =
      context.backend_decision.writer_model
      |> Helpers.build_backend_opts(context.opts)
      |> Keyword.put(:system_prompt, Prompts.system_prompt(:writer))
      |> with_generation_defaults(temperature: 0.2)

    case context.backend_module.generate(prompt, backend_opts) do
      {:ok, %{text: text, meta: writer_meta}} ->
        backend_meta =
          writer_meta
          |> Map.merge(%{
            backend: :req_llm,
            mode: :two_pass,
            planner_model: context.backend_decision.planner_model,
            writer_model: context.backend_decision.writer_model,
            planner_meta: context.planner_meta,
            structure_plan: context.structure_plan
          })

        {:ok,
         context
         |> Map.put(:generated_text, text)
         |> Map.put(:backend_meta, backend_meta)}

      {:error, reason} ->
        writer_model = context.backend_decision.writer_model || "unknown"

        failed =
          Helpers.halt_with_entry_result(
            context,
            :generation_failed,
            "writing pass failed for writer model #{writer_model}: #{format_error(reason)}",
            "generate_draft_envelope"
          )

        {:ok, failed}
    end
  end

  defp with_generation_defaults(opts, defaults) when is_list(defaults) do
    generation_opts = opts |> Keyword.get(:generation_opts, []) |> List.wrap()
    Keyword.put(opts, :generation_opts, Keyword.merge(defaults, generation_opts))
  end

  defp format_error(%{__exception__: true} = error), do: Exception.message(error)
  defp format_error(error) when is_binary(error), do: error
  defp format_error(error) when is_atom(error), do: Atom.to_string(error)
  defp format_error(error), do: inspect(error)
end
