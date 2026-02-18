defmodule AgentJido.ContentOps.RunicStrategy do
  @moduledoc """
  Wrapper around `Jido.Runic.Strategy` that maps ContentOps cadence signals
  into explicit workflow feed signals with normalized run modes.
  """

  use Jido.Agent.Strategy

  alias Jido.Instruction
  alias Jido.Runic.Strategy, as: BaseStrategy

  @supported_modes [:hourly, :nightly, :weekly, :monthly]

  @impl true
  def init(agent, ctx), do: BaseStrategy.init(agent, ctx)

  @impl true
  def tick(agent, ctx), do: BaseStrategy.tick(agent, ctx)

  @impl true
  def snapshot(agent, ctx), do: BaseStrategy.snapshot(agent, ctx)

  @impl true
  def action_spec(action), do: BaseStrategy.action_spec(action)

  @impl true
  def signal_routes(ctx) do
    [
      {"contentops.tick.hourly", {:strategy_cmd, :contentops_tick_hourly}, 100},
      {"contentops.tick.nightly", {:strategy_cmd, :contentops_tick_nightly}, 100},
      {"contentops.tick.weekly", {:strategy_cmd, :contentops_tick_weekly}, 100},
      {"contentops.tick.monthly", {:strategy_cmd, :contentops_tick_monthly}, 100},
      {"contentops.run.requested", {:strategy_cmd, :contentops_run_requested}, 100}
    ] ++ BaseStrategy.signal_routes(ctx)
  end

  @impl true
  def cmd(agent, instructions, ctx) do
    rewritten =
      instructions
      |> List.wrap()
      |> Enum.flat_map(&rewrite_instructions/1)

    BaseStrategy.cmd(agent, rewritten, ctx)
  end

  defp rewrite_instructions(%Instruction{action: :contentops_tick_hourly} = instruction) do
    [reset_workflow_instruction(instruction), to_feed_instruction(instruction, :hourly)]
  end

  defp rewrite_instructions(%Instruction{action: :contentops_tick_nightly} = instruction) do
    [reset_workflow_instruction(instruction), to_feed_instruction(instruction, :nightly)]
  end

  defp rewrite_instructions(%Instruction{action: :contentops_tick_weekly} = instruction) do
    [reset_workflow_instruction(instruction), to_feed_instruction(instruction, :weekly)]
  end

  defp rewrite_instructions(%Instruction{action: :contentops_tick_monthly} = instruction) do
    [reset_workflow_instruction(instruction), to_feed_instruction(instruction, :monthly)]
  end

  defp rewrite_instructions(%Instruction{action: :contentops_run_requested, params: params} = instruction) do
    mode = params |> requested_mode() |> normalize_mode(:weekly)
    [reset_workflow_instruction(instruction), to_feed_instruction(instruction, mode)]
  end

  defp rewrite_instructions(instruction), do: [instruction]

  defp requested_mode(params) when is_map(params) do
    direct_mode = Map.get(params, :mode) || Map.get(params, "mode")

    nested_mode =
      case Map.get(params, :data) || Map.get(params, "data") do
        data when is_map(data) ->
          Map.get(data, :mode) || Map.get(data, "mode")

        _other ->
          nil
      end

    direct_mode || nested_mode
  end

  defp requested_mode(_params), do: nil

  defp to_feed_instruction(%Instruction{} = instruction, mode) do
    %Instruction{
      instruction
      | action: :runic_feed_signal,
        params: %{data: %{mode: normalize_mode(mode, :weekly)}}
    }
  end

  defp reset_workflow_instruction(%Instruction{} = instruction) do
    %Instruction{
      instruction
      | action: :runic_set_workflow,
        params: %{workflow: AgentJido.ContentOps.OrchestratorAgent.build_workflow()}
    }
  end

  defp normalize_mode(mode, _default) when mode in @supported_modes, do: mode

  defp normalize_mode(mode, default) when is_binary(mode) do
    case mode |> String.trim() |> String.downcase() do
      "hourly" -> :hourly
      "nightly" -> :nightly
      "weekly" -> :weekly
      "monthly" -> :monthly
      _other -> default
    end
  end

  defp normalize_mode(_mode, default), do: default
end
