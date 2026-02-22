%{
  title: "Installation and Setup",
  description: "Get Jido installed and validated in a new or existing Elixir project with a clean production-safe baseline.",
  category: :docs,
  order: 10,
  audience: :beginner,
  learning_outcomes: ["Add core Jido dependencies to mix.exs", "Configure runtime secrets and provider settings safely", "Run a smoke test proving the local environment is ready"],
}
---
### What This Solves

This guide provides the foundation for building reliable agents with Jido. It solves the initial setup problem by walking you through adding Jido to your project, configuring it for production safety, and verifying that the core runtime is ready to use. By following these steps, you establish a clean, correct baseline for all future agent development.

### How to Use It

To get started, you will add the core `jido` and `jido_ai` packages to your `mix.exs` file. Next, you will configure your LLM provider API keys securely in `config/runtime.exs` using environment variables. Finally, you will run a simple command in an `IEx` session to confirm the system is correctly installed and configured.

### Examples

After completing this guide, your project will have the necessary dependencies and configuration to start building agents. Your setup will resemble the following snippets.

**`mix.exs` Dependencies:**
```elixir
defp deps do
  [
    {:jido, "~> 2.0.0"},
    {:jido_ai, "~> 2.0.0"}
    # ... other dependencies
  ]
end
```

**`config/runtime.exs` Secret Configuration:**
```elixir
import Config

# Configure Jido AI with your provider API key
config :jido_ai, :providers, 
  openai: [
    api_key: System.get_env("OPENAI_API_KEY")
  ]
```

### References and Next Steps

With your environment configured, you are ready to build.

*   **Build Your First Agent**: Follow our step-by-step tutorial in [Your First Agent](/docs/learn/first-agent).
*   **Explore Use Cases**: See persona-based guides in [Quickstarts](/docs/learn/quickstarts-by-persona).
*   **Review All Options**: Dive deep into all available settings in the [Configuration Reference](/docs/reference/configuration).

### Prerequisites

Before you begin, ensure you have an Elixir project ready. You will need:

*   Elixir `~> 1.17` or newer installed.
*   An existing Elixir application. If you don't have one, create one with `mix new my_agent_app`.
*   An API key from an LLM provider, such as OpenAI. You will need this to verify the AI-related components.

### Add Dependencies

The Jido ecosystem is a set of composable packages. For most use cases, you will start with the core runtime (`jido`) and the AI integration layer (`jido_ai`).

Add the following to the `deps` function in your `mix.exs` file:

```elixir
defp deps do
  [
    {:jido, "~> 2.0.0"},
    {:jido_ai, "~> 2.0.0"}
  ]
end
```

We recommend using optimistic version requirements (`~>`) to receive compatible updates automatically. After adding the dependencies, fetch them from Hex:

```shell
mix deps.get
```

### Configure Runtime

To protect secrets like API keys, you should always configure them in `config/runtime.exs`, which is not checked into source control. This file reads from environment variables to configure your application at boot time.

Add the following to your `config/runtime.exs` file to configure the OpenAI provider for `jido_ai`:

```elixir
import Config

# This file is loaded only at runtime.
#
# It is perfect for sensitive data like API keys and secrets.
if config_env() == :prod do
  # Add production-specific configurations here
end

# Example for configuring the OpenAI provider in jido_ai
# Ensure the OPENAI_API_KEY environment variable is set in your shell.
api_key = System.get_env("OPENAI_API_KEY")

if api_key do
  config :jido_ai, :providers, 
    openai: [
      api_key: api_key
    ]
else
  # Optional: Warn if the key is missing during development
  if Mix.env() != :prod do
    IO.puts(:stderr, "Warning: OPENAI_API_KEY environment variable not set.")
  end
end
```

Before proceeding, make sure to export the environment variable in your terminal session:

```shell
export OPENAI_API_KEY="your-api-key-here"
```

### Verify Installation

To confirm that Jido is installed and configured correctly, you can run a quick smoke test in an interactive Elixir shell. This test will attempt to access the configuration you just set up.

Start an `IEx` session within your project's directory:

```shell
iex -S mix
```

Once inside `IEx`, check the application environment for `:jido_ai`:

```elixir
Application.get_env(:jido_ai, :providers)
```

If the setup is correct, you will see your configuration printed:

```elixir
[openai: [api_key: "your-api-key-here"]]
```

#### Common Setup Failures

If you encounter issues, check these common problems first.

*   **`UndefinedFunctionError` for a Jido module:** This usually means dependencies were not fetched or compiled. Run `mix deps.get` and `mix compile` again.
*   **Verification returns `nil`:** This indicates your `config/runtime.exs` is not being loaded or the environment variable is not set. Confirm that `OPENAI_API_KEY` is exported in the same shell session where you run `iex -S mix`.
*   **Dependency Resolution Errors:** If `mix deps.get` fails, you may have a version conflict with another library. Run `mix deps.tree` to inspect the dependency graph and identify the conflict.

