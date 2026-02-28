defmodule AgentJidoWeb.AdminContentIngestionLive do
  @moduledoc """
  Admin UI for inspecting local content inventory and running Arcana ingestion.
  """
  use AgentJidoWeb, :live_view

  alias AgentJido.ContentIngest.Inventory

  @task_supervisor_key :content_ingest_task_supervisor
  @task_ref_key :content_ingest_task_ref
  @running_key :content_ingest_running

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(@running_key, false)
     |> assign(@task_ref_key, nil)
     |> assign(@task_supervisor_key, nil)
     |> assign(:current_run_label, nil)
     |> assign(:last_ingest_summary, nil)
     |> assign(:last_ingest_label, nil)
     |> assign(:source_rows, [])
     |> assign(:source_lookup, %{})
     |> assign(:collection_counts, %{})
     |> load_sources()}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <AgentJidoWeb.Jido.AdminNav.admin_shell current_path="/dashboard/content-ingestion">
      <div class="container mx-auto max-w-6xl space-y-8 px-6 py-12">
        <header class="space-y-2">
          <p class="text-xs font-semibold uppercase tracking-[0.2em] text-primary">Admin Control Plane</p>
          <h1 class="text-3xl font-semibold text-foreground">Content Ingestion</h1>
          <p class="max-w-3xl text-sm text-muted-foreground">
            Inspect every ingestible content source and run Arcana sync for all sources or a single source.
          </p>
        </header>

        <section class="space-y-4 rounded-lg border border-border bg-card p-6">
          <div class="flex flex-wrap items-start justify-between gap-3">
            <div class="space-y-2">
              <h2 class="text-lg font-semibold text-foreground">Actions</h2>
              <p class="text-sm text-muted-foreground">
                Use ingest-all for a full sync, or re-ingest a single source from the inventory table.
              </p>
            </div>

            <div :if={@content_ingest_running} class="text-xs font-semibold uppercase tracking-wide text-accent-yellow">
              {@current_run_label || "Ingestion running"}…
            </div>
          </div>

          <div class="grid grid-cols-2 gap-2 text-xs text-muted-foreground md:grid-cols-4">
            <span>total: {length(@source_rows)}</span>
            <span>docs: {Map.get(@collection_counts, "site_docs", 0)}</span>
            <span>blog: {Map.get(@collection_counts, "site_blog", 0)}</span>
            <span>ecosystem: {Map.get(@collection_counts, "site_ecosystem", 0)}</span>
          </div>

          <div class="flex flex-wrap items-center gap-3">
            <button
              type="button"
              phx-click="refresh_sources"
              disabled={@content_ingest_running}
              class="rounded-md border border-border bg-background px-3 py-2 text-xs font-semibold text-foreground hover:border-primary/50 disabled:cursor-not-allowed disabled:opacity-50"
            >
              Refresh inventory
            </button>

            <button
              type="button"
              phx-click="preview_all"
              disabled={@content_ingest_running}
              class="rounded-md border border-border bg-background px-3 py-2 text-xs font-semibold text-foreground hover:border-primary/50 disabled:cursor-not-allowed disabled:opacity-50"
            >
              Preview ingest all
            </button>

            <button
              type="button"
              phx-click="ingest_all"
              disabled={@content_ingest_running}
              class="rounded-md bg-primary px-3 py-2 text-xs font-semibold text-primary-foreground hover:bg-primary/90 disabled:cursor-not-allowed disabled:opacity-50"
            >
              Ingest all
            </button>
          </div>

          <section :if={@last_ingest_summary} class="space-y-2 rounded-md border border-border bg-background p-4">
            <h3 class="text-sm font-semibold text-foreground">Last run: {@last_ingest_label}</h3>
            <div class="grid grid-cols-2 gap-2 text-xs text-muted-foreground md:grid-cols-6">
              <span>sources: {@last_ingest_summary.total_sources}</span>
              <span>inserted: {@last_ingest_summary.inserted}</span>
              <span>updated: {@last_ingest_summary.updated}</span>
              <span>deleted: {@last_ingest_summary.deleted}</span>
              <span>skipped: {@last_ingest_summary.skipped}</span>
              <span>failed: {@last_ingest_summary.failed_count}</span>
            </div>
            <p class={summary_status_class(@last_ingest_summary)}>
              {summary_status_text(@last_ingest_summary)}
            </p>
          </section>
        </section>

        <section class="space-y-4 rounded-lg border border-border bg-card p-6">
          <div class="space-y-1">
            <h2 class="text-lg font-semibold text-foreground">Local Content Inventory</h2>
            <p class="text-sm text-muted-foreground">
              Each row is a source that can be re-ingested independently.
            </p>
          </div>

          <div class="overflow-x-auto rounded-md border border-border bg-background">
            <table class="w-full table-fixed text-left text-[11px] leading-5">
              <thead class="bg-elevated text-muted-foreground">
                <tr>
                  <th class="w-[10%] px-2 py-1.5 font-semibold">Action</th>
                  <th class="w-[12%] px-2 py-1.5 font-semibold">Collection</th>
                  <th class="w-[22%] px-2 py-1.5 font-semibold">Title</th>
                  <th class="w-[33%] px-2 py-1.5 font-semibold">Path</th>
                  <th class="w-[23%] px-2 py-1.5 font-semibold">Source ID</th>
                </tr>
              </thead>
              <tbody>
                <tr :for={source <- @source_rows} class="border-t border-border/70">
                  <td class="px-2 py-1.5">
                    <button
                      type="button"
                      phx-click="ingest_source"
                      phx-value-source-id={source.source_id}
                      disabled={@content_ingest_running}
                      class="whitespace-nowrap rounded-md border border-border bg-background px-2 py-0.5 text-[11px] font-semibold text-foreground hover:border-primary/50 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                      Re-ingest
                    </button>
                  </td>
                  <td class="whitespace-nowrap px-2 py-1.5 text-muted-foreground">{source.collection}</td>
                  <td class="truncate px-2 py-1.5 text-foreground" title={source.title}>{source.title}</td>
                  <td class="truncate px-2 py-1.5 text-muted-foreground" title={source.path}>{source.path}</td>
                  <td class="truncate px-2 py-1.5 font-mono text-muted-foreground" title={source.source_id}>
                    {source.source_id}
                  </td>
                </tr>
                <tr :if={@source_rows == []}>
                  <td colspan="5" class="px-2 py-2 text-muted-foreground">
                    No ingestible sources found in local inventory.
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>
    </AgentJidoWeb.Jido.AdminNav.admin_shell>
    """
  end

  @impl true
  def handle_event("refresh_sources", _params, socket) do
    {:noreply, load_sources(socket)}
  end

  def handle_event("preview_all", _params, socket) do
    trigger_ingest(socket, :preview_all, nil)
  end

  def handle_event("ingest_all", _params, socket) do
    trigger_ingest(socket, :ingest_all, nil)
  end

  def handle_event("ingest_source", %{"source-id" => source_id}, socket) do
    trigger_ingest(socket, :ingest_source, source_id)
  end

  @impl true
  def handle_info({ref, {:ok, mode, source_id, summary}}, socket) do
    if ref == socket.assigns[@task_ref_key] do
      Process.demonitor(ref, [:flush])
      normalized = normalize_summary(summary)

      socket =
        socket
        |> assign(@running_key, false)
        |> assign(@task_ref_key, nil)
        |> assign(:current_run_label, nil)
        |> assign(:last_ingest_summary, normalized)
        |> assign(:last_ingest_label, run_label(mode, source_id))
        |> load_sources()

      flash_type = if normalized.failed_count > 0, do: :error, else: :info
      {:noreply, put_flash(socket, flash_type, run_complete_text(mode, source_id))}
    else
      {:noreply, socket}
    end
  end

  def handle_info({ref, {:error, mode, source_id, reason}}, socket) do
    if ref == socket.assigns[@task_ref_key] do
      Process.demonitor(ref, [:flush])

      {:noreply,
       socket
       |> assign(@running_key, false)
       |> assign(@task_ref_key, nil)
       |> assign(:current_run_label, nil)
       |> put_flash(:error, "#{run_label(mode, source_id)} failed: #{reason}")}
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
       |> assign(:current_run_label, nil)
       |> put_flash(:error, "Ingestion task crashed: #{inspect(reason)}")}
    else
      {:noreply, socket}
    end
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  defp trigger_ingest(socket, mode, source_id) do
    cond do
      socket.assigns[@running_key] ->
        {:noreply, put_flash(socket, :error, "An ingestion task is already running.")}

      true ->
        with {:ok, socket} <- ensure_task_supervisor(socket),
             {:ok, opts} <- ingest_opts(mode, source_id, socket.assigns.source_lookup),
             {:ok, ref} <- start_ingest_task(socket, mode, source_id, opts) do
          {:noreply,
           socket
           |> assign(@running_key, true)
           |> assign(@task_ref_key, ref)
           |> assign(:current_run_label, run_label(mode, source_id))
           |> put_flash(:info, "#{run_label(mode, source_id)} started.")}
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

  defp start_ingest_task(socket, mode, source_id, opts) do
    supervisor = socket.assigns[@task_supervisor_key]
    ingest_module = ingest_module()

    task =
      Task.Supervisor.async_nolink(supervisor, fn ->
        try do
          {:ok, mode, source_id, ingest_module.sync(opts)}
        rescue
          error -> {:error, mode, source_id, Exception.message(error)}
        catch
          kind, reason -> {:error, mode, source_id, "#{kind}: #{inspect(reason)}"}
        end
      end)

    {:ok, task.ref}
  rescue
    error ->
      {:error, "Failed to start ingestion task: #{Exception.message(error)}"}
  end

  defp ingest_opts(:preview_all, _source_id, _lookup), do: {:ok, [dry_run: true, graph: false]}
  defp ingest_opts(:ingest_all, _source_id, _lookup), do: {:ok, [dry_run: false, graph: false]}

  defp ingest_opts(:ingest_source, source_id, source_lookup) do
    case Map.get(source_lookup, source_id) do
      nil ->
        {:error, "Could not find source #{source_id} in current inventory."}

      source ->
        {:ok,
         [
           dry_run: false,
           graph: false,
           reconcile_stale: false,
           sources: [source],
           managed_collections: [source.collection]
         ]}
    end
  end

  defp ingest_opts(_mode, _source_id, _lookup), do: {:ok, [dry_run: true, graph: false]}

  defp run_label(:preview_all, _source_id), do: "Preview all sources"
  defp run_label(:ingest_all, _source_id), do: "Ingest all sources"
  defp run_label(:ingest_source, source_id), do: "Re-ingest #{source_id}"
  defp run_label(_mode, _source_id), do: "Ingestion run"

  defp run_complete_text(:preview_all, _source_id), do: "Ingestion preview completed."
  defp run_complete_text(:ingest_all, _source_id), do: "Ingest all completed."
  defp run_complete_text(:ingest_source, source_id), do: "Re-ingest completed for #{source_id}."
  defp run_complete_text(_mode, _source_id), do: "Ingestion completed."

  defp load_sources(socket) do
    sources =
      Inventory.build()
      |> Enum.sort_by(&{&1.collection, &1.source_id})

    source_rows =
      Enum.map(sources, fn source ->
        metadata = source.metadata || %{}

        %{
          source_id: source.source_id,
          collection: source.collection,
          title: metadata_value(metadata, "title") || metadata_value(metadata, "name") || source.source_id,
          path: metadata_value(metadata, "path") || metadata_value(metadata, "url") || "—"
        }
      end)

    source_lookup =
      Enum.into(sources, %{}, fn source -> {source.source_id, source} end)

    collection_counts =
      Enum.frequencies_by(sources, & &1.collection)

    socket
    |> assign(:source_rows, source_rows)
    |> assign(:source_lookup, source_lookup)
    |> assign(:collection_counts, collection_counts)
  rescue
    _error ->
      socket
      |> assign(:source_rows, [])
      |> assign(:source_lookup, %{})
      |> assign(:collection_counts, %{})
  end

  defp metadata_value(metadata, key) when is_map(metadata) do
    Map.get(metadata, key) || Map.get(metadata, String.to_atom(key))
  rescue
    ArgumentError ->
      Map.get(metadata, key)
  end

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

  defp summary_status_text(summary) do
    pending = summary.inserted + summary.updated + summary.deleted

    cond do
      summary.failed_count > 0 ->
        "Run completed with failures. Check logs and retry."

      pending > 0 ->
        "Run completed successfully with #{pending} total content changes."

      true ->
        "Run completed with no content changes."
    end
  end

  defp summary_status_class(summary) do
    if summary.failed_count > 0 do
      "text-xs font-semibold text-accent-red"
    else
      "text-xs font-semibold text-accent-green"
    end
  end

  defp ingest_module do
    Application.get_env(:agent_jido, :dashboard_ingest_module, AgentJido.ContentIngest)
  end
end
