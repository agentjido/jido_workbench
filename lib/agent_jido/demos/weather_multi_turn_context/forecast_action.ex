defmodule AgentJido.Demos.WeatherMultiTurnContext.ForecastAction do
  @moduledoc """
  Deterministic local weather tool used by the multi-turn context demo.
  """

  use Jido.Action,
    name: "weather_multi_turn_context_forecast",
    description: "Returns deterministic forecast context for a local weather assistant demo",
    schema: [
      city: [type: :string, required: true],
      turn: [type: {:in, [:forecast, :umbrella, :activities]}, required: true],
      attempt: [type: :integer, default: 1]
    ]

  alias AgentJido.Demos.WeatherMultiTurnContext.Fixtures

  @impl true
  def run(%{city: city, turn: :umbrella, attempt: 1}, _context) do
    city_fixture = Fixtures.city_by_name!(city)

    {:error,
     %{
       type: :busy,
       city: city_fixture.city,
       retry_after_ms: 300,
       detail: "Deterministic busy response on the first umbrella lookup."
     }}
  end

  def run(%{city: city, turn: turn, attempt: attempt}, _context) when turn in [:forecast, :umbrella, :activities] do
    city_fixture = Fixtures.city_by_name!(city)

    {:ok,
     %{
       city: city_fixture.city,
       period: city_fixture.period,
       condition: city_fixture.condition,
       temperature: city_fixture.temperature,
       umbrella: city_fixture.umbrella,
       outdoor_activity: city_fixture.outdoor_activity,
       indoor_activity: city_fixture.indoor_activity,
       backup_recommendation: city_fixture.backup_recommendation,
       turn: turn,
       attempt: attempt
     }}
  end
end
