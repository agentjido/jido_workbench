defmodule AgentJido.Demos.WeatherMultiTurnContext.RuntimeDemo do
  @moduledoc """
  Deterministic runtime wrapper for the local weather multi-turn context demo.
  """

  alias AgentJido.Demos.WeatherMultiTurnContext.{Fixtures, WeatherAssistant}

  defstruct assistant: nil, log: []

  @type log_entry :: %{
          required(:label) => String.t(),
          required(:detail) => String.t()
        }

  @type t :: %__MODULE__{
          assistant: WeatherAssistant.t(),
          log: [log_entry()]
        }

  @doc "Returns the city presets used by the demo."
  @spec cities() :: [map()]
  def cities, do: Fixtures.cities()

  @doc "Returns the deterministic turn fixtures used by the demo."
  @spec turns() :: [map()]
  def turns, do: Fixtures.turns()

  @doc "Builds a new runtime demo state."
  @spec new(String.t() | nil) :: t()
  def new(city_id \\ nil) do
    %__MODULE__{assistant: WeatherAssistant.new(city_id)}
  end

  @doc "Resets the demo while optionally changing the selected city."
  @spec reset(t(), keyword()) :: t()
  def reset(%__MODULE__{} = demo, opts \\ []) do
    city_id = Keyword.get(opts, :city_id, demo.assistant.selected_city_id)
    new(city_id)
  end

  @doc "Changes the selected city by resetting the demo state."
  @spec select_city(t(), String.t()) :: t()
  def select_city(%__MODULE__{} = demo, city_id) do
    demo
    |> reset(city_id: city_id)
    |> append_log("City", "Selected #{demo_city_name(city_id)} for the next conversation run.")
  end

  @doc "Runs one turn of the deterministic weather conversation."
  @spec run_turn(t(), atom()) :: t()
  def run_turn(%__MODULE__{} = demo, turn_id) do
    before_retry_count = length(demo.assistant.retry_events)
    assistant = WeatherAssistant.run_turn(demo.assistant, turn_id)
    turn = List.last(assistant.turns)
    after_retry_count = length(assistant.retry_events)

    demo =
      demo
      |> Map.put(:assistant, assistant)
      |> append_log(turn.title, "Answered turn #{turn.id} for #{turn.city} in #{turn.attempts} attempt(s).")

    if after_retry_count > before_retry_count do
      retry = List.last(assistant.retry_events)
      append_log(demo, "Retry", "Backed off #{retry.backoff_ms}ms before retrying #{retry.turn} for #{retry.city}.")
    else
      demo
    end
  end

  @doc "Runs the full deterministic three-turn conversation."
  @spec run_all(t()) :: t()
  def run_all(%__MODULE__{} = demo) do
    demo
    |> run_turn(:forecast)
    |> run_turn(:umbrella)
    |> run_turn(:activities)
  end

  defp append_log(%__MODULE__{} = demo, label, detail) do
    entry = %{label: label, detail: detail}
    %{demo | log: [entry | demo.log] |> Enum.take(30)}
  end

  defp demo_city_name(city_id), do: Fixtures.city!(city_id).city
end
