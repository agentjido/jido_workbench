%{
  title: "Actions and validation",
  description: "Define schemas, validate inputs and outputs, and compose actions into chains.",
  category: :docs,
  order: 21,
  tags: [:docs, :learn, :actions, :validation],
  draft: false
}
---

## Defining an action

An Action is an Elixir module that calls `use Jido.Action` with compile-time configuration. You declare a `name`, an optional `description`, a `schema` for input validation, and an optional `output_schema` for output validation. The only required callback is `run/2`.

`run/2` receives validated params as its first argument and a context map as its second. It returns one of three shapes covered later in this guide.

```elixir
defmodule MyApp.CalculateShipping do
  use Jido.Action,
    name: "calculate_shipping",
    description: "Calculates shipping cost for an order",
    schema: Zoi.object(%{
      weight_kg: Zoi.float(),
      destination: Zoi.string()
    }),
    output_schema: Zoi.object(%{
      cost: Zoi.float(),
      carrier: Zoi.string()
    })

  @impl true
  def run(params, _context) do
    cost = params.weight_kg * rate_for(params.destination)
    {:ok, %{cost: cost, carrier: "standard"}}
  end

  defp rate_for("US"), do: 2.50
  defp rate_for(_), do: 5.00
end
```

The `use` macro validates your configuration at compile time. If you pass an invalid schema or omit `name`, compilation fails with a clear error.

## Input validation with Zoi

Jido uses Zoi schemas for both compile-time and runtime validation. When you call an action, params are validated against the `schema` before `run/2` executes. Invalid params return an error tuple without ever reaching your logic.

Common Zoi types:

```elixir
Zoi.string()              # binary strings
Zoi.integer()             # whole numbers
Zoi.float()               # floating-point numbers
Zoi.boolean()             # true or false
Zoi.atom()                # Elixir atoms
Zoi.list(Zoi.string())    # list of strings
Zoi.map(Zoi.integer())    # map with integer values
```

Add defaults and mark fields optional with pipes:

```elixir
schema: Zoi.object(%{
  currency: Zoi.string() |> Zoi.default("USD"),
  note: Zoi.string() |> Zoi.optional()
})
```

When params fail validation, you get a structured error before `run/2` is called:

```elixir
MyApp.CalculateShipping.run(%{weight_kg: "not_a_number"}, %{})
# => {:error, %Jido.Error{type: :validation_error, message: ...}}
```

## Output validation

The `output_schema` field validates the return value of `run/2`. If your action returns data that does not match the declared output schema, Jido returns a validation error.

```elixir
defmodule MyApp.LookupPrice do
  use Jido.Action,
    name: "lookup_price",
    schema: Zoi.object(%{sku: Zoi.string()}),
    output_schema: Zoi.object(%{
      price: Zoi.float(),
      currency: Zoi.string()
    })

  @impl true
  def run(_params, _context) do
    # Missing the required `currency` field
    {:ok, %{price: 29.99}}
  end
end
```

Running this action produces a validation error because the output is missing `currency`. Output validation catches contract violations early and keeps downstream consumers safe.

## Open validation model

Only declared fields are validated. Undeclared fields pass through untouched. This is intentional for composition.

When actions chain, earlier actions produce fields that later actions consume. Open validation prevents intermediate actions from rejecting data they do not use.

```elixir
defmodule MyApp.EnrichOrder do
  use Jido.Action,
    name: "enrich_order",
    schema: Zoi.object(%{order_id: Zoi.string()})

  @impl true
  def run(params, _context) do
    {:ok, %{order_id: params.order_id, customer_tier: "gold"}}
  end
end

defmodule MyApp.ApplyDiscount do
  use Jido.Action,
    name: "apply_discount",
    schema: Zoi.object(%{customer_tier: Zoi.string()})

  @impl true
  def run(params, _context) do
    discount = if params.customer_tier == "gold", do: 0.15, else: 0.0
    {:ok, %{discount: discount}}
  end
end

defmodule MyApp.FinalizeOrder do
  use Jido.Action,
    name: "finalize_order",
    schema: Zoi.object(%{
      order_id: Zoi.string(),
      discount: Zoi.float()
    })

  @impl true
  def run(params, _context) do
    {:ok, %{order_id: params.order_id, discount: params.discount, status: :confirmed}}
  end
end
```

In a chain of `[EnrichOrder, ApplyDiscount, FinalizeOrder]`, the `order_id` produced by `EnrichOrder` flows through `ApplyDiscount` even though `ApplyDiscount` only declares `customer_tier`. By the time `FinalizeOrder` runs, both `order_id` and `discount` are available.

## Validation lifecycle hooks

Two optional callbacks let you transform params around validation.

`on_before_validate_params/1` transforms raw input before schema validation. Use it to normalize external formats.

```elixir
defmodule MyApp.ImportProduct do
  use Jido.Action,
    name: "import_product",
    schema: Zoi.object(%{
      sku: Zoi.string(),
      price_cents: Zoi.integer()
    })

  @impl true
  def on_before_validate_params(params) do
    {:ok, Map.update(params, :sku, "", &String.upcase/1)}
  end

  @impl true
  def run(params, _context) do
    {:ok, %{sku: params.sku, price_cents: params.price_cents}}
  end
end
```

`on_after_validate_params/1` enriches validated params before execution. Use it to inject derived data.

```elixir
defmodule MyApp.ProcessPayment do
  use Jido.Action,
    name: "process_payment",
    schema: Zoi.object(%{
      amount: Zoi.float(),
      currency: Zoi.string() |> Zoi.default("USD")
    })

  @impl true
  def on_after_validate_params(params) do
    {:ok, Map.put(params, :idempotency_key, generate_key())}
  end

  @impl true
  def run(params, _context) do
    {:ok, %{payment_id: "pay_123", idempotency_key: params.idempotency_key}}
  end

  defp generate_key, do: :crypto.strong_rand_bytes(16) |> Base.encode16()
end
```

## The three return shapes

Actions return one of three tuples from `run/2`.

State changes to merge into the agent:

```elixir
def run(params, _context) do
  {:ok, %{status: :processed, order_id: params.order_id}}
end
```

State changes plus side-effect instructions for the runtime:

```elixir
def run(params, _context) do
  signal = %Jido.Signal{
    id: "sig_#{params.order_id}",
    type: "order.confirmed",
    source: "my_app.orders",
    data: %{order_id: params.order_id}
  }

  {:ok, %{status: :confirmed}, %Jido.Agent.Directive.Emit{signal: signal}}
end
```

Failure:

```elixir
def run(%{amount: amount}, _context) when amount <= 0 do
  {:error, "amount must be positive"}
end
```

Directives are never executed inside `run/2`. They are collected and returned alongside the updated agent, keeping your action logic pure.

## Composition patterns

Actions compose because inputs and outputs are plain maps. Pass a list of actions to `cmd/2`, and each action's output merges into params for the next.

```elixir
defmodule MyApp.ValidateOrder do
  use Jido.Action,
    name: "validate_order",
    schema: Zoi.object(%{order_id: Zoi.string()})

  @impl true
  def run(params, _context) do
    {:ok, %{order_id: params.order_id, validated: true}}
  end
end

defmodule MyApp.CalculateTotal do
  use Jido.Action,
    name: "calculate_total",
    schema: Zoi.object(%{validated: Zoi.boolean()})

  @impl true
  def run(%{validated: true}, _context) do
    {:ok, %{total: 49.99}}
  end
end

defmodule MyApp.ChargeCustomer do
  use Jido.Action,
    name: "charge_customer",
    schema: Zoi.object(%{
      order_id: Zoi.string(),
      total: Zoi.float()
    })

  @impl true
  def run(params, _context) do
    {:ok, %{charged: true, receipt_id: "rcpt_#{params.order_id}"}}
  end
end
```

Execute the chain through an agent:

```elixir
{agent, directives} = MyAgent.cmd(agent, [
  {MyApp.ValidateOrder, %{order_id: "ord_42"}},
  MyApp.CalculateTotal,
  MyApp.ChargeCustomer
])
```

`ValidateOrder` produces `%{order_id: "ord_42", validated: true}`. `CalculateTotal` reads `validated` and adds `total`. `ChargeCustomer` picks up both `order_id` and `total` from the accumulated map. If any action returns `{:error, reason}`, the chain stops.

## Testing actions

Actions are pure functions. Test them directly without spinning up an agent.

```elixir
defmodule MyApp.CalculateShippingTest do
  use ExUnit.Case, async: true

  test "calculates domestic shipping rate" do
    assert {:ok, result} =
             MyApp.CalculateShipping.run(
               %{weight_kg: 2.0, destination: "US"},
               %{}
             )

    assert result.cost == 5.0
    assert result.carrier == "standard"
  end

  test "calculates international shipping rate" do
    assert {:ok, result} =
             MyApp.CalculateShipping.run(
               %{weight_kg: 1.0, destination: "DE"},
               %{}
             )

    assert result.cost == 5.0
  end
end
```

You can also test validation by passing invalid params and asserting on the error.

## Next steps

- [Directives and scheduling](/docs/learn/directives-scheduling) - isolate side effects from action logic
- [Actions concept](/docs/concepts/actions) - authoritative reference for the Action system
- [Agents concept](/docs/concepts/agents) - how agents execute actions through cmd/2
