%{
  title: "Your first LLM agent",
  description: "Add LLM reasoning to a Jido agent with jido_ai, configure a provider, and run your first AI-enhanced command.",
  category: :docs,
  order: 40,
  tags: [:docs, :getting_started, :tutorial, :ai, :livebook],
  draft: false,
  legacy_paths: ["/docs/learn/first-llm-agent"],
  learning_outcomes: [
    "Install jido_ai and req_llm in a self-contained Livebook",
    "Configure a provider key for notebook execution",
    "Start the default Jido runtime and run your first AI-enhanced command"
  ],
  prerequisites: ["/docs/getting-started/first-agent"],
  livebook: %{
    runnable: true,
    required_env_vars: ["OPENAI_API_KEY"],
    requires_network: true,
    setup_instructions: "Set OPENAI_API_KEY or LB_OPENAI_API_KEY before running the request cell."
  }
}
---
## Setup

This notebook is self-contained: install the dependencies, configure a provider key, start the default Jido runtime, and send one prompt through an AI agent. If you already completed [Your first agent](/docs/getting-started/first-agent), still run this notebook top to bottom because it defines its own module.

```elixir
Mix.install([
  {{mix_dep:jido}},
  {{mix_dep:jido_ai}},
  {{mix_dep:req_llm}}
])

Logger.configure(level: :warning)
```

## Configure credentials

In Livebook, store `OPENAI_API_KEY` as a secret. Livebook exposes that secret as `LB_OPENAI_API_KEY` inside the notebook, so this cell checks both names.

```elixir
openai_key = System.get_env("LB_OPENAI_API_KEY") || System.get_env("OPENAI_API_KEY")

configured? =
  if is_binary(openai_key) do
    ReqLLM.put_key(:openai_api_key, openai_key)
    true
  else
    IO.puts("Set OPENAI_API_KEY or LB_OPENAI_API_KEY before running the request cell.")
    false
  end
```

## Define the agent

`use Jido.AI.Agent` keeps the module declarative: describe the agent, choose a model, and provide a system prompt. This first example does not use tools, so the only new capability is the LLM call.

```elixir
defmodule MyAgentApp.Greeter do
  use Jido.AI.Agent,
    name: "greeter",
    description: "Generates a friendly greeting",
    tools: [],
    model: :fast,
    system_prompt: """
    You are a friendly greeter.
    Generate a short, warm welcome message.
    One or two sentences maximum.
    """
end
```

`model: :fast` uses the default fast model alias from `jido_ai`. You can swap in a provider-specific string later, but the alias keeps the tutorial portable.

## Start the runtime and agent

`Jido.start/0` is the notebook-friendly runtime helper. It is safe to call more than once, so rerunning this cell does not force you to restart the notebook. `Jido.start_agent/3` then starts your agent inside that runtime.

```elixir
{:ok, _} = Jido.start()
runtime = Jido.default_instance()
agent_id = "greeter-demo-#{System.unique_integer([:positive])}"

{:ok, pid} = Jido.start_agent(runtime, MyAgentApp.Greeter, id: agent_id)
```

## Ask the agent

Send one prompt with `ask_sync/3`. The return value is `{:ok, text}` on success or `{:error, reason}` if the provider call fails.

```elixir
greeting =
  if configured? do
    MyAgentApp.Greeter.ask_sync(
      pid,
      "Say hello to someone just getting started with Jido.",
      timeout: 30_000
    )
  else
    {:skip, :no_openai_key}
  end

IO.inspect(greeting, label: "Greeting")
```

```elixir
case greeting do
  {:ok, text} ->
    IO.puts(text)

  {:error, reason} ->
    IO.puts("Greeting failed: #{inspect(reason)}")

  {:skip, :no_openai_key} ->
    IO.puts("Skipped request. Set OPENAI_API_KEY or LB_OPENAI_API_KEY to run it.")
end
```

## Inspect the last request

Show the success path first, then inspect the runtime state. `Jido.AgentServer.status/1` gives you the current snapshot for the running agent process.

```elixir
snapshot =
  case Jido.AgentServer.status(pid) do
    {:ok, status} ->
      %{
        done?: status.snapshot.done?,
        result: status.snapshot.result,
        model: status.snapshot.details[:model]
      }

    other ->
      other
  end

IO.inspect(snapshot, label: "Snapshot")
```

## What happened

1. `Jido.start/0` started the default runtime used for scripts and Livebook.
2. `Jido.start_agent/3` started `MyAgentApp.Greeter` as a supervised agent process.
3. `ask_sync/3` combined the system prompt and your message, then sent the request through `req_llm`.
4. `Jido.AgentServer.status/1` exposed the resulting snapshot so you could inspect the completed request.

The agent module stays free of provider-specific HTTP code. The runtime handles request execution, while your module stays focused on behavior.

## Moving this into a Mix project

Keep the agent module the same, add the dependencies to `mix.exs`, configure the provider key in `config/runtime.exs`, and supervise a `use Jido` module in your application:

```elixir
defmodule MyAgentApp.Jido do
  use Jido, otp_app: :my_agent_app
end
```

```elixir
children = [
  {MyAgentApp.Jido, name: MyAgentApp.Jido}
]
```

Then start agents against that named runtime:

```
{:ok, pid} = Jido.start_agent(MyAgentApp.Jido, MyAgentApp.Greeter, id: "greeter-1")
MyAgentApp.Greeter.ask_sync(pid, "Say hello to the production app.", timeout: 30_000)
```

## Next steps

- Continue to [Build an AI Chat Agent](/docs/learn/ai-chat-agent) for multi-turn conversation on the same agent process.
- Continue to [AI Agent with Tools](/docs/learn/ai-agent-with-tools) when you want the model to call actions.
- Review the [Chat Response recipe](/docs/guides/cookbook/chat-response) for the smallest request-response API.
