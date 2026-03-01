%{
  title: "Execution",
  description: "The pipeline that turns instructions into validated results with retries, timeouts, and compensation.",
  category: :docs,
  order: 110,
  tags: [:docs, :concepts],
  draft: false
}
---
## What execution solves

Calling `action.run(params, context)` directly gives you no validation, no timeout protection, and no error recovery. If the function hangs, your process hangs. If the input is malformed, you get a cryptic crash. If the call fails, you have no retry or compensation path.

`Jido.Exec` wraps every action invocation in a pipeline that validates inputs and outputs, enforces timeout budgets, retries transient failures, and runs compensation callbacks when things go wrong. Every action, whether called synchronously, asynchronously, or as part of a chain, goes through this same pipeline.

## The pipeline

A call to `Jido.Exec.run/4` passes through these stages in order:

1. **Normalize params and context** into maps (accepts maps, keyword lists, or `{:ok, map}` tuples)
2. **Validate the action** module is compiled and exports `run/2`
3. **Validate params** through the action's `validate_params/1` callback
4. **Inject action metadata** into the context under `:action_metadata`
5. **Log start** via conditional telemetry
6. **Resolve timeout budget** propagating any existing deadline through `__jido_deadline_ms__`
7. **Execute under Task.Supervisor** with the resolved timeout
8. **Call `action.run/2`** with validated params and enriched context
9. **Validate output** through `validate_output/1` if the action exports it
10. **Handle result** routing errors to compensation if enabled
11. **Log end** via telemetry
12. **Retry on failure** using exponential backoff if the error is retryable

```elixir
Jido.Exec.run(MyApp.CalculateShipping, %{weight_kg: 2.5, destination: "US"}, %{tenant: "acme"})
# => {:ok, %{cost: 6.25, carrier: "standard"}}
```

The pipeline catches exceptions, function clause errors, and unexpected return shapes. Every failure path produces a structured `Jido.Action.Error` with type, message, and details.

You can also pass an `%Instruction{}` struct directly:

```elixir
instruction = %Jido.Instruction{
  action: MyApp.CalculateShipping,
  params: %{weight_kg: 2.5, destination: "US"},
  context: %{tenant: "acme"},
  opts: [timeout: 10_000]
}

Jido.Exec.run(instruction)
```

This is the form that strategies use internally when processing `cmd/2` calls.

## Timeout budgets

Every execution runs under a timeout enforced by `Task.Supervisor`. The default is 30 seconds, configurable globally through `:jido_action, :default_timeout` or per-call via the `:timeout` option.

Deadlines propagate through nested calls. When Exec resolves the timeout budget, it stores an absolute monotonic deadline in the context under `__jido_deadline_ms__`. If a parent action invokes a child action through Exec, the child inherits the remaining budget.

```elixir
Jido.Exec.run(MyApp.ParentAction, %{}, %{}, timeout: 10_000)
```

If the parent takes 6 seconds and calls a child action, the child gets at most 4 seconds. If the budget is already exhausted when a child dispatch begins, Exec fails immediately with a timeout error before spawning any process.

When timeout is set to `0`, the action runs in the calling process with no timeout enforcement.

## Validation

`Jido.Exec.Validator` performs three checks during the pipeline:

- **validate_action** confirms the module is compiled (`Code.ensure_compiled/1`) and exports `run/2`
- **validate_params** calls the action's `validate_params/1` callback, which Zoi schemas generate automatically
- **validate_output** calls the action's `validate_output/1` if exported, otherwise skips validation

Output validation is optional. If your action declares an `output_schema`, the generated `validate_output/1` enforces it. If not, the raw result passes through unchanged.

## Retries

`Jido.Exec.Retry` handles transient failure recovery with exponential backoff. The defaults are 1 retry and 250ms initial backoff, configurable via `:max_retries` and `:backoff` options or globally through `:jido_action` application config.

Not all errors trigger retries. Validation errors (`InvalidInputError`) and configuration errors (`ConfigurationError`) fail immediately. Other errors are retryable unless their details contain `retry: false`. Backoff doubles on each attempt, capped at 30 seconds.

```elixir
Jido.Exec.run(MyApp.FetchPrice, %{symbol: "AAPL"}, %{},
  max_retries: 3,
  backoff: 500,
  timeout: 15_000
)
```

With these options, Exec attempts the action up to 4 times total (1 initial + 3 retries). The backoff intervals would be 500ms, 1000ms, and 2000ms. If the action returns `{:error, %{details: %{retry: false}}}`, retries stop immediately regardless of remaining attempts.

## Compensation

When an action fails and has compensation enabled, `Jido.Exec.Compensation` runs the action's `on_error/4` callback to attempt recovery. Compensation requires two things: the action metadata must include `compensation: [enabled: true]`, and the action must export `on_error/4`.

```elixir
defmodule MyApp.ChargeCard do
  use Jido.Action,
    name: "charge_card",
    compensation: [enabled: true],
    schema: Zoi.object(%{
      amount: Zoi.float(),
      card_token: Zoi.string()
    })

  @impl true
  def run(params, _context) do
    case PaymentGateway.charge(params.card_token, params.amount) do
      {:ok, charge_id} -> {:ok, %{charge_id: charge_id}}
      {:error, reason} -> {:error, reason}
    end
  end

  def on_error(params, error, _context, _opts) do
    PaymentGateway.void(params.card_token)
    {:ok, %{voided: true, original_error: error}}
  end
end
```

Compensation runs under `Task.Supervisor` with its own timeout (defaults to 5 seconds). The compensation result wraps the original error in a `Jido.Action.Error` with `compensated: true` in the details. If compensation itself fails or times out, the error includes `compensated: false`.

## Async execution

`Jido.Exec.run_async/4` starts an action under `Task.Supervisor` and returns an async reference immediately. Use `await/2` to collect the result or `cancel/1` to terminate.

```elixir
ref = Jido.Exec.run_async(MyApp.GenerateReport, %{quarter: "Q4"})

result = Jido.Exec.await(ref, 60_000)

:ok = Jido.Exec.cancel(ref)
```

Async execution runs the full pipeline, including validation, timeouts, and retries. Only the process that started the async action can await or cancel it. The async ref contains `:ref`, `:pid`, `:owner`, and `:monitor_ref` for deterministic cleanup.

If you call `await/2` and the action has not finished within the timeout, Exec kills the task process and returns a timeout error. Calling `cancel/1` sends a `:shutdown` exit signal and waits briefly for the process to terminate before flushing monitor messages.

## Chaining

`Jido.Exec.Chain.chain/3` runs a list of actions sequentially, merging each action's output into the params for the next action. This is the mechanism behind multi-action `cmd/2` calls.

```elixir
Jido.Exec.Chain.chain(
  [
    {MyApp.ValidateOrder, %{order_id: "ord_99"}},
    MyApp.ApplyDiscount,
    MyApp.CalculateShipping
  ],
  %{},
  context: %{tenant: "acme"},
  interrupt_check: fn -> System.monotonic_time(:millisecond) > deadline end
)
```

If any action fails, the chain halts and returns `{:error, reason}`. The optional `interrupt_check` function runs between actions. If it returns `true`, the chain halts with `{:interrupted, last_result}` containing the output from the most recent successful action.

Chains support async execution via `async: true`, which runs the entire chain under `Task.Supervisor` and returns a `Task` struct.

## How strategies use Exec

You rarely call `Jido.Exec` directly. When you call `MyAgent.cmd(agent, instructions)`, the agent's strategy handles execution. `Jido.Agent.Strategy.Direct` calls `Jido.Exec.run/1` with each `%Instruction{}` struct, merges the result into agent state, and collects directives.

The separation matters because strategies control sequencing, error handling policy, and multi-turn orchestration. Exec handles the mechanics of a single action invocation. This lets you swap strategies without affecting how individual actions validate, time out, or compensate.

### Jido instances

By default, Exec uses the global `Jido.Action.TaskSupervisor`. If you run multiple Jido instances (via `Jido.Supervisor` with a name), pass the `:jido` option to route execution through instance-scoped supervisors:

```elixir
Jido.Exec.run(MyApp.ProcessOrder, %{order_id: "ord_1"}, %{},
  jido: :my_app
)
```

This isolates task supervision per instance, preventing one workload from exhausting another's supervisor capacity.

## Next steps

- [Actions](/docs/concepts/actions) - define the units of work that Exec runs
- [Strategy](/docs/concepts/strategy) - control how agents orchestrate execution
- [Agents](/docs/concepts/agents) - see how `cmd/2` wires everything together
