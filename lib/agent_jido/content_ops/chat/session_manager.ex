defmodule AgentJido.ContentOps.Chat.SessionManager do
  @moduledoc """
  Manages room-scoped Ops agent sessions.
  """

  use GenServer

  alias AgentJido.ContentOps.Chat.{ChatAgent, OpsAgent}

  @type state :: %{
          sessions: %{String.t() => {pid(), reference()}},
          jido: atom()
        }

  @doc "Starts the session manager."
  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc "Ensures there is an active Ops session for a room."
  @spec ensure_session(String.t()) :: {:ok, pid()} | {:error, term()}
  def ensure_session(room_id) when is_binary(room_id) do
    GenServer.call(__MODULE__, {:ensure_session, room_id, OpsAgent})
  end

  @doc "Ensures there is an active Chat session for a room."
  @spec ensure_chat_session(String.t()) :: {:ok, pid()} | {:error, term()}
  def ensure_chat_session(room_id) when is_binary(room_id) do
    GenServer.call(__MODULE__, {:ensure_session, room_id, ChatAgent})
  end

  @doc "Returns the session pid for a room if present."
  @spec get_session(String.t()) :: {:ok, pid()} | {:error, :not_found}
  def get_session(room_id) when is_binary(room_id) do
    GenServer.call(__MODULE__, {:get_session, room_id})
  end

  @doc "Stops a room session if it is running."
  @spec stop_session(String.t()) :: :ok
  def stop_session(room_id) when is_binary(room_id) do
    GenServer.cast(__MODULE__, {:stop_session, room_id})
  end

  @impl true
  def init(opts) do
    state = %{
      sessions: %{},
      jido: Keyword.get(opts, :jido, AgentJido.Jido)
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:ensure_session, room_id, agent_module}, _from, state) do
    session_key = {agent_module, room_id}

    case Map.get(state.sessions, session_key) do
      {pid, _ref} when is_pid(pid) ->
        if Process.alive?(pid) do
          {:reply, {:ok, pid}, state}
        else
          start_and_reply(state, session_key, agent_module, room_id)
        end

      _other ->
        start_and_reply(state, session_key, agent_module, room_id)
    end
  end

  def handle_call({:get_session, room_id}, _from, state) do
    case Map.get(state.sessions, room_id) do
      {pid, _ref} when is_pid(pid) ->
        if Process.alive?(pid) do
          {:reply, {:ok, pid}, state}
        else
          {:reply, {:error, :not_found}, %{state | sessions: Map.delete(state.sessions, room_id)}}
        end

      _other ->
        {:reply, {:error, :not_found}, state}
    end
  end

  @impl true
  def handle_cast({:stop_session, room_id}, state) do
    state =
      case Map.pop(state.sessions, room_id) do
        {{pid, ref}, sessions} ->
          Process.demonitor(ref, [:flush])
          _ = Jido.stop_agent(state.jido, pid)
          %{state | sessions: sessions}

        {nil, _sessions} ->
          state
      end

    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    sessions =
      state.sessions
      |> Enum.reject(fn {_room_id, {_pid, session_ref}} -> session_ref == ref end)
      |> Map.new()

    {:noreply, %{state | sessions: sessions}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, state) do
    Enum.each(state.sessions, fn {_room_id, {pid, _ref}} ->
      _ = Jido.stop_agent(state.jido, pid)
    end)

    :ok
  end

  defp start_room_agent(jido, agent_module, room_id) do
    prefix = agent_module |> Module.split() |> List.last() |> Macro.underscore()
    agent_id = "contentops_chat_#{prefix}:" <> room_id

    case Jido.whereis(jido, agent_id) do
      pid when is_pid(pid) ->
        {:ok, pid}

      nil ->
        case Jido.start_agent(jido, agent_module, id: agent_id) do
          {:ok, pid} -> {:ok, pid}
          {:error, {:already_started, pid}} -> {:ok, pid}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  defp start_and_reply(state, session_key, agent_module, room_id) do
    case start_room_agent(state.jido, agent_module, room_id) do
      {:ok, pid} ->
        ref = Process.monitor(pid)
        sessions = Map.put(state.sessions, session_key, {pid, ref})
        {:reply, {:ok, pid}, %{state | sessions: sessions}}

      {:error, reason} ->
        {:reply, {:error, reason}, state}
    end
  end
end
