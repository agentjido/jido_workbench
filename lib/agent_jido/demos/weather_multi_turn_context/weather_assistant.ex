defmodule AgentJido.Demos.WeatherMultiTurnContext.WeatherAssistant do
  @moduledoc """
  Deterministic assistant logic for the local weather multi-turn context demo.
  """

  alias AgentJido.Demos.WeatherMultiTurnContext.{Fixtures, ForecastAction}

  defstruct selected_city_id: Fixtures.default_city_id(),
            selected_city: nil,
            current_city: nil,
            turns: [],
            retry_events: [],
            tool_calls: [],
            completed_turn_ids: []

  @type turn_entry :: %{
          required(:id) => atom(),
          required(:title) => String.t(),
          required(:prompt) => String.t(),
          required(:response) => String.t(),
          required(:city) => String.t(),
          required(:attempts) => pos_integer()
        }

  @type retry_entry :: %{
          required(:turn) => atom(),
          required(:city) => String.t(),
          required(:attempt) => pos_integer(),
          required(:backoff_ms) => pos_integer(),
          required(:detail) => String.t()
        }

  @type tool_call_entry :: %{
          required(:turn) => atom(),
          required(:city) => String.t(),
          required(:attempt) => pos_integer(),
          required(:status) => :ok | :error,
          required(:payload) => map()
        }

  @type t :: %__MODULE__{
          selected_city_id: String.t(),
          selected_city: map(),
          current_city: String.t() | nil,
          turns: [turn_entry()],
          retry_events: [retry_entry()],
          tool_calls: [tool_call_entry()],
          completed_turn_ids: [atom()]
        }

  @doc "Builds a new deterministic assistant state."
  @spec new(String.t() | nil) :: t()
  def new(city_id \\ nil) do
    selected_city = Fixtures.city!(city_id || Fixtures.default_city_id())

    %__MODULE__{
      selected_city_id: selected_city.id,
      selected_city: selected_city
    }
  end

  @doc "Resets the assistant while optionally changing the selected city."
  @spec reset(t(), keyword()) :: t()
  def reset(%__MODULE__{} = assistant, opts \\ []) do
    city_id = Keyword.get(opts, :city_id, assistant.selected_city_id)
    new(city_id)
  end

  @doc "Changes the selected city by resetting the assistant state."
  @spec select_city(t(), String.t()) :: t()
  def select_city(%__MODULE__{} = assistant, city_id) do
    reset(assistant, city_id: city_id)
  end

  @doc "Runs one deterministic turn while preserving city context and retry behavior."
  @spec run_turn(t(), atom()) :: t()
  def run_turn(%__MODULE__{} = assistant, turn_id) when turn_id in [:forecast, :umbrella, :activities] do
    city_fixture = resolve_city(assistant, turn_id)
    prompt = Fixtures.prompt(turn_id, city_fixture)

    {assistant, payload, attempts} = lookup_with_retry(assistant, turn_id, city_fixture.city)
    response = compose_response(turn_id, payload)
    turn = Fixtures.turn!(turn_id)

    %{
      assistant
      | current_city: city_fixture.city,
        turns:
          assistant.turns ++
            [
              %{
                id: turn_id,
                title: turn.title,
                prompt: prompt,
                response: response,
                city: city_fixture.city,
                attempts: attempts
              }
            ],
        completed_turn_ids: Enum.uniq(assistant.completed_turn_ids ++ [turn_id])
    }
  end

  @doc "Runs the full deterministic three-turn weather conversation."
  @spec run_all(t()) :: t()
  def run_all(%__MODULE__{} = assistant) do
    assistant
    |> run_turn(:forecast)
    |> run_turn(:umbrella)
    |> run_turn(:activities)
  end

  defp resolve_city(%__MODULE__{current_city: current_city}, turn_id) when is_binary(current_city) and turn_id in [:umbrella, :activities] do
    Fixtures.city_by_name!(current_city)
  end

  defp resolve_city(%__MODULE__{selected_city: selected_city}, _turn_id), do: selected_city

  defp lookup_with_retry(%__MODULE__{} = assistant, turn_id, city) do
    case tool_call(turn_id, city, 1) do
      {:ok, payload} ->
        {record_tool_call(assistant, turn_id, city, 1, :ok, payload), payload, 1}

      {:error, %{type: :busy, retry_after_ms: retry_after_ms} = reason} ->
        assistant =
          assistant
          |> record_tool_call(turn_id, city, 1, :error, reason)
          |> record_retry(turn_id, city, 1, retry_after_ms, reason.detail)

        {:ok, payload} = tool_call(turn_id, city, 2)
        {record_tool_call(assistant, turn_id, city, 2, :ok, payload), payload, 2}
    end
  end

  defp tool_call(turn_id, city, attempt) do
    ForecastAction.run(%{city: city, turn: turn_id, attempt: attempt}, %{})
  end

  defp record_tool_call(%__MODULE__{} = assistant, turn, city, attempt, status, payload) do
    entry = %{turn: turn, city: city, attempt: attempt, status: status, payload: payload}
    %{assistant | tool_calls: assistant.tool_calls ++ [entry]}
  end

  defp record_retry(%__MODULE__{} = assistant, turn, city, attempt, backoff_ms, detail) do
    entry = %{turn: turn, city: city, attempt: attempt, backoff_ms: backoff_ms, detail: detail}
    %{assistant | retry_events: assistant.retry_events ++ [entry]}
  end

  defp compose_response(:forecast, payload) do
    "#{payload.city} is expecting #{payload.condition} #{String.downcase(payload.period)} with temperatures around #{payload.temperature}. " <>
      "Plan for a practical option and keep a backup ready if conditions shift."
  end

  defp compose_response(:umbrella, payload) do
    "#{payload.umbrella} Backup recommendation: #{payload.backup_recommendation}"
  end

  defp compose_response(:activities, payload) do
    "For #{payload.city}, try one outdoor option like #{payload.outdoor_activity} and one indoor option like #{payload.indoor_activity}. " <>
      "If conditions change, #{String.downcase(payload.backup_recommendation)}"
  end
end
