defmodule AgentJido.Demos.WeatherMultiTurnContext.Fixtures do
  @moduledoc """
  Deterministic city and turn fixtures for the local weather multi-turn demo.
  """

  @cities [
    %{
      id: "seattle",
      city: "Seattle",
      period: "Tomorrow Morning",
      condition: "light rain",
      temperature: "58F",
      umbrella: "Yes, bring an umbrella because Seattle is expected to stay damp through Tomorrow Morning.",
      outdoor_activity: "walk the waterfront with a rain shell",
      indoor_activity: "visit the aquarium",
      backup_recommendation: "If the rain picks up, switch to an indoor coffee break downtown."
    },
    %{
      id: "denver",
      city: "Denver",
      period: "Tomorrow Afternoon",
      condition: "sunny with gusty wind",
      temperature: "71F",
      umbrella: "No umbrella is needed in Denver, but a light jacket helps with the gusty wind.",
      outdoor_activity: "take a trail walk at Red Rocks",
      indoor_activity: "stop by the art museum",
      backup_recommendation: "If the wind feels sharp, swap the trail for an indoor museum visit."
    }
  ]

  @turns [
    %{
      id: :forecast,
      title: "Forecast Anchor",
      prompt_template: "I'm in %{city}. Give tomorrow's weather in one short paragraph and explicitly mention %{city}.",
      requires_city_in_prompt?: true
    },
    %{
      id: :umbrella,
      title: "Umbrella Follow-Up",
      prompt_template: "Should I bring an umbrella?",
      requires_city_in_prompt?: false
    },
    %{
      id: :activities,
      title: "Activities Follow-Up",
      prompt_template: "Suggest one outdoor and one indoor activity.",
      requires_city_in_prompt?: false
    }
  ]

  @doc "Returns the city presets used by the weather demo."
  @spec cities() :: [map()]
  def cities, do: @cities

  @doc "Returns the deterministic turn sequence for the demo."
  @spec turns() :: [map()]
  def turns, do: @turns

  @doc "Returns the default city id."
  @spec default_city_id() :: String.t()
  def default_city_id, do: "seattle"

  @doc "Fetches a city fixture by stable id."
  @spec city!(String.t()) :: map()
  def city!(id) when is_binary(id) do
    Enum.find(@cities, &(&1.id == id)) ||
      raise ArgumentError, "unknown weather demo city id: #{inspect(id)}"
  end

  @doc "Fetches a city fixture by city name."
  @spec city_by_name!(String.t()) :: map()
  def city_by_name!(city_name) when is_binary(city_name) do
    normalized = normalize(city_name)

    Enum.find(@cities, fn city ->
      normalize(city.city) == normalized
    end) ||
      raise ArgumentError, "unknown weather demo city: #{inspect(city_name)}"
  end

  @doc "Fetches a turn fixture by id."
  @spec turn!(atom()) :: map()
  def turn!(id) when is_atom(id) do
    Enum.find(@turns, &(&1.id == id)) ||
      raise ArgumentError, "unknown weather demo turn id: #{inspect(id)}"
  end

  @doc "Renders the prompt text for a turn and city."
  @spec prompt(atom(), map()) :: String.t()
  def prompt(turn_id, city_fixture) do
    turn = turn!(turn_id)

    if turn.requires_city_in_prompt? do
      turn.prompt_template
      |> String.replace("%{city}", city_fixture.city)
    else
      turn.prompt_template
    end
  end

  defp normalize(value), do: value |> String.downcase() |> String.trim()
end
