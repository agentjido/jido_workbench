defmodule AgentJido.ContentGen.Actions.GenerateStructurePlan do
  @moduledoc false

  use Jido.Action,
    name: "content_gen_generate_structure_plan",
    description: "Generates structured page plan via fixed planner model"

  alias AgentJido.ContentGen.Actions.Helpers
  alias AgentJido.ContentGen.Contract
  alias AgentJido.ContentGen.ModelRouter
  alias AgentJido.ContentGen.PromptBuilder
  alias AgentJido.ContentGen.Prompts

  @impl true
  def run(%{halted?: true} = context, _runtime_context), do: {:ok, context}

  def run(%{update_mode: :audit_only} = context, _runtime_context), do: {:ok, context}

  def run(context, _runtime_context) do
    backend_decision = ModelRouter.choose(context.entry, context.target, context.opts)
    backend_module = Helpers.backend_module(backend_decision.backend, context.opts)
    prompt_opts = Helpers.generation_prompt_opts(context.existing, context.opts)
    prompt = PromptBuilder.build_structure_pass(context.entry, context.target, prompt_opts)

    backend_opts =
      backend_decision.planner_model
      |> Helpers.build_backend_opts(context.opts)
      |> Keyword.put(:system_prompt, Prompts.system_prompt(:planner))
      |> Keyword.put(:output_schema, Helpers.structure_schema())
      |> with_generation_defaults(temperature: 0.1)

    case generate_object(backend_module, prompt, backend_opts) do
      {:ok, %{object: raw_structure, meta: planner_meta}} ->
        case Helpers.normalize_structure_plan(raw_structure) do
          {:ok, structure_plan} ->
            {:ok,
             context
             |> Map.put(:backend_decision, backend_decision)
             |> Map.put(:backend_module, backend_module)
             |> Map.put(:prompt_opts, prompt_opts)
             |> Map.put(:planner_meta, planner_meta)
             |> Map.put(:structure_plan, structure_plan)}

          {:error, reason} ->
            case fallback_structure_plan(raw_structure, context.entry, context.target) do
              {:ok, fallback_plan} ->
                {:ok,
                 context
                 |> Map.put(:backend_decision, backend_decision)
                 |> Map.put(:backend_module, backend_module)
                 |> Map.put(:prompt_opts, prompt_opts)
                 |> Map.put(:planner_meta, Map.put(planner_meta || %{}, :structure_fallback, reason))
                 |> Map.put(:structure_plan, fallback_plan)}

              {:error, fallback_reason} ->
                failed =
                  context
                  |> Map.put(:backend_decision, backend_decision)
                  |> Map.put(:backend_module, backend_module)
                  |> Helpers.halt_with_entry_result(
                    :generation_failed,
                    "invalid structure response: #{reason}; fallback failed: #{fallback_reason}",
                    "generate_structure_plan"
                  )

                {:ok, failed}
            end
        end

      {:error, reason} ->
        planner_model = backend_decision.planner_model || "unknown"

        failed =
          context
          |> Map.put(:backend_decision, backend_decision)
          |> Map.put(:backend_module, backend_module)
          |> Helpers.halt_with_entry_result(
            :generation_failed,
            "structure pass failed for planner model #{planner_model}: #{format_error(reason)}",
            "generate_structure_plan"
          )

        {:ok, failed}
    end
  end

  defp generate_object(backend_module, prompt, opts) do
    case Code.ensure_loaded(backend_module) do
      {:module, ^backend_module} ->
        if function_exported?(backend_module, :generate_object, 2) do
          backend_module.generate_object(prompt, opts)
        else
          {:error, "backend #{inspect(backend_module)} does not support structured-object generation"}
        end

      {:error, reason} ->
        {:error, "backend #{inspect(backend_module)} could not be loaded: #{inspect(reason)}"}
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

  defp fallback_structure_plan(raw_structure, entry, target) when is_map(raw_structure) do
    contract = Contract.contract(entry, target)

    section_order =
      extract_any(raw_structure, [:section_order, "section_order"], contract.required_sections)
      |> List.wrap()
      |> Enum.map(&extract_section_heading/1)
      |> Enum.reject(&is_nil/1)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
      |> case do
        [] -> contract.required_sections
        value -> value
      end

    if section_order == [] do
      {:error, "no section order available from planner response or contract"}
    else
      {:ok,
       %{
         frontmatter_plan: extract_any(raw_structure, [:frontmatter_plan, "frontmatter_plan"], %{}),
         section_order: section_order,
         section_briefs: extract_any(raw_structure, [:section_briefs, "section_briefs"], "") |> fallback_section_briefs(section_order),
         code_plan: extract_any(raw_structure, [:code_plan, "code_plan"], "") |> to_string(),
         citation_plan:
           extract_any(raw_structure, [:citation_plan, "citation_plan"], [])
           |> List.wrap()
           |> Enum.map(&stringify_value/1)
           |> Enum.map(&String.trim/1)
           |> Enum.reject(&(&1 == "")),
         consistency_rules:
           extract_any(raw_structure, [:consistency_rules, "consistency_rules"], [])
           |> List.wrap()
           |> Enum.map(&stringify_value/1)
           |> Enum.map(&String.trim/1)
           |> Enum.reject(&(&1 == ""))
       }}
    end
  end

  defp fallback_structure_plan(_raw_structure, _entry, _target), do: {:error, "planner response was not a map"}

  defp fallback_section_briefs(value, _section_order) when is_binary(value) and value != "", do: value

  defp fallback_section_briefs(_value, section_order) do
    section_order
    |> Enum.map_join("\n", fn section -> "#{section}: cover concrete implementation details and verification guidance." end)
  end

  defp extract_any(map, [key | rest], default) do
    if Map.has_key?(map, key) do
      Map.get(map, key)
    else
      extract_any(map, rest, default)
    end
  end

  defp extract_any(_map, [], default), do: default

  defp extract_section_heading(value) when is_binary(value), do: value
  defp extract_section_heading(value) when is_atom(value), do: Atom.to_string(value)
  defp extract_section_heading(value) when is_integer(value) or is_float(value), do: to_string(value)

  defp extract_section_heading(value) when is_map(value) do
    value
    |> extract_any([:heading, "heading", :title, "title", :name, "name", :section, "section"], nil)
    |> case do
      nil -> nil
      heading -> stringify_value(heading)
    end
  end

  defp extract_section_heading(_), do: nil

  defp stringify_value(value) when is_binary(value), do: value
  defp stringify_value(value) when is_atom(value), do: Atom.to_string(value)
  defp stringify_value(value) when is_integer(value) or is_float(value), do: to_string(value)

  defp stringify_value(value) when is_map(value) do
    value
    |> extract_any([:text, "text", :rule, "rule", :description, "description", :content, "content"], nil)
    |> case do
      nil -> inspect(value)
      extracted -> stringify_value(extracted)
    end
  end

  defp stringify_value(value), do: inspect(value)
end
