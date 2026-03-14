defmodule AgentJido.ContentGen.TwoPass do
  @moduledoc """
  Two-pass ReqLLM pipeline:
  1) Structure pass (planning)
  2) Writing pass (final content)
  """

  alias AgentJido.ContentGen.Backends.ReqLLMBackend
  alias AgentJido.ContentGen.PromptBuilder

  @planner_system_prompt """
  You are a principal technical documentation planner.
  Return only structured JSON for page structure and evidence plan.
  """

  @writer_system_prompt """
  You are a principal technical documentation author.
  Return only JSON with frontmatter/body_markdown/citations/audit_notes.
  """

  @structure_schema [
    frontmatter_plan: [type: :map, required: false, doc: "Frontmatter intentions for writer pass"],
    section_order: [type: {:list, :string}, required: true, doc: "Ordered section headings"],
    section_briefs: [type: :string, required: true, doc: "Section-by-section writing brief"],
    code_plan: [type: :string, required: false, doc: "Expected code block strategy"],
    citation_plan: [type: {:list, :string}, required: false, doc: "Planned module/file citations"],
    consistency_rules: [type: {:list, :string}, required: false, doc: "Rules to preserve voice and consistency"]
  ]

  @spec generate(map(), map(), map(), map(), keyword(), module()) ::
          {:ok, %{text: String.t(), meta: map()}} | {:error, String.t()}
  def generate(entry, target, prompt_opts, backend_decision, backend_opts, backend_module \\ ReqLLMBackend) do
    planner_model = Map.get(backend_decision, :planner_model) || Map.get(backend_decision, :model)
    writer_model = Map.get(backend_decision, :writer_model) || Map.get(backend_decision, :model)
    planner_prompt = PromptBuilder.build_structure_pass(entry, target, prompt_opts)

    case run_structure_pass(
           backend_module,
           planner_prompt,
           backend_opts,
           planner_model,
           writer_model
         ) do
      {:ok, %{object: raw_structure, meta: planner_meta, planner_model_used: planner_model_used}} ->
        case normalize_structure_plan(raw_structure) do
          {:ok, structure_plan} ->
            writer_prompt = PromptBuilder.build_writing_pass(entry, target, prompt_opts, structure_plan)

            writer_opts =
              backend_opts
              |> Keyword.put(:model, writer_model)
              |> Keyword.put(:system_prompt, @writer_system_prompt)
              |> with_generation_defaults(temperature: 0.2)

            case backend_module.generate(writer_prompt, writer_opts) do
              {:ok, %{text: text, meta: writer_meta}} ->
                meta =
                  writer_meta
                  |> Map.merge(%{
                    backend: :req_llm,
                    mode: :two_pass,
                    planner_model: planner_model_used,
                    writer_model: writer_model,
                    planner_meta: planner_meta,
                    structure_plan: structure_plan
                  })

                {:ok, %{text: text, meta: meta}}

              {:error, reason} ->
                {:error, "writing pass failed: #{format_error(reason)}"}
            end

          {:error, reason} ->
            run_single_pass_fallback(
              entry,
              target,
              prompt_opts,
              backend_opts,
              writer_model,
              backend_module,
              "invalid structure response: #{format_error(reason)}"
            )
        end

      {:error, reason} ->
        run_single_pass_fallback(
          entry,
          target,
          prompt_opts,
          backend_opts,
          writer_model,
          backend_module,
          "structure pass failed: #{format_error(reason)}"
        )
    end
  end

  defp run_single_pass_fallback(entry, target, prompt_opts, backend_opts, writer_model, backend_module, reason) do
    prompt = PromptBuilder.build(entry, target, prompt_opts)

    writer_opts =
      backend_opts
      |> Keyword.put(:model, writer_model)
      |> Keyword.put(:system_prompt, @writer_system_prompt)
      |> with_generation_defaults(temperature: 0.2)

    case backend_module.generate(prompt, writer_opts) do
      {:ok, %{text: text, meta: writer_meta}} ->
        meta =
          writer_meta
          |> Map.merge(%{
            backend: :req_llm,
            mode: :single_pass_fallback,
            writer_model: writer_model,
            structure_error: reason
          })

        {:ok, %{text: text, meta: meta}}

      {:error, fallback_reason} ->
        {:error, "#{reason}; single-pass fallback failed: #{format_error(fallback_reason)}"}
    end
  end

  defp run_structure_pass(backend_module, planner_prompt, backend_opts, planner_model, writer_model) do
    planner_opts =
      backend_opts
      |> Keyword.put(:model, planner_model)
      |> Keyword.put(:system_prompt, @planner_system_prompt)
      |> Keyword.put(:output_schema, @structure_schema)
      |> with_generation_defaults(temperature: 0.1)

    case generate_object(backend_module, planner_prompt, planner_opts) do
      {:ok, %{object: _object, meta: _meta} = result} ->
        {:ok, Map.put(result, :planner_model_used, planner_model)}

      {:error, reason} ->
        maybe_retry_structure_with_writer_model(
          backend_module,
          planner_prompt,
          backend_opts,
          planner_model,
          writer_model,
          reason
        )
    end
  end

  defp maybe_retry_structure_with_writer_model(
         backend_module,
         planner_prompt,
         backend_opts,
         planner_model,
         writer_model,
         original_reason
       ) do
    cond do
      planner_model == writer_model ->
        {:error, original_reason}

      not model_not_found?(original_reason) ->
        {:error, original_reason}

      true ->
        fallback_opts =
          backend_opts
          |> Keyword.put(:model, writer_model)
          |> Keyword.put(:system_prompt, @planner_system_prompt)
          |> Keyword.put(:output_schema, @structure_schema)
          |> with_generation_defaults(temperature: 0.1)

        case generate_object(backend_module, planner_prompt, fallback_opts) do
          {:ok, %{object: _object, meta: fallback_meta} = result} ->
            meta =
              fallback_meta
              |> Map.put(:planner_fallback_from, planner_model)
              |> Map.put(:planner_fallback_to, writer_model)

            result
            |> Map.put(:meta, meta)
            |> Map.put(:planner_model_used, writer_model)
            |> then(&{:ok, &1})

          {:error, fallback_reason} ->
            {:error,
             "planner model #{planner_model} returned #{format_error(original_reason)}; " <>
               "fallback #{writer_model} returned #{format_error(fallback_reason)}"}
        end
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

  defp normalize_structure_plan(raw) when is_map(raw) do
    section_order =
      raw
      |> fetch_any([:section_order, "section_order"], [])
      |> List.wrap()
      |> Enum.map(&to_string/1)
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    if section_order == [] do
      {:error, "empty section_order in structure response"}
    else
      {:ok,
       %{
         frontmatter_plan: fetch_any(raw, [:frontmatter_plan, "frontmatter_plan"], %{}),
         section_order: section_order,
         section_briefs: fetch_any(raw, [:section_briefs, "section_briefs"], "") |> to_string(),
         code_plan: fetch_any(raw, [:code_plan, "code_plan"], "") |> to_string(),
         citation_plan:
           raw
           |> fetch_any([:citation_plan, "citation_plan"], [])
           |> List.wrap()
           |> Enum.map(&to_string/1)
           |> Enum.map(&String.trim/1)
           |> Enum.reject(&(&1 == "")),
         consistency_rules:
           raw
           |> fetch_any([:consistency_rules, "consistency_rules"], [])
           |> List.wrap()
           |> Enum.map(&to_string/1)
           |> Enum.map(&String.trim/1)
           |> Enum.reject(&(&1 == ""))
       }}
    end
  end

  defp normalize_structure_plan(_other), do: {:error, "invalid structure response payload"}

  defp fetch_any(map, [key | rest], default) do
    if Map.has_key?(map, key) do
      Map.get(map, key)
    else
      fetch_any(map, rest, default)
    end
  end

  defp fetch_any(_map, [], default), do: default

  defp with_generation_defaults(opts, defaults) when is_list(defaults) do
    generation_opts = opts |> Keyword.get(:generation_opts, []) |> List.wrap()
    Keyword.put(opts, :generation_opts, Keyword.merge(defaults, generation_opts))
  end

  defp model_not_found?(reason) when is_atom(reason), do: reason == :not_found

  defp model_not_found?(reason) when is_binary(reason) do
    normalized = reason |> String.downcase() |> String.trim()

    normalized == "not_found" or
      String.contains?(normalized, "not found") or
      String.contains?(normalized, "not_found")
  end

  defp model_not_found?(%{__exception__: true} = error), do: model_not_found?(Exception.message(error))
  defp model_not_found?(reason), do: model_not_found?(inspect(reason))

  defp format_error(%{__exception__: true} = error), do: Exception.message(error)
  defp format_error(error) when is_binary(error), do: error
  defp format_error(error) when is_atom(error), do: Atom.to_string(error)
  defp format_error(error), do: inspect(error)
end
