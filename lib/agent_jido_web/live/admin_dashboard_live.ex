defmodule AgentJidoWeb.AdminDashboardLive do
  @moduledoc """
  Admin control-plane landing page for privileged tools.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.ContentIngest.Inventory
  alias AgentJido.QueryLogs

  @task_supervisor_key :dashboard_ingest_task_supervisor
  @task_ref_key :dashboard_ingest_task_ref
  @running_key :dashboard_ingest_running
  @preview_summary_key :dashboard_ingest_preview_summary
  @apply_summary_key :dashboard_ingest_apply_summary
  @query_window_days 7
  @query_recent_limit 80
  @query_top_limit 8

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(@running_key, false)
     |> assign(@task_ref_key, nil)
     |> assign(@task_supervisor_key, nil)
     |> assign(@preview_summary_key, nil)
     |> assign(@apply_summary_key, nil)
     |> assign(:query_tracking_snapshot, %{})
     |> load_query_tracking_snapshot()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto max-w-5xl space-y-8 px-6 py-12">
      <header class="space-y-2">
        <p class="text-xs font-semibold uppercase tracking-[0.2em] text-primary">Admin Control Plane</p>
        <h1 class="text-3xl font-semibold text-foreground">Dashboard</h1>
        <p class="max-w-2xl text-sm text-muted-foreground">
          Launch operational tooling for search, studio workflows, and ContentOps execution.
        </p>
      </header>

      <section class="grid gap-4 md:grid-cols-2">
        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">Arcana dashboard</h2>
          <p class="text-sm text-muted-foreground">
            Inspect retrieval surfaces, collections, and search diagnostics.
          </p>
          <.link href="/arcana" class="text-sm font-semibold text-primary hover:text-primary/80">
            Open Arcana dashboard
          </.link>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">Jido Studio</h2>
          <p class="text-sm text-muted-foreground">
            Observe and operate agent workflows in the Jido Studio environment.
          </p>
          <.link href="/dev/jido" class="text-sm font-semibold text-primary hover:text-primary/80">
            Open Jido Studio
          </.link>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">ContentOps dashboard</h2>
          <p class="text-sm text-muted-foreground">
            Monitor orchestration health, execution pipeline state, and run history.
          </p>
          <.link href="/dev/contentops" class="text-sm font-semibold text-primary hover:text-primary/80">
            Open ContentOps dashboard
          </.link>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6">
          <h2 class="text-lg font-semibold text-foreground">ContentOps GitHub dashboard</h2>
          <p class="text-sm text-muted-foreground">
            Review linked GitHub issues and pull requests for ContentOps operations.
          </p>
          <.link
            href="/dev/contentops/github"
            class="text-sm font-semibold text-primary hover:text-primary/80"
          >
            Open ContentOps GitHub dashboard
          </.link>
        </article>

        <article class="space-y-2 rounded-lg border border-border bg-card p-6 md:col-span-2">
          <h2 class="text-lg font-semibold text-foreground">Content Generator</h2>
          <p class="text-sm text-muted-foreground">
            Run `content.plan.generate` with admin controls and queue shortcuts.
          </p>
          <.link
            href="/dashboard/content-generator"
            class="text-sm font-semibold text-primary hover:text-primary/80"
          >
            Open Content Generator
          </.link>
        </article>

        <article id="dashboard-query-tracking" class="space-y-4 rounded-lg border border-border bg-card p-6 md:col-span-2">
          <div class="flex flex-wrap items-start justify-between gap-3">
            <div class="space-y-2">
              <h2 class="text-lg font-semibold text-foreground">Query Tracking</h2>
              <p class="text-sm text-muted-foreground">
                Tracks every Ask AI question and search query submitted through the site.
              </p>
            </div>

            <button
              type="button"
              phx-click="refresh_query_tracking"
              class="rounded-md border border-border bg-background px-3 py-2 text-xs font-semibold text-foreground hover:border-primary/50"
            >
              Refresh query logs
            </button>
          </div>

          <p :if={@query_tracking_snapshot.unavailable?} class="text-xs font-semibold text-amber-300">
            Query tracking is temporarily unavailable. Run migrations and refresh.
          </p>

          <div class="grid grid-cols-2 gap-2 text-xs text-muted-foreground md:grid-cols-6">
            <span>window: {@query_tracking_snapshot.summary.days}d</span>
            <span>total: {@query_tracking_snapshot.summary.total}</span>
            <span>search: {@query_tracking_snapshot.summary.search}</span>
            <span>ask ai: {@query_tracking_snapshot.summary.ask_ai}</span>
            <span>success: {@query_tracking_snapshot.summary.success}</span>
            <span>no results: {@query_tracking_snapshot.summary.no_results}</span>
          </div>

          <div :if={@query_tracking_snapshot.top_queries != []} class="space-y-2">
            <h3 class="text-xs font-semibold uppercase tracking-[0.14em] text-muted-foreground">Top queries</h3>
            <div class="flex flex-wrap gap-2">
              <span
                :for={query <- @query_tracking_snapshot.top_queries}
                class="rounded-full border border-border bg-background px-2.5 py-1 text-xs text-foreground"
              >
                {truncate_query(query.query)} <span class="text-muted-foreground">({query.count})</span>
              </span>
            </div>
          </div>

          <div class="overflow-x-auto rounded-md border border-border bg-background">
            <table class="min-w-full text-left text-xs">
              <thead class="bg-elevated text-muted-foreground">
                <tr>
                  <th class="px-3 py-2 font-semibold">Time (UTC)</th>
                  <th class="px-3 py-2 font-semibold">Source</th>
                  <th class="px-3 py-2 font-semibold">Channel</th>
                  <th class="px-3 py-2 font-semibold">Status</th>
                  <th class="px-3 py-2 font-semibold">Results</th>
                  <th class="px-3 py-2 font-semibold">Query</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={entry <- @query_tracking_snapshot.recent_queries} class="border-t border-border/70">
                  <td class="whitespace-nowrap px-3 py-2 text-muted-foreground">{format_timestamp(entry.inserted_at)}</td>
                  <td class="px-3 py-2 text-foreground">{source_label(entry.source)}</td>
                  <td class="px-3 py-2 text-muted-foreground">{entry.channel}</td>
                  <td class="px-3 py-2">
                    <span class={"rounded px-1.5 py-0.5 font-semibold #{query_status_class(entry.status)}"}>
                      {entry.status}
                    </span>
                  </td>
                  <td class="px-3 py-2 text-muted-foreground">{entry.results_count}</td>
                  <td class="max-w-[560px] break-words px-3 py-2 text-foreground">{entry.query}</td>
                </tr>
                <tr :if={@query_tracking_snapshot.recent_queries == []}>
                  <td colspan="6" class="px-3 py-3 text-muted-foreground">
                    No query logs yet.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </article>

        <article id="dashboard-content-ingest" class="space-y-4 rounded-lg border border-border bg-card p-6 md:col-span-2">
          <div class="space-y-2">
            <h2 class="text-lg font-semibold text-foreground">Content Ingestion</h2>
            <p class="text-sm text-muted-foreground">
              Run idempotent Arcana sync from the dashboard. Preview computes pending insert/update/delete work without writing. Apply performs the sync.
            </p>
            <p class="text-xs text-muted-foreground">
              Dashboard runs use `graph: false` for predictable cost and runtime.
            </p>
          </div>

          <div class="flex flex-wrap items-center gap-3">
            <button
              type="button"
              phx-click="preview_ingest"
              disabled={@dashboard_ingest_running}
              class="rounded-md border border-border bg-background px-3 py-2 text-sm font-semibold text-foreground hover:border-primary/50 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {if @dashboard_ingest_running, do: "Working…", else: "Preview ingest changes"}
            </button>

            <button
              type="button"
              phx-click="run_ingest"
              disabled={@dashboard_ingest_running}
              class="rounded-md bg-primary px-3 py-2 text-sm font-semibold text-primary-foreground hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {if @dashboard_ingest_running, do: "Working…", else: "Run ingest now"}
            </button>

            <button
              type="button"
              phx-click="run_ingest_one"
              disabled={@dashboard_ingest_running}
              class="rounded-md border border-border bg-background px-3 py-2 text-sm font-semibold text-foreground hover:border-primary/50 disabled:cursor-not-allowed disabled:opacity-50"
            >
              {if @dashboard_ingest_running, do: "Working…", else: "Ingest 1"}
            </button>
          </div>

          <section :if={@dashboard_ingest_preview_summary} class="space-y-2 rounded-md border border-border bg-background p-4">
            <h3 class="text-sm font-semibold text-foreground">Last preview</h3>
            <div class="grid grid-cols-2 gap-2 text-xs text-muted-foreground md:grid-cols-6">
              <span>sources: {@dashboard_ingest_preview_summary.total_sources}</span>
              <span>inserted: {@dashboard_ingest_preview_summary.inserted}</span>
              <span>updated: {@dashboard_ingest_preview_summary.updated}</span>
              <span>deleted: {@dashboard_ingest_preview_summary.deleted}</span>
              <span>skipped: {@dashboard_ingest_preview_summary.skipped}</span>
              <span>failed: {@dashboard_ingest_preview_summary.failed_count}</span>
            </div>
            <p class={preview_status_class(@dashboard_ingest_preview_summary)}>
              {preview_status_text(@dashboard_ingest_preview_summary)}
            </p>
          </section>

          <section :if={@dashboard_ingest_apply_summary} class="space-y-2 rounded-md border border-border bg-background p-4">
            <h3 class="text-sm font-semibold text-foreground">Last apply run</h3>
            <div class="grid grid-cols-2 gap-2 text-xs text-muted-foreground md:grid-cols-6">
              <span>sources: {@dashboard_ingest_apply_summary.total_sources}</span>
              <span>inserted: {@dashboard_ingest_apply_summary.inserted}</span>
              <span>updated: {@dashboard_ingest_apply_summary.updated}</span>
              <span>deleted: {@dashboard_ingest_apply_summary.deleted}</span>
              <span>skipped: {@dashboard_ingest_apply_summary.skipped}</span>
              <span>failed: {@dashboard_ingest_apply_summary.failed_count}</span>
            </div>
            <p class={apply_status_class(@dashboard_ingest_apply_summary)}>
              {apply_status_text(@dashboard_ingest_apply_summary)}
            </p>
          </section>
        </article>
      </section>
    </div>
    """
  end

  @impl true
  def handle_event("preview_ingest", _params, socket) do
    trigger_ingest(socket, :preview)
  end

  @impl true
  def handle_event("run_ingest", _params, socket) do
    trigger_ingest(socket, :apply)
  end

  @impl true
  def handle_event("run_ingest_one", _params, socket) do
    trigger_ingest(socket, :apply_one)
  end

  @impl true
  def handle_event("refresh_query_tracking", _params, socket) do
    {:noreply, load_query_tracking_snapshot(socket)}
  end

  @impl true
  def handle_info({ref, {:ok, mode, summary}}, socket) do
    if ref == socket.assigns[@task_ref_key] do
      Process.demonitor(ref, [:flush])
      normalized = normalize_summary(summary)

      socket =
        socket
        |> assign(@running_key, false)
        |> assign(@task_ref_key, nil)
        |> assign(summary_assign_key(mode), normalized)

      message =
        case mode do
          :preview -> "Ingestion preview complete."
          :apply -> "Ingestion run complete."
          :apply_one -> "Single-source ingestion run complete."
        end

      flash_type = if normalized.failed_count > 0, do: :error, else: :info
      {:noreply, put_flash(socket, flash_type, message)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({ref, {:error, mode, reason}}, socket) do
    if ref == socket.assigns[@task_ref_key] do
      Process.demonitor(ref, [:flush])

      label =
        case mode do
          :preview -> "preview"
          :apply -> "apply"
          :apply_one -> "single-source apply"
        end

      {:noreply,
       socket
       |> assign(@running_key, false)
       |> assign(@task_ref_key, nil)
       |> put_flash(:error, "Ingestion #{label} failed: #{reason}")}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, socket) do
    if ref == socket.assigns[@task_ref_key] do
      {:noreply,
       socket
       |> assign(@running_key, false)
       |> assign(@task_ref_key, nil)
       |> put_flash(:error, "Ingestion task crashed: #{inspect(reason)}")}
    else
      {:noreply, socket}
    end
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  defp trigger_ingest(socket, mode) do
    cond do
      socket.assigns[@running_key] ->
        {:noreply, put_flash(socket, :error, "An ingestion task is already running.")}

      true ->
        with {:ok, socket} <- ensure_task_supervisor(socket),
             {:ok, ref} <- start_ingest_task(socket, mode) do
          label =
            case mode do
              :preview -> "Ingestion preview started."
              :apply -> "Ingestion run started."
              :apply_one -> "Single-source ingestion run started."
            end

          {:noreply,
           socket
           |> assign(@running_key, true)
           |> assign(@task_ref_key, ref)
           |> put_flash(:info, label)}
        else
          {:error, reason} ->
            {:noreply, put_flash(socket, :error, reason)}
        end
    end
  end

  defp ensure_task_supervisor(socket) do
    case socket.assigns[@task_supervisor_key] do
      pid when is_pid(pid) ->
        if Process.alive?(pid), do: {:ok, socket}, else: start_task_supervisor(socket)

      _other ->
        start_task_supervisor(socket)
    end
  end

  defp start_task_supervisor(socket) do
    case Task.Supervisor.start_link() do
      {:ok, pid} -> {:ok, assign(socket, @task_supervisor_key, pid)}
      {:error, reason} -> {:error, "Could not start ingestion task supervisor: #{inspect(reason)}"}
    end
  end

  defp start_ingest_task(socket, mode) do
    supervisor = socket.assigns[@task_supervisor_key]
    ingest_module = ingest_module()

    with {:ok, opts} <- ingest_opts(mode) do
      task =
        Task.Supervisor.async_nolink(supervisor, fn ->
          try do
            {:ok, mode, ingest_module.sync(opts)}
          rescue
            error -> {:error, mode, Exception.message(error)}
          catch
            kind, reason -> {:error, mode, "#{kind}: #{inspect(reason)}"}
          end
        end)

      {:ok, task.ref}
    end
  rescue
    error ->
      {:error, "Failed to start ingestion task: #{Exception.message(error)}"}
  end

  defp ingest_opts(:preview), do: {:ok, [dry_run: true, graph: false]}
  defp ingest_opts(:apply), do: {:ok, [dry_run: false, graph: false]}

  defp ingest_opts(:apply_one) do
    case first_inventory_source() do
      {:ok, source} ->
        {:ok,
         [
           dry_run: false,
           graph: false,
           reconcile_stale: false,
           sources: [source],
           managed_collections: [source.collection]
         ]}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp ingest_opts(_), do: {:ok, [dry_run: true, graph: false]}

  defp ingest_module do
    Application.get_env(:agent_jido, :dashboard_ingest_module, AgentJido.ContentIngest)
  end

  defp summary_assign_key(:preview), do: @preview_summary_key
  defp summary_assign_key(:apply), do: @apply_summary_key
  defp summary_assign_key(:apply_one), do: @apply_summary_key

  defp normalize_summary(summary) when is_map(summary) do
    failed = Map.get(summary, :failed, [])

    %{
      total_sources: Map.get(summary, :total_sources, 0),
      inserted: Map.get(summary, :inserted, 0),
      updated: Map.get(summary, :updated, 0),
      deleted: Map.get(summary, :deleted, 0),
      skipped: Map.get(summary, :skipped, 0),
      failed_count: Map.get(summary, :failed_count, if(is_list(failed), do: length(failed), else: 0))
    }
  end

  defp normalize_summary(_summary) do
    %{total_sources: 0, inserted: 0, updated: 0, deleted: 0, skipped: 0, failed_count: 0}
  end

  defp pending_changes(summary), do: summary.inserted + summary.updated + summary.deleted

  defp preview_status_text(summary) do
    pending = pending_changes(summary)

    cond do
      summary.failed_count > 0 ->
        "Preview completed with failures. Review logs before applying."

      pending > 0 ->
        "Pending ingestion changes detected (#{pending}). Run ingest now to apply."

      true ->
        "No ingestion changes detected. Arcana content is up to date."
    end
  end

  defp preview_status_class(summary) do
    pending = pending_changes(summary)

    cond do
      summary.failed_count > 0 -> "text-xs font-semibold text-red-400"
      pending > 0 -> "text-xs font-semibold text-amber-300"
      true -> "text-xs font-semibold text-emerald-300"
    end
  end

  defp apply_status_text(summary) do
    cond do
      summary.failed_count > 0 ->
        "Ingestion apply completed with failures. Check logs and retry."

      true ->
        "Ingestion apply completed successfully."
    end
  end

  defp apply_status_class(summary) do
    if summary.failed_count > 0 do
      "text-xs font-semibold text-red-400"
    else
      "text-xs font-semibold text-emerald-300"
    end
  end

  defp load_query_tracking_snapshot(socket) do
    snapshot =
      QueryLogs.dashboard_snapshot(
        @query_window_days,
        @query_recent_limit,
        @query_top_limit
      )

    assign(socket, :query_tracking_snapshot, snapshot)
  end

  defp source_label("ask_ai"), do: "Ask AI"
  defp source_label("search"), do: "Search"
  defp source_label(source) when is_binary(source), do: source
  defp source_label(_source), do: "Unknown"

  defp query_status_class("success"), do: "bg-emerald-500/15 text-emerald-300"
  defp query_status_class("no_results"), do: "bg-amber-500/15 text-amber-300"
  defp query_status_class("error"), do: "bg-red-500/15 text-red-300"
  defp query_status_class("challenge"), do: "bg-amber-500/15 text-amber-300"
  defp query_status_class("submitted"), do: "bg-cyan-500/15 text-cyan-300"
  defp query_status_class(_status), do: "bg-muted text-muted-foreground"

  defp format_timestamp(%NaiveDateTime{} = datetime) do
    Calendar.strftime(datetime, "%Y-%m-%d %H:%M:%S")
  end

  defp format_timestamp(_datetime), do: "—"

  defp truncate_query(query) when is_binary(query) do
    trimmed = String.trim(query)

    cond do
      trimmed == "" ->
        "(empty)"

      String.length(trimmed) > 80 ->
        String.slice(trimmed, 0, 77) <> "..."

      true ->
        trimmed
    end
  end

  defp truncate_query(_query), do: "(empty)"

  defp first_inventory_source do
    source =
      Inventory.build()
      |> Enum.sort_by(&{&1.collection, &1.source_id})
      |> List.first()

    if source do
      {:ok, source}
    else
      {:error, "No ingestible sources found in local inventory."}
    end
  rescue
    error ->
      {:error, "Failed to build local inventory: #{Exception.message(error)}"}
  end
end
