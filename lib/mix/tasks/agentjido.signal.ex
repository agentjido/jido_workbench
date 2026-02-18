defmodule Mix.Tasks.Agentjido.Signal do
  @moduledoc """
  Send signals to running agents in the Jido Workbench.

  ## Usage

      mix agentjido.signal <signal_type> [options]
      mix agentjido.signal <command> [options]

  ## Commands

      run              Run the ContentOps orchestrator pipeline (default: weekly)
      signal           Send a raw signal to an agent

  ## Examples

      # Run orchestrator pipeline (weekly mode)
      mix agentjido.signal run

      # Run orchestrator in specific mode
      mix agentjido.signal run --mode hourly
      mix agentjido.signal run --mode nightly
      mix agentjido.signal run --mode weekly
      mix agentjido.signal run --mode monthly

      # Send a raw run request signal to the orchestrator
      mix agentjido.signal contentops.run.requested --data '{"mode":"weekly"}'

      # Send a signal to a specific agent
      mix agentjido.signal some.signal.type --agent contentops --data '{"key":"value"}'

      # Send contentops.work.requested signal
      mix agentjido.signal contentops.work.requested --data '{"content_kind":"docs","target_slug":"docs/getting-started"}'

  ## Options

      --agent    Target agent: contentops (default: contentops)
      --mode     Run mode for `run` command: hourly, nightly, weekly, monthly (default: weekly)
      --data     JSON payload for the signal data (default: "{}")
      --timeout  Timeout in seconds (default: 30)
      --async    Send signal asynchronously (cast instead of call)
  """
  use Mix.Task

  @shortdoc "Send signals to running Jido agents"

  @switches [
    agent: :string,
    mode: :string,
    data: :string,
    timeout: :integer,
    async: :boolean
  ]

  @agent_servers %{
    "contentops" => AgentJido.ContentOps.OrchestratorServer
  }

  @impl Mix.Task
  def run(args) do
    bootstrap_runtime!()
    Mix.Task.run("app.start")
    ensure_orchestrator_running!()

    {opts, argv, _invalid} = OptionParser.parse(args, strict: @switches)

    case argv do
      ["run" | _] -> handle_run(opts)
      [signal_type | _] -> handle_signal(signal_type, opts)
      [] -> handle_run(opts)
    end
  end

  defp bootstrap_runtime! do
    System.put_env("AGENTJIDO_RUNTIME_ENABLED", "true")
  end

  defp ensure_orchestrator_running! do
    case Jido.AgentServer.status(AgentJido.ContentOps.OrchestratorServer) do
      {:ok, _status} ->
        :ok

      {:error, :not_found} ->
        ensure_runtime_processes!()

      {:error, reason} ->
        Mix.raise("""
        ContentOps orchestrator is not available after startup (#{inspect(reason)}).
        Ensure dependencies are started and runtime initialization is healthy.
        """)
    end
  end

  defp ensure_runtime_processes! do
    ensure_jido_running!()
    ensure_orchestrator_process!()

    case Jido.AgentServer.status(AgentJido.ContentOps.OrchestratorServer) do
      {:ok, _status} ->
        :ok

      {:error, reason} ->
        Mix.raise("""
        ContentOps orchestrator failed to start (#{inspect(reason)}).
        Ensure runtime dependencies are healthy and retry.
        """)
    end
  end

  defp ensure_jido_running! do
    registry_name = AgentJido.Jido.Registry

    case Process.whereis(registry_name) do
      pid when is_pid(pid) ->
        :ok

      nil ->
        case AgentJido.Jido.start_link([]) do
          {:ok, _pid} ->
            :ok

          {:error, {:already_started, _pid}} ->
            if Process.whereis(registry_name) do
              :ok
            else
              Mix.raise("AgentJido.Jido started without registry; restart runtime and retry.")
            end

          {:error, reason} ->
            Mix.raise("Failed to start AgentJido.Jido: #{inspect(reason)}")
        end
    end
  end

  defp ensure_orchestrator_process! do
    case Process.whereis(AgentJido.ContentOps.OrchestratorServer) do
      pid when is_pid(pid) ->
        :ok

      nil ->
        case Jido.AgentServer.start_link(
               id: AgentJido.ContentOps.OrchestratorServer,
               agent: AgentJido.ContentOps.OrchestratorAgent,
               jido: AgentJido.Jido,
               name: AgentJido.ContentOps.OrchestratorServer
             ) do
          {:ok, _pid} -> :ok
          {:error, {:already_started, _pid}} -> :ok
          {:error, reason} -> Mix.raise("Failed to start orchestrator server: #{inspect(reason)}")
        end
    end
  end

  defp handle_run(opts) do
    mode = parse_mode(Keyword.get(opts, :mode))
    timeout = Keyword.get(opts, :timeout, 30) * 1_000

    Mix.shell().info("🤖 ContentOps: starting #{mode} run...")

    result =
      AgentJido.ContentOps.OrchestratorAgent.run(
        mode: mode,
        timeout: timeout
      )

    print_run_result(result)
  end

  defp handle_signal(signal_type, opts) do
    agent_key = Keyword.get(opts, :agent, "contentops")
    timeout = Keyword.get(opts, :timeout, 30) * 1_000
    async = Keyword.get(opts, :async, false)
    data = parse_data(Keyword.get(opts, :data, "{}"))

    server = resolve_server!(agent_key)

    Mix.shell().info("📡 Sending signal #{signal_type} to #{agent_key}...")

    signal =
      Jido.Signal.new!(
        signal_type,
        data,
        source: "/cli/agentjido.signal"
      )

    if async do
      case Jido.AgentServer.cast(server, signal) do
        :ok ->
          Mix.shell().info("✅ Signal sent (async)")

        {:error, reason} ->
          Mix.raise("Failed to send signal: #{inspect(reason)}")
      end
    else
      case Jido.AgentServer.call(server, signal, timeout) do
        {:ok, agent} ->
          Mix.shell().info("✅ Signal processed")
          Mix.shell().info("   Agent state: #{inspect(agent.state, pretty: true, limit: 5)}")

        {:error, reason} ->
          Mix.raise("Signal processing failed: #{inspect(reason)}")
      end
    end
  end

  defp resolve_server!(agent_key) do
    case Map.get(@agent_servers, agent_key) do
      nil ->
        known = Map.keys(@agent_servers) |> Enum.join(", ")
        Mix.raise("Unknown agent: #{agent_key}. Known agents: #{known}")

      server ->
        server
    end
  end

  defp parse_mode(nil), do: :weekly
  defp parse_mode("hourly"), do: :hourly
  defp parse_mode("nightly"), do: :nightly
  defp parse_mode("weekly"), do: :weekly
  defp parse_mode("monthly"), do: :monthly

  defp parse_mode(mode) do
    Mix.raise("Invalid mode: #{mode}. Must be one of: hourly, nightly, weekly, monthly")
  end

  defp parse_data(json) when is_binary(json) do
    case Jason.decode(json) do
      {:ok, data} when is_map(data) ->
        data

      {:ok, _} ->
        Mix.raise("--data must be a JSON object, got: #{json}")

      {:error, reason} ->
        Mix.raise("Invalid JSON in --data: #{inspect(reason)}")
    end
  end

  defp print_run_result(%{status: :completed} = result) do
    Mix.shell().info("")
    Mix.shell().info("✅ Run completed")
    Mix.shell().info("   Mode:        #{result.mode}")
    Mix.shell().info("   Productions: #{length(result.productions)}")

    report = AgentJido.ContentOps.OrchestratorAgent.run_report(result)

    if report do
      Mix.shell().info("   Changes:     #{report[:stats][:change_requests] || 0}")
      Mix.shell().info("   Delivered:   #{report[:stats][:delivered] || 0}")
    end

    Mix.shell().info("")
  end

  defp print_run_result(%{status: :failed}) do
    Mix.raise("ContentOps run failed")
  end

  defp print_run_result(%{status: {:error, reason}}) do
    Mix.raise("ContentOps run error: #{inspect(reason)}")
  end
end
