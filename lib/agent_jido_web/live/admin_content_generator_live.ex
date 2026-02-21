defmodule AgentJidoWeb.AdminContentGeneratorLive do
  @moduledoc """
  Admin UI for triggering `content.plan.generate` runs.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.ContentGen
  alias AgentJido.ContentPlan

  @recent_run_limit 12
  @task_supervisor_key :content_gen_task_supervisor
  @run_task_ref_key :content_gen_task_ref
  @run_form_key :content_gen_form
  @run_params_key :content_gen_form_params
  @run_history_key :content_gen_runs
  @running_key :content_gen_running

  @impl true
  def mount(_params, _session, socket) do
    params = default_form_params()
    {draft_entries, outline_entries} = queue_entries()

    {:ok,
     socket
     |> assign(@running_key, false)
     |> assign(@run_task_ref_key, nil)
     |> assign(@task_supervisor_key, nil)
     |> assign(@run_history_key, [])
     |> assign(:draft_entries, draft_entries)
     |> assign(:outline_entries, outline_entries)
     |> assign(@run_params_key, params)
     |> assign(@run_form_key, to_form(params, as: :generator))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto max-w-6xl space-y-8 px-6 py-12">
      <header class="space-y-2">
        <p class="text-xs font-semibold uppercase tracking-[0.2em] text-primary">Admin Control Plane</p>
        <div class="flex flex-wrap items-center gap-3">
          <h1 class="text-3xl font-semibold text-foreground">Content Generator</h1>
          <.link navigate="/dashboard" class="text-sm font-semibold text-primary hover:text-primary/80">
            Back to dashboard
          </.link>
        </div>
        <p class="max-w-3xl text-sm text-muted-foreground">
          Trigger `content.plan.generate` runs and prefill parameters from draft/outline queue items.
        </p>
      </header>

      <section class="space-y-4 rounded-lg border border-border bg-card p-6">
        <div class="flex items-start justify-between gap-4">
          <div class="space-y-1">
            <h2 class="text-lg font-semibold text-foreground">Run Generator</h2>
            <p class="text-sm text-muted-foreground">
              Dry-run is default. Enable apply only when report output is clean.
            </p>
          </div>
          <div :if={@content_gen_running} class="text-xs font-semibold uppercase tracking-wide text-amber-500">
            Run in progress
          </div>
        </div>

        <.form for={@content_gen_form} phx-submit="start_content_run" class="grid gap-4 md:grid-cols-2">
          <label class="space-y-1">
            <span class="block text-xs font-medium uppercase tracking-wide text-muted-foreground">Entry ID</span>
            <input
              type="text"
              name="generator[entry]"
              value={@content_gen_form[:entry].value}
              placeholder="docs/reference-jido-action"
              class="w-full rounded-md border border-border bg-background px-3 py-2 text-sm"
            />
          </label>

          <label class="space-y-1">
            <span class="block text-xs font-medium uppercase tracking-wide text-muted-foreground">Section(s)</span>
            <input
              type="text"
              name="generator[sections]"
              value={@content_gen_form[:sections].value}
              placeholder="docs,build"
              class="w-full rounded-md border border-border bg-background px-3 py-2 text-sm"
            />
          </label>

          <label class="space-y-1">
            <span class="block text-xs font-medium uppercase tracking-wide text-muted-foreground">Status Filter</span>
            <input
              type="text"
              name="generator[statuses]"
              value={@content_gen_form[:statuses].value}
              placeholder="outline,draft"
              class="w-full rounded-md border border-border bg-background px-3 py-2 text-sm"
            />
          </label>

          <label class="space-y-1">
            <span class="block text-xs font-medium uppercase tracking-wide text-muted-foreground">Max Entries</span>
            <input
              type="number"
              min="1"
              name="generator[max]"
              value={@content_gen_form[:max].value}
              class="w-full rounded-md border border-border bg-background px-3 py-2 text-sm"
            />
          </label>

          <label class="space-y-1">
            <span class="block text-xs font-medium uppercase tracking-wide text-muted-foreground">Backend</span>
            <select
              name="generator[backend]"
              class="w-full rounded-md border border-border bg-background px-3 py-2 text-sm"
            >
              <option value="auto" selected={@content_gen_form[:backend].value == "auto"}>auto</option>
              <option value="codex" selected={@content_gen_form[:backend].value == "codex"}>codex</option>
              <option value="req_llm" selected={@content_gen_form[:backend].value == "req_llm"}>req_llm</option>
            </select>
          </label>

          <label class="space-y-1">
            <span class="block text-xs font-medium uppercase tracking-wide text-muted-foreground">Model (optional)</span>
            <input
              type="text"
              name="generator[model]"
              value={@content_gen_form[:model].value}
              placeholder="google:gemini-2.5-pro"
              class="w-full rounded-md border border-border bg-background px-3 py-2 text-sm"
            />
          </label>

          <label class="space-y-1">
            <span class="block text-xs font-medium uppercase tracking-wide text-muted-foreground">Update Mode</span>
            <select
              name="generator[update_mode]"
              class="w-full rounded-md border border-border bg-background px-3 py-2 text-sm"
            >
              <option value="improve" selected={@content_gen_form[:update_mode].value == "improve"}>improve</option>
              <option value="regenerate" selected={@content_gen_form[:update_mode].value == "regenerate"}>
                regenerate
              </option>
              <option value="audit_only" selected={@content_gen_form[:update_mode].value == "audit_only"}>
                audit_only
              </option>
            </select>
          </label>

          <label class="space-y-1">
            <span class="block text-xs font-medium uppercase tracking-wide text-muted-foreground">Source Root</span>
            <input
              type="text"
              name="generator[source_root]"
              value={@content_gen_form[:source_root].value}
              placeholder=".."
              class="w-full rounded-md border border-border bg-background px-3 py-2 text-sm"
            />
          </label>

          <label class="space-y-1 md:col-span-2">
            <span class="block text-xs font-medium uppercase tracking-wide text-muted-foreground">Report Path (optional)</span>
            <input
              type="text"
              name="generator[report]"
              value={@content_gen_form[:report].value}
              placeholder="tmp/content_gen/manual_run_report.json"
              class="w-full rounded-md border border-border bg-background px-3 py-2 text-sm"
            />
          </label>

          <div class="flex items-center gap-6 md:col-span-2">
            <label class="flex items-center gap-2 text-sm text-foreground">
              <input type="hidden" name="generator[apply]" value="false" />
              <input type="checkbox" name="generator[apply]" value="true" checked={truthy?(@content_gen_form[:apply].value)} />
              Apply changes (write files)
            </label>

            <label class="flex items-center gap-2 text-sm text-foreground">
              <input type="hidden" name="generator[fail_on_audit]" value="false" />
              <input
                type="checkbox"
                name="generator[fail_on_audit]"
                value="true"
                checked={truthy?(@content_gen_form[:fail_on_audit].value)}
              /> Fail on audit
            </label>
          </div>

          <div class="md:col-span-2">
            <button
              type="submit"
              class="rounded-md bg-primary px-4 py-2 text-sm font-semibold text-primary-foreground disabled:cursor-not-allowed disabled:opacity-60"
              disabled={@content_gen_running}
            >
              {if @content_gen_running, do: "Running…", else: "Start content run"}
            </button>
          </div>
        </.form>
      </section>

      <section class="grid gap-4 lg:grid-cols-2">
        <article class="space-y-3 rounded-lg border border-border bg-card p-6">
          <div class="flex items-center justify-between">
            <h2 class="text-base font-semibold text-foreground">Draft queue</h2>
            <span class="text-xs text-muted-foreground">{length(@draft_entries)} entries</span>
          </div>

          <p :if={@draft_entries == []} class="text-sm text-muted-foreground">
            No `:draft` entries found in `priv/content_plan`.
          </p>

          <div :for={entry <- @draft_entries} class="rounded border border-border bg-background p-3">
            <div class="flex items-start justify-between gap-3">
              <div class="min-w-0 space-y-1">
                <p class="truncate text-sm font-semibold text-foreground">{entry.title}</p>
                <p class="truncate font-mono text-xs text-muted-foreground">{entry.id}</p>
                <p class="text-xs text-muted-foreground">{entry.destination_route}</p>
              </div>
              <button
                type="button"
                phx-click="use_entry"
                phx-value-entry={entry.id}
                phx-value-section={entry.section}
                class="shrink-0 rounded border border-border px-2 py-1 text-xs font-semibold text-primary hover:bg-primary/10"
              >
                Use entry
              </button>
            </div>
          </div>
        </article>

        <article class="space-y-3 rounded-lg border border-border bg-card p-6">
          <div class="flex items-center justify-between">
            <h2 class="text-base font-semibold text-foreground">Outline queue</h2>
            <span class="text-xs text-muted-foreground">{length(@outline_entries)} entries</span>
          </div>

          <p :if={@outline_entries == []} class="text-sm text-muted-foreground">
            No `:outline` entries found in `priv/content_plan`.
          </p>

          <div :for={entry <- @outline_entries} class="rounded border border-border bg-background p-3">
            <div class="flex items-start justify-between gap-3">
              <div class="min-w-0 space-y-1">
                <p class="truncate text-sm font-semibold text-foreground">{entry.title}</p>
                <p class="truncate font-mono text-xs text-muted-foreground">{entry.id}</p>
                <p class="text-xs text-muted-foreground">{entry.destination_route}</p>
              </div>
              <button
                type="button"
                phx-click="use_entry"
                phx-value-entry={entry.id}
                phx-value-section={entry.section}
                class="shrink-0 rounded border border-border px-2 py-1 text-xs font-semibold text-primary hover:bg-primary/10"
              >
                Use entry
              </button>
            </div>
          </div>
        </article>
      </section>

      <section class="space-y-3 rounded-lg border border-border bg-card p-6">
        <h2 class="text-base font-semibold text-foreground">Recent runs</h2>
        <div :if={@content_gen_runs == []} class="text-sm text-muted-foreground">
          No runs started in this session.
        </div>

        <div :for={run <- @content_gen_runs} class="rounded-md border border-border bg-background p-3 text-sm">
          <div class="flex flex-wrap items-center justify-between gap-2">
            <p class="font-mono text-xs text-muted-foreground">{run.run_id}</p>
            <span class={run_status_class(run.status)}>{run.status}</span>
          </div>
          <p class="mt-1 text-xs text-muted-foreground">{run.report_path}</p>
          <div class="mt-2 grid grid-cols-2 gap-2 text-xs text-foreground md:grid-cols-4">
            <span>selected: {run.stats.selected}</span>
            <span>written: {run.stats.written}</span>
            <span>dry-run: {run.stats.dry_run_candidates}</span>
            <span>audit failed: {run.stats.audit_failed}</span>
          </div>
          <p class="mt-2 text-[11px] text-muted-foreground">completed {format_timestamp(run.generated_at)}</p>
        </div>
      </section>
    </div>
    """
  end

  @impl true
  def handle_event("use_entry", %{"entry" => entry_id, "section" => section}, socket) do
    params =
      socket.assigns[@run_params_key]
      |> Map.put("entry", entry_id)
      |> Map.put("sections", section)

    {:noreply,
     socket
     |> assign(@run_params_key, params)
     |> assign(@run_form_key, to_form(params, as: :generator))
     |> put_flash(:info, "Prefilled form from #{entry_id}.")}
  end

  @impl true
  def handle_event("start_content_run", %{"generator" => params}, socket) do
    socket =
      socket
      |> assign(@run_params_key, params)
      |> assign(@run_form_key, to_form(params, as: :generator))

    cond do
      socket.assigns[@running_key] ->
        {:noreply, put_flash(socket, :error, "A content generation run is already in progress.")}

      true ->
        with {:ok, run_opts} <- build_run_opts(params),
             {:ok, socket} <- ensure_task_supervisor(socket),
             {:ok, ref} <- start_content_run_task(socket, run_opts) do
          {:noreply,
           socket
           |> assign(@running_key, true)
           |> assign(@run_task_ref_key, ref)
           |> put_flash(:info, "Content generation run started.")}
        else
          {:error, reason} ->
            {:noreply, put_flash(socket, :error, reason)}
        end
    end
  end

  @impl true
  def handle_info({ref, result}, socket) do
    if ref == socket.assigns[@run_task_ref_key] do
      Process.demonitor(ref, [:flush])

      {status, report, message} =
        case result do
          {:ok, report} ->
            {:completed, report, "Content generation run completed."}

          {:error, report} ->
            {:failed, report, "Content generation run finished with blocking failures."}

          other ->
            fallback_report = %{run_id: "unknown", report_path: "n/a", stats: %{}, generated_at: DateTime.utc_now()}
            {:failed, fallback_report, "Unexpected run result: #{inspect(other)}"}
        end

      run_summary = summarize_report(status, report)

      {:noreply,
       socket
       |> assign(@running_key, false)
       |> assign(@run_task_ref_key, nil)
       |> update(@run_history_key, fn runs -> Enum.take([run_summary | runs], @recent_run_limit) end)
       |> put_flash(if(status == :completed, do: :info, else: :error), message)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, reason}, socket) do
    if ref == socket.assigns[@run_task_ref_key] do
      run_summary =
        summarize_report(:failed, %{
          run_id: "crashed_#{System.unique_integer([:positive])}",
          report_path: "n/a",
          generated_at: DateTime.utc_now(),
          stats: %{},
          reason: inspect(reason)
        })

      {:noreply,
       socket
       |> assign(@running_key, false)
       |> assign(@run_task_ref_key, nil)
       |> update(@run_history_key, fn runs -> Enum.take([run_summary | runs], @recent_run_limit) end)
       |> put_flash(:error, "Content generation task crashed.")}
    else
      {:noreply, socket}
    end
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  defp queue_entries do
    entries =
      ContentPlan.all_entries()
      |> Enum.filter(&(&1.destination_collection == :pages and &1.status in [:draft, :outline]))
      |> Enum.sort_by(&{&1.section, &1.order, &1.id})

    draft_entries = Enum.filter(entries, &(&1.status == :draft))
    outline_entries = Enum.filter(entries, &(&1.status == :outline))
    {draft_entries, outline_entries}
  end

  defp start_content_run_task(socket, run_opts) do
    supervisor = socket.assigns[@task_supervisor_key]
    run_module = run_module()
    task = Task.Supervisor.async_nolink(supervisor, fn -> run_module.run(run_opts) end)
    {:ok, task.ref}
  rescue
    error -> {:error, "Failed to start run task: #{Exception.message(error)}"}
  end

  defp ensure_task_supervisor(socket) do
    case socket.assigns[@task_supervisor_key] do
      pid when is_pid(pid) ->
        if Process.alive?(pid), do: {:ok, socket}, else: start_task_supervisor(socket)

      _other ->
        start_task_supervisor(socket)
    end
  end

  defp build_run_opts(params) do
    with {:ok, max} <- parse_positive_integer(params["max"] || ""),
         {:ok, statuses} <- parse_statuses(params["statuses"] || "") do
      opts =
        %{
          apply: parse_boolean(params["apply"], false),
          max: max,
          sections: parse_csv(params["sections"] || ""),
          entry: blank_to_nil(params["entry"]),
          statuses: statuses,
          backend: parse_backend(params["backend"]),
          model: blank_to_nil(params["model"]),
          update_mode: parse_update_mode(params["update_mode"]),
          source_root: blank_to_default(params["source_root"], ".."),
          report: blank_to_nil(params["report"]),
          fail_on_audit: parse_boolean(params["fail_on_audit"], true)
        }

      {:ok, opts}
    end
  end

  defp parse_statuses(raw) do
    values =
      parse_csv(raw)
      |> case do
        [] -> Enum.map(ContentGen.default_statuses(), &Atom.to_string/1)
        list -> list
      end

    known_statuses =
      ContentPlan.all_entries()
      |> Enum.map(& &1.status)
      |> Enum.uniq()

    statuses =
      Enum.reduce_while(values, [], fn value, acc ->
        case status_atom(value, known_statuses) do
          {:ok, atom} -> {:cont, [atom | acc]}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)

    case statuses do
      {:error, _} = error -> error
      list -> {:ok, Enum.reverse(list)}
    end
  end

  defp parse_positive_integer(raw) do
    case Integer.parse(to_string(raw)) do
      {value, ""} when value > 0 -> {:ok, value}
      _ -> {:error, "Max entries must be a positive integer."}
    end
  end

  defp parse_backend("codex"), do: :codex
  defp parse_backend("req_llm"), do: :req_llm
  defp parse_backend(_), do: :auto

  defp parse_update_mode("regenerate"), do: :regenerate
  defp parse_update_mode("audit_only"), do: :audit_only
  defp parse_update_mode(_), do: :improve

  defp parse_csv(raw) do
    raw
    |> to_string()
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp parse_boolean(nil, default), do: default

  defp parse_boolean(value, _default) do
    value in ["true", "1", "on", true]
  end

  defp blank_to_nil(nil), do: nil

  defp blank_to_nil(value) do
    case String.trim(to_string(value)) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp blank_to_default(nil, default), do: default

  defp blank_to_default(value, default) do
    case String.trim(to_string(value)) do
      "" -> default
      trimmed -> trimmed
    end
  end

  defp summarize_report(status, report) do
    stats =
      report
      |> Map.get(:stats, %{})
      |> normalize_stats()

    %{
      run_id: Map.get(report, :run_id, "unknown"),
      status: status,
      report_path: Map.get(report, :report_path, "n/a"),
      generated_at: Map.get(report, :generated_at, DateTime.utc_now()),
      stats: stats
    }
  end

  defp normalize_stats(stats) do
    %{
      selected: Map.get(stats, :selected, 0),
      written: Map.get(stats, :written, 0),
      dry_run_candidates: Map.get(stats, :dry_run_candidates, 0),
      audit_failed: Map.get(stats, :audit_failed, 0)
    }
  end

  defp run_module do
    Application.get_env(:agent_jido, :content_gen_run_module, AgentJido.ContentGen.Run)
  end

  defp start_task_supervisor(socket) do
    case Task.Supervisor.start_link() do
      {:ok, pid} -> {:ok, assign(socket, @task_supervisor_key, pid)}
      {:error, reason} -> {:error, "Could not start task supervisor: #{inspect(reason)}"}
    end
  end

  defp status_atom(value, known_statuses) do
    normalized = value |> to_string() |> String.trim() |> String.downcase()

    try do
      atom = String.to_existing_atom(normalized)

      if atom in known_statuses do
        {:ok, atom}
      else
        {:error, "Unknown status value: #{value}"}
      end
    rescue
      ArgumentError ->
        {:error, "Unknown status value: #{value}"}
    end
  end

  defp default_form_params do
    %{
      "entry" => "",
      "sections" => "",
      "statuses" => Enum.join(Enum.map(ContentGen.default_statuses(), &Atom.to_string/1), ","),
      "max" => Integer.to_string(ContentGen.default_batch_size()),
      "backend" => "auto",
      "model" => "",
      "update_mode" => "improve",
      "source_root" => "..",
      "report" => "",
      "apply" => "false",
      "fail_on_audit" => "true"
    }
  end

  defp truthy?(value), do: parse_boolean(value, false)

  defp run_status_class(:completed),
    do: "inline-flex items-center rounded bg-emerald-500/10 px-2 py-0.5 text-[11px] font-semibold uppercase tracking-wide text-emerald-500"

  defp run_status_class(:failed),
    do: "inline-flex items-center rounded bg-red-500/10 px-2 py-0.5 text-[11px] font-semibold uppercase tracking-wide text-red-500"

  defp run_status_class(_),
    do: "inline-flex items-center rounded bg-muted px-2 py-0.5 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground"

  defp format_timestamp(%DateTime{} = dt), do: Calendar.strftime(dt, "%Y-%m-%d %H:%M:%S UTC")
  defp format_timestamp(_), do: "—"
end
