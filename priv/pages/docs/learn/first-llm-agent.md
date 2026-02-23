%{
  title: "Build Your First LLM Agent",
  description: "Learn how to integrate LLMs into your Jido agents using jido_ai, configure providers, and execute AI-powered commands.",
  category: :docs,
  order: 12,
  prerequisites: ["/docs/learn/first-agent"],
}
---
In the [First Agent tutorial](/docs/learn/first-agent), you built a simple agent that performed a pure computation. Now, you'll give that agent intelligence by connecting it to a Large Language Model (LLM).

Jido's architecture treats AI as an optional, composable capability. This guide shows you how to add the necessary packages, configure a model provider, and execute your first LLM-powered command within the Jido runtime.

## Add AI Dependencies

Jido's core is model-agnostic. To add LLM capabilities, you'll use two additional packages:

*   `jido_ai`: Provides the integration layer between Jido agents and LLM reasoning strategies.
*   `req_llm`: A flexible HTTP client for interacting with various LLM provider APIs.

Add them to your `mix.exs` file:

```elixir
def deps do
  [
    {:jido, "~> 0.1"},
    {:jido_ai, "~> 0.1"},
    {:req_llm, "~> 0.1"}
  ]
end
```

Then, fetch the new dependencies from the command line:

```sh
mix deps.get
```

## Configure a Provider

Next, you need to tell `req_llm` how to connect to an LLM provider, such as OpenAI or Anthropic. This configuration includes API keys, model names, and other provider-specific settings.

Add the following to your `config/runtime.exs` file. This example configures OpenAI's `gpt-4o-mini` model.

```elixir
import Config

config :req_llm,
  clients: [
    openai: [
      # It's best practice to load secrets from environment variables.
      api_key: {:system, "OPENAI_API_KEY"},
      # Define a model alias for easy reference in your code.
      models: %{
        "default" => "gpt-4o-mini"
      }
    ]
  ]
```

Make sure to set the `OPENAI_API_KEY` environment variable before running your application. For more advanced configurations, including multiple providers, see the [Configuration reference](/docs/reference/configuration).

## Choose a Strategy

A **Strategy** in `jido_ai` is a module that defines how an agent reasons and interacts with an LLM. It handles prompt construction, response parsing, and can orchestrate complex patterns like ReAct (Reason-Act) or Chain-of-Thought.

To enable a strategy, you'll modify the agent you built in the previous tutorial. Let's update `lib/my_app/greeter.ex` to use the `Jido.AI.Strategies.ReAct` strategy.

```elixir
defmodule MyApp.Greeter do
  use Jido.Agent

  # Add this line to enable the ReAct AI strategy
  use Jido.AI, strategy: Jido.AI.Strategies.ReAct

  @impl true
  def init(_args) do
    {:ok, %{count: 0}}
  end

  @impl true
  def cmd(:greet, state) do
    # We'll update this command in the next step.
    {:pure, "Hello", state}
  end

  @impl true
  def apply({:greet, "Hello"}, state) do
    {:ok, %{state | count: state.count + 1}}
  end
end
```

By adding `use Jido.AI`, you've equipped your agent with the ability to process special `:ai` commands, which will be handled by the specified strategy.

## Run Your First LLM Command

Now, let's change the `:greet` command to use the LLM. Instead of returning a hardcoded string, `cmd/2` will return an `{:ai, prompt}` tuple. The `Jido.AI` integration will intercept this tuple and execute the LLM call.

Update your `cmd/2` function to ask the LLM for a creative greeting.

```elixir
# in lib/my_app/greeter.ex

@impl true
def cmd(:greet, _state) do
  prompt = "Generate a creative, one-sentence greeting for a new user."
  {:ai, prompt}
end
```

The `apply/2` function also needs to be updated to handle the result from the LLM. The strategy will return the LLM's text response as the result.

```elixir
# in lib/my_app/greeter.ex

@impl true
def apply({:greet, llm_greeting}, state) when is_binary(llm_greeting) do
  IO.puts("LLM Greeting: #{llm_greeting}")
  {:ok, %{state | count: state.count + 1}}
end
```

Now, run it in an `iex` session:

```elixir
# iex -S mix
iex> {:ok, agent} = Jido.Agent.start_link(MyApp.Greeter, [])
{:ok, #PID<..._>}

iex> Jido.Agent.run_command(agent, :greet)
LLM Greeting: Welcome aboard, adventurer of the digital frontier!
{:ok, %{count: 1}}
```

You just executed your first AI-powered agent command. The agent sent a prompt to the LLM and received a structured response, all within the Jido runtime.

## What Just Happened?

Let's trace the flow of the command you just ran. Understanding this separation of concerns is key to building reliable AI systems with Jido.

1.  `Jido.Agent.run_command(agent, :greet)` sent the `:greet` command to your agent process.
2.  Your agent's `cmd(:greet, state)` function was called. It returned the tuple `{:ai, "Generate a..."}`.
3.  Crucially, `cmd/2` did **not** perform the HTTP request. It remained a pure function, describing the *intent* to call an AI model.
4.  The `use Jido.AI` macro intercepted this special tuple. It delegated the work to the configured strategy, `Jido.AI.Strategies.ReAct`.
5.  The `ReAct` strategy constructed the final API request, called the OpenAI model you configured, and waited for the response.
6.  Once the response was received, the strategy parsed it to extract the core text.
7.  Finally, the Jido runtime invoked your agent's `apply({:greet, "Welcome aboard..."}, state)` function with the result from the LLM.

This architecture maintains Jido's core principle: `cmd/2` describes work, and the runtime executes it. The AI strategy acts as a specialized part of the runtime, handling the side effect of the network call while keeping your business logic clean and testable.

## Next Steps

You've successfully integrated an LLM into a Jido agent. The next steps involve building more complex, multi-step workflows and giving your agents tools to interact with the outside world.

*   **Build a Workflow**: Learn how to coordinate multiple agents in a [First Workflow](/docs/learn/first-workflow).
*   **Explore AI Capabilities**: Dive deeper into strategies and tool use in the [`jido_ai` reference](/docs/reference/packages/jido-ai).

