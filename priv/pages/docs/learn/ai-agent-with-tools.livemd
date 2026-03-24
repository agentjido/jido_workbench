%{
  title: "AI agent with tools",
  description: "Build a ReAct agent that reasons iteratively and calls tools to answer questions.",
  category: :docs,
  order: 30,
  legacy_paths: ["/docs/learn/tool-use"],
  tags: [:docs, :learn, :ai, :tools, :react, :livebook],
  draft: false,
  prerequisites: ["/docs/getting-started/first-llm-agent"],
  learning_outcomes: [
    "Define tool Actions that an AI agent can call",
    "Start a tool-using agent in the default Livebook runtime",
    "Inspect tool activity after a successful answer"
  ],
  livebook: %{
    runnable: false,
    required_env_vars: ["OPENAI_API_KEY"],
    requires_network: true,
    setup_instructions: "Set OPENAI_API_KEY or LB_OPENAI_API_KEY before running the request cells."
  }
}
---
## Setup

This notebook is self-contained. Install the dependencies, configure the provider key, start one agent in the default Jido runtime, then let that agent call tools as needed. If you want the smaller model-only introduction first, review [Your first LLM agent](/docs/getting-started/first-llm-agent).

```elixir
Mix.install([
  {{mix_dep:jido}},
  {{mix_dep:jido_ai}},
  {{mix_dep:req_llm}}
])

Logger.configure(level: :warning)
```

## Configure credentials

Set your OpenAI API key as a Livebook secret named `OPENAI_API_KEY`. Livebook exposes that secret as `LB_OPENAI_API_KEY`, so this cell checks both names.

```elixir
openai_key = System.get_env("LB_OPENAI_API_KEY") || System.get_env("OPENAI_API_KEY")

configured? =
  if is_binary(openai_key) do
    ReqLLM.put_key(:openai_api_key, openai_key)
    true
  else
    IO.puts("Set OPENAI_API_KEY or LB_OPENAI_API_KEY before running the request cells.")
    false
  end
```

## Beyond simple chat

In the first LLM tutorial, your agent generated text from a prompt. That works for greetings and summaries, but real tasks require the agent to fetch data, call APIs, and combine results. Jido solves this with tool-calling Actions and a ReAct reasoning loop.

By the end of this tutorial, you will have an agent that answers weather questions like this:

```
{:ok, _} = Jido.start()
runtime = Jido.default_instance()
{:ok, pid} = Jido.start_agent(runtime, MyApp.WeatherAgent, id: "weather-demo")

{:ok, answer} =
  MyApp.WeatherAgent.ask_sync(
    pid,
    "What's the weather in Denver? Should I bring a jacket?",
    timeout: 60_000
  )

IO.puts(answer)
```

The agent geocodes "Denver" to coordinates, resolves those coordinates into the NWS URLs it needs, fetches the forecast from the National Weather Service API, and synthesizes practical advice. All tool calls happen automatically through the ReAct loop.

> Output varies between runs because the LLM generates different responses and real weather data changes.

## Define the Tool Actions

In Jido, every tool is a `Jido.Action`. The same module works as a programmatic action you call from code and as an LLM-callable tool. The LLM sees each Action's `name`, `description`, and `schema`, then decides when to invoke it.

Jido ships weather tools that wrap the free NWS (National Weather Service) API. No API key is needed for the weather data itself.

`Jido.Tools.Weather.Geocode` converts a city name to coordinates:

```elixir
Jido.Tools.Weather.Geocode.run(
  %{location: "Denver, CO"},
  %{}
)
```

This returns `{:ok, %{lat: "39.7...", lng: "-104.9..."}}`. The geocode tool uses OpenStreetMap Nominatim, which is free and unauthenticated.

`Jido.Tools.Weather.LocationToGrid` resolves a `"lat,lng"` coordinate pair into the NWS URLs you need for downstream weather lookups:

```elixir
{:ok, grid_info} =
  Jido.Tools.Weather.LocationToGrid.run(
    %{location: "39.7392,-104.9903"},
    %{}
  )
```

Then `Jido.Tools.Weather.Forecast` uses the forecast URL returned by `LocationToGrid`:

```elixir
Jido.Tools.Weather.Forecast.run(
  %{forecast_url: grid_info.urls.forecast},
  %{}
)
```

For current conditions, use the observation-stations URL from that same lookup:

```elixir
Jido.Tools.Weather.CurrentConditions.run(
  %{observation_stations_url: grid_info.urls.observation_stations},
  %{}
)
```

You can also write custom Tool Actions. Here is a temperature converter that the agent can call when needed:

```elixir
defmodule MyApp.TemperatureConverter do
  use Jido.Action,
    name: "convert_temperature",
    description: "Convert between Fahrenheit and Celsius",
    schema: [
      value: [type: :float, required: true, doc: "Temperature value"],
      from: [
        type: {:in, [:fahrenheit, :celsius]},
        required: true,
        doc: "Source unit"
      ],
      to: [
        type: {:in, [:fahrenheit, :celsius]},
        required: true,
        doc: "Target unit"
      ]
    ]

  @impl true
  def run(%{value: v, from: :fahrenheit, to: :celsius}, _ctx) do
    {:ok, %{result: Float.round((v - 32) * 5 / 9, 1), unit: "°C"}}
  end

  def run(%{value: v, from: :celsius, to: :fahrenheit}, _ctx) do
    {:ok, %{result: Float.round(v * 9 / 5 + 32, 1), unit: "°F"}}
  end

  def run(%{value: v, from: same, to: same}, _ctx) do
    unit = if same == :celsius, do: "°C", else: "°F"
    {:ok, %{result: v, unit: unit}}
  end
end
```

The `schema` with `doc` strings is what the LLM reads to understand each parameter. Descriptive names and clear documentation directly improve tool-calling accuracy.

## Build the AI Agent

Define the agent with `use Jido.AI.Agent`, listing the tools it can call and the system prompt that guides its reasoning.

```elixir
defmodule MyApp.WeatherAgent do
  use Jido.AI.Agent,
    name: "weather_agent",
    description: "Weather assistant with tool access",
    tools: [
      Jido.Tools.Weather.Geocode,
      Jido.Tools.Weather.LocationToGrid,
      Jido.Tools.Weather.Forecast,
      Jido.Tools.Weather.CurrentConditions,
      MyApp.TemperatureConverter
    ],
    model: :fast,
    max_iterations: 6,
    system_prompt: """
    You are a helpful weather assistant.
    Use weather_geocode to convert city names to coordinates first.
    Then use weather_location_to_grid to get the NWS forecast and observation URLs.
    Use the forecast URL for forecasts and the observation stations URL for current conditions.
    Provide practical, conversational advice.
    """
end
```

Key configuration options:

- **tools** lists the `Jido.Action` modules available to the LLM. The runtime converts each Action's schema to JSON Schema for the provider's tool-calling protocol.
- **model** selects the LLM. `:fast` keeps the notebook portable across provider backends.
- **max_iterations** caps the number of ReAct reasoning loops. Set this high enough for multi-step tool chains but low enough to prevent runaway costs.
- **system_prompt** tells the LLM how to use the tools. Include constraints like coordinate format requirements here.

## The ReAct loop

When you send a query, the agent runs a Reason-Act loop:

1. Your question and the system prompt are sent to the LLM, along with JSON Schema definitions of all available tools.
2. The LLM reasons about the question and either responds directly or emits a `tool_call` with a tool name and arguments.
3. Jido executes the matching Action's `run/2` with the LLM-provided arguments.
4. The tool result is sent back to the LLM as additional context.
5. Steps 2 through 4 repeat until the LLM produces a final text answer or `max_iterations` is reached.

For a question like "What's the weather in Denver?", the loop typically runs three iterations: one to geocode "Denver" into coordinates, one to resolve those coordinates into NWS URLs, and one to fetch the forecast or current conditions. The LLM then synthesizes the raw weather data into a conversational answer.

The `max_iterations` bound prevents infinite loops. If the agent exhausts its iterations without a final answer, `ask_sync/3` returns `{:error, reason}`.

## Start the runtime and agent

```elixir
{:ok, _} = Jido.start()
runtime = Jido.default_instance()
agent_id = "weather-demo-#{System.unique_integer([:positive])}"

{:ok, pid} = Jido.start_agent(runtime, MyApp.WeatherAgent, id: agent_id)
```

## Ask the agent

Show the success path first: start with one weather question, then follow up on the same `pid`.

```elixir
forecast_answer =
  if configured? do
    MyApp.WeatherAgent.ask_sync(
      pid,
      "What's the weather in Chicago? Do I need an umbrella?",
      timeout: 60_000
    )
  else
    {:skip, :no_openai_key}
  end

IO.inspect(forecast_answer, label: "Forecast answer")
```

The timeout should be generous because the agent makes multiple LLM calls and external API requests in sequence. 60 seconds is reasonable for a three-step weather lookup chain.

Try a follow-up query on the same agent process:

```elixir
follow_up_answer =
  if configured? do
    MyApp.WeatherAgent.ask_sync(
      pid,
      "What about Seattle?",
      timeout: 60_000
    )
  else
    {:skip, :no_openai_key}
  end

IO.inspect(follow_up_answer, label: "Follow-up answer")
```

## Inspect tool activity

Once the happy path works, inspect the runtime snapshot to see which tool calls the agent made.

```elixir
tool_activity =
  case Jido.AgentServer.status(pid) do
    {:ok, status} ->
      %{
        result: status.snapshot.result,
        tool_calls: status.snapshot.details[:tool_calls] || [],
        model: status.snapshot.details[:model]
      }

    other ->
      other
  end

IO.inspect(tool_activity, label: "Tool activity")
```

The `tool_calls` list should show actions like `weather_geocode` and `weather_location_to_grid` when the model needs them.

## Helper methods

Wrap `ask_sync/3` in domain-specific functions to give callers a clean API instead of raw string prompts:

```elixir
defmodule MyApp.WeatherAgent do
  use Jido.AI.Agent,
    name: "weather_agent",
    description: "Weather assistant with tool access",
    tools: [
      Jido.Tools.Weather.Geocode,
      Jido.Tools.Weather.LocationToGrid,
      Jido.Tools.Weather.Forecast,
      Jido.Tools.Weather.CurrentConditions,
      MyApp.TemperatureConverter
    ],
    model: :fast,
    max_iterations: 6,
    system_prompt: """
    You are a helpful weather assistant.
    Use weather_geocode to convert city names to coordinates first.
    Then use weather_location_to_grid to get the NWS forecast and observation URLs.
    Use the forecast URL for forecasts and the observation stations URL for current conditions.
    Provide practical, conversational advice.
    """

  @spec get_forecast(pid(), String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def get_forecast(pid, location, opts \\ []) do
    query =
      "Get the weather forecast for #{location}. " <>
        "Include temperature, precipitation, and recommendations."

    ask_sync(pid, query, Keyword.put_new(opts, :timeout, 60_000))
  end

  @spec get_conditions(pid(), String.t(), keyword()) ::
          {:ok, String.t()} | {:error, term()}
  def get_conditions(pid, location, opts \\ []) do
    ask_sync(
      pid,
      "What are the current conditions in #{location}?",
      Keyword.put_new(opts, :timeout, 60_000)
    )
  end
end
```

These functions delegate to `ask_sync/3` internally and return the same `{:ok, answer}` or `{:error, reason}` tuples. Callers never construct prompt strings directly:

```elixir
{:ok, _} = Jido.start()
runtime = Jido.default_instance()
{:ok, pid} = Jido.start_agent(runtime, MyApp.WeatherAgent, id: "weather-helper-demo")
{:ok, forecast} = MyApp.WeatherAgent.get_forecast(pid, "Portland, OR")
IO.puts(forecast)
```

## Configuration options

`Jido.AI.Agent` accepts additional options that control tool execution and observability.

**Tool execution:**

```elixir
tool_execution_options = [
  tool_timeout_ms: 15_000,
  tool_max_retries: 1,
  tool_retry_backoff_ms: 200
]
```

- `tool_timeout_ms` sets the maximum time for a single tool call. Default is sufficient for most APIs, but increase it for slow external services.
- `tool_max_retries` controls how many times a failed tool call is retried before the error is returned to the LLM.
- `tool_retry_backoff_ms` is the delay between retries.

**Observability:**

```elixir
observability_options = %{
  emit_telemetry?: true,
  emit_lifecycle_signals?: true,
  redact_tool_args?: true,
  emit_llm_deltas?: true
}
```

These flags enable telemetry events for each iteration, tool call, and LLM response. Set `redact_tool_args?` to `true` when tool arguments may contain sensitive data.

**Request policy:**

```elixir
request_policy = :reject
```

The `request_policy` controls what happens when a new request arrives while one is already running. `:reject` returns an error immediately. This prevents concurrent LLM calls on the same agent process.

## Next steps

- Compare reasoning strategies in [Reasoning strategies compared](/docs/learn/reasoning-strategies-compared).
- Learn how Actions compose into pipelines in [Build your first workflow](/docs/learn/first-workflow).
- Add multi-turn conversation context in [Build an AI chat agent](/docs/learn/ai-chat-agent).
