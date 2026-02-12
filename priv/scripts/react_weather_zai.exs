# priv/scripts/react_weather_zai.exs
#
# Tracer-bullet MVP: ReAct weather agent using zai:glm-5
#
# Run with: ZAI_API_KEY=your_key mix run priv/scripts/react_weather_zai.exs

Logger.configure(level: :warning)

# Colors for terminal output
defmodule Colors do
  def cyan(text), do: "\e[36m#{text}\e[0m"
  def green(text), do: "\e[32m#{text}\e[0m"
  def yellow(text), do: "\e[33m#{text}\e[0m"
  def dim(text), do: "\e[2m#{text}\e[0m"
end

# Attach telemetry handler to show streaming tokens
#
# The jido agent_server telemetry at [:jido, :agent_server, :signal, :start]
# only includes signal_type in metadata (not the full signal struct).
# We hook into the react strategy telemetry instead for iteration visibility,
# and use a process-level intercept for streaming deltas.
:telemetry.attach_many(
  "weather-agent-react",
  [
    [:jido, :ai, :react, :start],
    [:jido, :ai, :react, :iteration],
    [:jido, :ai, :react, :complete],
    [:jido, :ai, :tool, :execute, :start],
    [:jido, :ai, :tool, :execute, :stop]
  ],
  fn event, measurements, metadata, _config ->
    case event do
      [:jido, :ai, :react, :start] ->
        IO.write(Colors.dim("  [react] started\n"))

      [:jido, :ai, :react, :iteration] ->
        iter = Map.get(metadata, :iteration, "?")
        IO.write(Colors.dim("  [react] iteration #{iter}\n"))

      [:jido, :ai, :react, :complete] ->
        reason = Map.get(metadata, :termination_reason, :unknown)
        duration = Map.get(measurements, :duration, 0)
        IO.write(Colors.dim("  [react] complete — #{reason} (#{duration}ms)\n"))

      [:jido, :ai, :tool, :execute, :start] ->
        tool = Map.get(metadata, :tool_name, "?")
        IO.write(Colors.yellow("  [tool] calling #{tool}...\n"))

      [:jido, :ai, :tool, :execute, :stop] ->
        tool = Map.get(metadata, :tool_name, "?")
        IO.write(Colors.green("  [tool] #{tool} done\n"))

      _ ->
        :ok
    end
  end,
  nil
)

# Ensure ZAI_API_KEY is set
api_key =
  System.get_env("ZAI_API_KEY") ||
    raise """
    Missing ZAI_API_KEY environment variable.

    Usage:
      ZAI_API_KEY=your_key mix run priv/scripts/react_weather_zai.exs
    """

# Configure zai provider at runtime
existing_providers = Application.get_env(:jido_ai, :providers, [])
Application.put_env(:jido_ai, :providers, Keyword.merge(existing_providers, zai: [api_key: api_key]))

# Define a minimal ReAct weather agent pinned to zai:glm-5
defmodule TracerBullet.WeatherAgent do
  @moduledoc false
  use Jido.AI.ReActAgent,
    name: "tracer_bullet_weather",
    description: "ReAct weather agent — zai:glm-5 tracer bullet",
    tools: [
      Jido.Tools.Weather,
      Jido.Tools.Weather.ByLocation,
      Jido.Tools.Weather.Forecast,
      Jido.Tools.Weather.HourlyForecast,
      Jido.Tools.Weather.CurrentConditions,
      Jido.Tools.Weather.Geocode
    ],
    model: "zai:glm-5",
    max_iterations: 10,
    system_prompt: """
    You are a helpful weather assistant.

    IMPORTANT: The weather tools ONLY accept "lat,lng" coordinates (e.g., "41.8781,-87.6298").
    They do NOT accept city names, addresses, or zip codes directly.

    When answering weather questions:
    1. Determine the location - ask for clarification if ambiguous
    2. Convert the location to coordinates:
       - Use weather_geocode to convert city/state/address to coordinates
       - Or use these common US city coordinates:
         - New York: 40.7128,-74.0060
         - Los Angeles: 34.0522,-118.2437
         - Chicago: 41.8781,-87.6298
         - Seattle: 47.6062,-122.3321
         - Denver: 39.7392,-104.9903
         - Miami: 25.7617,-80.1918
         - Boston: 42.3601,-71.0589
    3. Fetch the appropriate forecast using the coordinates
    4. Provide practical advice based on conditions

    Be conversational and helpful, not just a data dump.
    """

  @default_timeout 120_000

  @spec get_conditions(pid(), String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def get_conditions(pid, location, opts \\ []) do
    ask_sync(
      pid,
      "What are the current conditions in #{location}?",
      Keyword.put_new(opts, :timeout, @default_timeout)
    )
  end

  @spec need_umbrella?(pid(), String.t(), keyword()) :: {:ok, String.t()} | {:error, term()}
  def need_umbrella?(pid, location, opts \\ []) do
    ask_sync(
      pid,
      "Should I bring an umbrella in #{location} today?",
      Keyword.put_new(opts, :timeout, @default_timeout)
    )
  end
end

# Start the default Jido instance
{:ok, _} = Jido.start()
IO.puts(Colors.green("✓ Jido.start() succeeded"))

alias TracerBullet.WeatherAgent

# Start the weather agent
IO.puts("Starting WeatherAgent (zai:glm-5)...")
{:ok, pid} = Jido.start_agent(Jido.default_instance(), WeatherAgent)
IO.puts(Colors.green("✓ Agent started: #{inspect(pid)}"))

# Test get_conditions
IO.puts("\n" <> Colors.cyan("--- Testing get_conditions/3 for Denver ---"))
IO.puts("")

case WeatherAgent.get_conditions(pid, "Denver", timeout: 120_000) do
  {:ok, conditions} ->
    IO.puts("\n#{conditions}")
    IO.puts("\n" <> Colors.green("✓ get_conditions completed"))

  {:error, reason} ->
    IO.puts("\n✗ get_conditions failed: #{inspect(reason)}")
end

# Test need_umbrella?
IO.puts("\n" <> Colors.cyan("--- Testing need_umbrella?/3 for Seattle ---"))
IO.puts("")

case WeatherAgent.need_umbrella?(pid, "Seattle", timeout: 120_000) do
  {:ok, advice} ->
    IO.puts("\n#{advice}")
    IO.puts("\n" <> Colors.green("✓ need_umbrella? completed"))

  {:error, reason} ->
    IO.puts("\n✗ need_umbrella? failed: #{inspect(reason)}")
end

IO.puts("\n" <> Colors.green("--- All tests complete ---"))
Jido.stop_agent(Jido.default_instance(), pid)
IO.puts(Colors.green("✓ Agent stopped"))
Jido.stop()
IO.puts(Colors.green("✓ Jido stopped"))
