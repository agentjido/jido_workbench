defmodule JidoWorkbench.ChatRoom do
  use GenServer
  alias Jido.Chat.{Room, Participant}
  require Logger

  @bus_name Application.compile_env(:jido_workbench, [:agent_jido, :bus_name])
  @room_id Application.compile_env(:jido_workbench, [:agent_jido, :room_id])

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def join do
    GenServer.call(__MODULE__, :join)
  end

  def leave do
    GenServer.call(__MODULE__, :leave)
  end

  def get_room do
    GenServer.call(__MODULE__, :get_room)
  end

  @impl true
  def init(_) do
    # Get or start the chat room
    {:ok, room} = Room.via_tuple(@bus_name, @room_id) |> GenServer.whereis() |> then(&{:ok, &1})

    # Add Jido as an agent participant
    jido = Participant.new("jido", :agent, display_name: "Agent Jido")
    :ok = Room.add_participant(room, jido)

    # Post initial message
    {:ok, _initial_message} =
      Room.post_message(room, "Hello, I'm Jido, what's your name?", "jido")

    {:ok, %{room: room}}
  end

  @impl true
  def handle_call(:join, _from, state) do
    operator = Participant.new("operator", :human, display_name: "Operator")
    result = Room.add_participant(state.room, operator)

    Logger.debug("Operator joined")
    {:reply, result, state}
  end

  @impl true
  def handle_call(:leave, _from, state) do
    result = Room.remove_participant(state.room, "operator")

    Logger.debug("Operator left")
    {:reply, result, state}
  end

  @impl true
  def handle_call(:get_room, _from, state) do
    {:reply, {:ok, state.room}, state}
  end
end
