defmodule AgentJido.ContentGen.Run do
  @moduledoc """
  Orchestrates one content generation run from content-plan entries.

  This runner is review-first:
  - dry-run by default
  - deep audit before writes
  - idempotent no-op and churn guards
  """

  alias AgentJido.ContentGen
  alias AgentJido.ContentGen.Audit.ContentAuditor
  alias AgentJido.ContentGen.Audit.SourceIndex
  alias AgentJido.ContentGen.Backends.CodexCLI
  alias AgentJido.ContentGen.Backends.ReqLLMBackend
  alias AgentJido.ContentGen.ModelRouter
  alias AgentJido.ContentGen.OutputParser
  alias AgentJido.ContentGen.PathResolver
  alias AgentJido.ContentGen.PromptBuilder
  alias AgentJido.ContentGen.Report
  alias AgentJido.ContentGen.Selection
  alias AgentJido.ContentGen.Writer
  alias AgentJido.ContentPlan
  alias AgentJido.Release.LinkAudit

  @backend_modules %{
    codex: CodexCLI,
    req_llm: ReqLLMBackend
  }

  @type run_result :: {:ok, map()} | {:error, map()}

  @spec run(map()) :: run_result()
  def run(opts \\ %{}) when is_map(opts) do
    run_id = get_opt(opts, :run_id, default_run_id())
    run_dir = ContentGen.run_dir(run_id)
    report_path = get_opt(opts, :report, Path.join(run_dir, "report.json"))
    source_root = get_opt(opts, :source_root, "..")
    apply? = get_opt(opts, :apply, false)
    fail_on_audit = get_opt(opts, :fail_on_audit, true)

    :ok = File.mkdir_p(Path.join(run_dir, "candidates"))

    entries = get_opt(opts, :entries, ContentPlan.all_entries())
    selected = Selection.select(opts, entries)
    page_index = get_opt(opts, :page_index, PathResolver.page_index())
    route_patterns = get_opt(opts, :route_patterns, LinkAudit.route_patterns())
    source_index = get_opt(opts, :source_index, SourceIndex.build(source_root: source_root))

    report =
      Report.new(run_id, opts)
      |> Report.put_selected(length(selected))
      |> Map.put(:run_dir, run_dir)
      |> Map.put(:report_path, report_path)
      |> Map.put(:source_index_summary, source_index_summary(source_index))

    context = %{
      opts: opts,
      apply?: apply?,
      fail_on_audit: fail_on_audit,
      run_dir: run_dir,
      page_index: page_index,
      route_patterns: route_patterns,
      source_index: source_index
    }

    report =
      Enum.reduce(selected, report, fn entry, acc ->
        acc
        |> Report.add_entry(process_entry(entry, context))
      end)
      |> Report.finalize()

    case Report.write(report, report_path) do
      :ok ->
        if blocking_failures?(report, apply?, fail_on_audit) do
          {:error, report}
        else
          {:ok, report}
        end

      {:error, reason} ->
        {:error, Map.put(report, :report_write_error, reason)}
    end
  end

  defp process_entry(entry, context) do
    case PathResolver.resolve(entry, page_index: context.page_index) do
      {:skip, :skipped_non_file_target, payload} ->
        %{
          id: entry.id,
          section: entry.section,
          route: payload.route,
          status: :skipped_non_file_target,
          reason: "non-file-backed route in v1"
        }

      {:ok, target} ->
        process_file_target(entry, target, context)
    end
  end

  defp process_file_target(entry, target, context) do
    existing =
      case Writer.read_existing(target.target_path) do
        {:ok, parsed} -> parsed
        :missing -> nil
        {:error, reason} -> {:error, reason}
      end

    case existing do
      {:error, reason} ->
        base_entry_result(entry, target, nil, context)
        |> Map.merge(%{
          status: :generation_failed,
          reason: reason
        })

      _existing ->
        update_mode = Map.get(context.opts, :update_mode, :improve)

        if update_mode == :audit_only do
          process_audit_only(entry, target, existing, context)
        else
          process_generate(entry, target, existing, context)
        end
    end
  end

  defp process_audit_only(entry, target, nil, context) do
    base_entry_result(entry, target, nil, context)
    |> Map.merge(%{
      status: :skipped_missing_for_audit,
      reason: "audit_only requires an existing target file"
    })
  end

  defp process_audit_only(entry, target, existing, context) do
    candidate = %{
      frontmatter: existing.frontmatter || %{},
      body_markdown: existing.body || "",
      raw: existing.raw || "",
      citations: [],
      audit_notes: []
    }

    audit =
      ContentAuditor.audit(entry, target, candidate,
        source_index: context.source_index,
        route_patterns: context.route_patterns
      )

    candidate_path = write_candidate_artifact(context.run_dir, entry, target.format, candidate.raw)

    status = if audit.errors == [], do: :audit_only_passed, else: :audit_failed

    base_entry_result(entry, target, existing, context)
    |> Map.merge(%{
      status: status,
      reason: "audit_only",
      audit: audit,
      diff: diff_stats(existing.raw, candidate.raw),
      citations: candidate.citations,
      audit_notes: candidate.audit_notes,
      content_hash: content_hash(candidate.raw),
      candidate_path: candidate_path
    })
  end

  defp process_generate(entry, target, existing, context) do
    backend_decision = ModelRouter.choose(entry, target, context.opts)
    backend = backend_module(backend_decision.backend, context.opts)
    prompt = PromptBuilder.build(entry, target, generation_prompt_opts(existing, context.opts))

    backend_opts = build_backend_opts(backend_decision.model, context.opts)

    case backend.generate(prompt, backend_opts) do
      {:error, reason} ->
        base_entry_result(entry, target, existing, context)
        |> Map.merge(%{
          backend: backend_decision.backend,
          model: backend_decision.model,
          backend_reason: backend_decision.reason,
          status: :generation_failed,
          reason: to_string(reason)
        })

      {:ok, %{text: text, meta: backend_meta}} ->
        process_backend_output(entry, target, existing, backend_decision, backend_meta, text, context)
    end
  end

  defp process_backend_output(entry, target, existing, backend_decision, backend_meta, text, context) do
    case OutputParser.parse(text) do
      {:error, reason} ->
        base_entry_result(entry, target, existing, context)
        |> Map.merge(%{
          backend: backend_decision.backend,
          model: backend_decision.model,
          backend_reason: backend_decision.reason,
          backend_meta: backend_meta,
          status: :parse_failed,
          reason: reason,
          output_excerpt: String.slice(text || "", 0, 1_200)
        })

      {:ok, envelope} ->
        body_markdown = enrich_body_for_audit(envelope.body_markdown, entry)

        merged_frontmatter =
          Writer.merge_frontmatter(
            existing && existing.frontmatter,
            envelope.frontmatter,
            entry,
            target.route
          )

        rendered = Writer.render_file(merged_frontmatter, body_markdown)

        candidate = %{
          frontmatter: merged_frontmatter,
          body_markdown: body_markdown,
          raw: rendered,
          citations: envelope.citations,
          audit_notes: envelope.audit_notes
        }

        audit =
          ContentAuditor.audit(entry, target, candidate,
            source_index: context.source_index,
            route_patterns: context.route_patterns
          )

        candidate_path = write_candidate_artifact(context.run_dir, entry, target.format, rendered)
        audit_errors = length(audit.errors)

        entry_result =
          base_entry_result(entry, target, existing, context)
          |> Map.merge(%{
            backend: backend_decision.backend,
            model: backend_decision.model,
            backend_reason: backend_decision.reason,
            backend_meta: backend_meta,
            audit: audit,
            diff: diff_stats(existing_raw(existing), rendered),
            citations: candidate.citations,
            audit_notes: candidate.audit_notes,
            content_hash: content_hash(rendered),
            candidate_path: candidate_path
          })

        churn_result = Writer.churn_guard(existing, rendered, audit_errors)

        cond do
          context.fail_on_audit and audit_errors > 0 ->
            Map.merge(entry_result, %{status: :audit_failed, reason: "audit gates failed"})

          match?({:error, _}, churn_result) ->
            {:error, reason} = churn_result
            Map.merge(entry_result, %{status: :churn_blocked, reason: reason})

          Writer.noop?(existing_raw(existing), rendered) ->
            Map.merge(entry_result, %{status: :skipped_noop, reason: "generated output matches existing content"})

          context.apply? ->
            case Writer.write(target.target_path, rendered) do
              :ok ->
                Map.merge(entry_result, %{status: :written, reason: "applied to target"})

              {:error, reason} ->
                Map.merge(entry_result, %{status: :generation_failed, reason: reason})
            end

          true ->
            Map.merge(entry_result, %{status: :dry_run_candidate, reason: "dry-run (not applied)"})
        end
    end
  end

  defp generation_prompt_opts(existing, opts) do
    update_mode = Map.get(opts, :update_mode, :improve)

    %{
      update_mode: update_mode,
      existing: if(update_mode == :improve, do: existing, else: nil)
    }
  end

  defp build_backend_opts(model, opts) do
    base_opts =
      [cwd: File.cwd!()]
      |> maybe_put_model(model)

    opts
    |> Map.get(:backend_opts, [])
    |> case do
      backend_opts when is_list(backend_opts) -> Keyword.merge(base_opts, backend_opts)
      _other -> base_opts
    end
  end

  defp maybe_put_model(opts, model) when is_binary(model) and model != "", do: Keyword.put(opts, :model, model)
  defp maybe_put_model(opts, _model), do: opts

  defp backend_module(backend_key, opts) do
    modules = Map.merge(@backend_modules, Map.get(opts, :backend_modules, %{}))

    case Map.fetch(modules, backend_key) do
      {:ok, module} -> module
      :error -> raise ArgumentError, "no backend configured for #{inspect(backend_key)}"
    end
  end

  defp base_entry_result(entry, target, existing, context) do
    %{
      id: entry.id,
      title: entry.title,
      section: entry.section,
      order: entry.order,
      route: target.route,
      target_path: target.target_path,
      format: target.format,
      existed_before: not is_nil(existing),
      update_mode: Map.get(context.opts, :update_mode, :improve),
      status: :unknown
    }
  end

  defp existing_raw(nil), do: nil
  defp existing_raw(%{raw: raw}) when is_binary(raw), do: raw
  defp existing_raw(_existing), do: nil

  defp diff_stats(old, new) do
    old = old || ""
    new = new || ""

    %{
      changed: normalize_for_diff(old) != normalize_for_diff(new),
      old_bytes: byte_size(old),
      new_bytes: byte_size(new),
      delta_bytes: byte_size(new) - byte_size(old),
      old_lines: line_count(old),
      new_lines: line_count(new),
      delta_lines: line_count(new) - line_count(old)
    }
  end

  defp normalize_for_diff(text) do
    text
    |> String.split("\n")
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.join("\n")
    |> String.trim()
  end

  defp line_count(text) when text in ["", nil], do: 0
  defp line_count(text), do: text |> String.split("\n") |> length()

  defp content_hash(raw) when is_binary(raw) do
    :sha256
    |> :crypto.hash(raw)
    |> Base.encode16(case: :lower)
  end

  defp content_hash(_raw), do: nil

  defp write_candidate_artifact(run_dir, entry, format, raw) do
    ext = if format == :livemd, do: "livemd", else: "md"
    filename = String.replace(entry.id, "/", "__") <> ".#{ext}"
    path = Path.join([run_dir, "candidates", filename])

    :ok = File.mkdir_p(Path.dirname(path))
    :ok = File.write(path, raw || "")
    path
  rescue
    _ -> nil
  end

  defp source_index_summary(source_index) do
    %{
      package_paths: Map.get(source_index, :package_paths, %{}),
      scanned_files: Map.get(source_index, :scanned_files, 0),
      module_count: source_index |> Map.get(:modules, MapSet.new()) |> MapSet.size(),
      export_count: source_index |> Map.get(:exports, MapSet.new()) |> MapSet.size()
    }
  end

  defp blocking_failures?(report, apply?, fail_on_audit) do
    stats = report.stats || %{}

    generation_or_parse_failed? = (stats.generation_failed || 0) > 0 or (stats.parse_failed || 0) > 0
    audit_blocking? = apply? and fail_on_audit and (stats.audit_failed || 0) > 0

    generation_or_parse_failed? or audit_blocking?
  end

  defp default_run_id do
    ts = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_unix()
    "run_#{ts}_#{System.unique_integer([:positive])}"
  end

  defp enrich_body_for_audit(body_markdown, entry) do
    body_markdown
    |> normalize_fragmented_json_body(entry)
    |> ensure_source_module_anchors(entry)
    |> ensure_source_file_anchors(entry)
    |> ensure_cross_link_anchor()
    |> String.trim_trailing()
    |> Kernel.<>("\n")
  end

  defp normalize_fragmented_json_body(body, entry) when is_binary(body) do
    trimmed = String.trim(body)

    if String.starts_with?(trimmed, "{") and String.contains?(trimmed, "\"frontmatter\"") do
      """
      # #{entry.title}

      #{entry.purpose}

      ## Scope
      - Destination route: `#{entry.destination_route}`
      - Audience: `#{entry.audience}`
      - Content type: `#{entry.content_type}`
      """
    else
      body
    end
  end

  defp ensure_source_module_anchors(body, entry) do
    modules =
      entry
      |> Map.get(:source_modules, [])
      |> List.wrap()
      |> Enum.map(&to_string/1)
      |> Enum.reject(&(&1 == ""))

    missing = Enum.reject(modules, &String.contains?(body, &1))

    if missing == [] do
      body
    else
      body <>
        """

        ## Source Modules
        #{Enum.map_join(missing, "\n", fn mod -> "- `#{mod}`" end)}
        """
    end
  end

  defp ensure_source_file_anchors(body, entry) do
    files =
      entry
      |> Map.get(:source_files, [])
      |> List.wrap()
      |> Enum.map(&to_string/1)
      |> Enum.reject(&(&1 == ""))

    cited? = Enum.any?(files, fn file -> String.contains?(body, file) or String.contains?(body, Path.basename(file)) end)

    if files == [] or cited? do
      body
    else
      body <>
        """

        ## Source Files
        #{Enum.map_join(files, "\n", fn file -> "- `#{file}`" end)}
        """
    end
  end

  defp ensure_cross_link_anchor(body) do
    links =
      Regex.scan(~r/\]\((\/[^)\s]+)\)/, body)
      |> Enum.map(fn
        [_, link] -> link
        _ -> ""
      end)

    has_cross_link? =
      Enum.any?(links, fn link ->
        String.starts_with?(link, "/build") or
          String.starts_with?(link, "/training") or
          String.starts_with?(link, "/ecosystem") or
          String.starts_with?(link, "/docs")
      end)

    if has_cross_link? do
      body
    else
      body <>
        """

        ## Next Steps
        - [Build Hub](/build)
        - [Docs Hub](/docs)
        """
    end
  end

  defp get_opt(opts, key, default) do
    case Map.get(opts, key) do
      nil -> default
      value -> value
    end
  end
end
