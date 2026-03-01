%{
  title: "Tool use",
  description: "Turn Actions into LLM-callable tools and integrate function calling into agent workflows.",
  category: :docs,
  order: 24,
  tags: [:docs, :learn, :tools, :ai],
  draft: false
}
---
Every Jido Action doubles as an LLM tool definition. The same Zoi schema that validates runtime input also generates the JSON Schema that LLMs use to understand available parameters. You define the contract once - both human callers and AI agents use the same interface.

## Actions as tools

Actions already carry a name, description, and schema. These map directly to the tool definition format LLMs expect. When you define an Action with Zoi types, each field's `description` option becomes the parameter description the LLM sees.

```elixir
defmodule MyApp.LookupCustomer do
  use Jido.Action,
    name: "lookup_customer",
    description: "Finds a customer by email address",
    schema: Zoi.object(%{
      email: Zoi.string(description: "The customer's email address")
    })

  @impl true
  def run(params, _context) do
    customer = MyApp.Customers.find_by_email(params.email)
    {:ok, %{customer_id: customer.id, name: customer.name}}
  end
end
```

This module works as a regular programmatic action and as an AI tool. No adapter layer or separate definition required.

## Converting to tool definitions

Call `to_tool/0` on any Action module to get a generic tool map with the name, description, and JSON Schema. To convert multiple actions into structs compatible with `req_llm`, use `Jido.AI.ToolAdapter.from_actions/1`.

```elixir
tool_map = MyApp.LookupCustomer.to_tool()

tools = Jido.AI.ToolAdapter.from_actions([
  MyApp.LookupCustomer,
  MyApp.CreateOrder
])
```

The adapter reads each action's Zoi schema and produces the JSON Schema representation that providers like OpenAI and Anthropic expect.

## Registering tools on an agent

Attach tools to a `Jido.AI.Agent` with the `tools` option. The agent sends these definitions to the LLM alongside your system prompt.

```elixir
defmodule MyApp.SupportAgent do
  use Jido.AI.Agent,
    name: "support_agent",
    description: "Customer support agent with tool access",
    tools: [MyApp.LookupCustomer, MyApp.CreateOrder],
    model: :fast,
    system_prompt: "You help customers. Use available tools
      to look up accounts and create orders."
end
```

## Tool execution flow

The runtime handles the full tool-call loop:

1. The agent sends tool definitions to the LLM with the prompt.
2. The LLM returns a tool call with a name and arguments.
3. Jido converts string-keyed JSON args to atom-keyed params using the action schema.
4. The action's `run/2` executes with validated params.
5. The result flows back to the LLM for the next reasoning step.

Jido handles parameter normalization automatically. A value like `"42"` for an integer field becomes `42` before it reaches your action.

## Strict mode

Some providers require `additionalProperties: false` in tool schemas. OpenAI's structured outputs mode is the most common example. Pass `strict: true` to `from_actions/2` to enable this globally.

```elixir
tools = Jido.AI.ToolAdapter.from_actions(
  [MyApp.LookupCustomer],
  strict: true
)
```

You can also define a `strict?/0` callback on individual actions to opt in per-action without changing the adapter call.

## Testing tool actions

Test tool actions the same way you test regular actions. Call `run/2` directly with the expected params.

```elixir
test "lookup_customer returns customer data" do
  assert {:ok, %{customer_id: "cus_123"}} =
    MyApp.LookupCustomer.run(%{email: "jane@example.com"}, %{})
end
```

No LLM round-trip needed. The action contract guarantees the same behavior whether called programmatically or through the tool-call loop.

## Next steps

- [Why not just a GenServer?](/docs/learn/why-not-just-a-genserver) - the case for separating data from process
- [Actions concept](/docs/concepts/actions) - deeper reference on the Action system
- [Build an AI chat agent](/docs/learn/ai-chat-agent) - multi-turn conversational agent with tools
