defmodule AgentJido.Demos.WeatherReasoningStrategySuite.ComparisonLabTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.WeatherReasoningStrategySuite.ComparisonLab

  test "starts on the default preset with the recommended strategy selected" do
    lab = ComparisonLab.new()

    assert lab.selected_preset_id == "commute-window"
    assert lab.selected_preset.title == "Commuter Decision"
    assert lab.selected_strategy_id == :cot
    assert lab.selected_strategy.name == "CoT"
    assert hd(lab.log).detail =~ "Commuter Decision"
  end

  test "select_preset resets selection to the new preset recommendation" do
    lab =
      ComparisonLab.new()
      |> ComparisonLab.select_preset("weekend-trip")

    assert lab.selected_preset_id == "weekend-trip"
    assert lab.selected_preset.title == "Weekend Trip Planning"
    assert lab.selected_strategy_id == :tot
    assert lab.selected_strategy.name == "ToT"
    assert hd(lab.log).detail =~ "Weekend Trip Planning"
  end

  test "select_strategy focuses one strategy inside the active preset" do
    lab =
      ComparisonLab.new("storm-operations")
      |> ComparisonLab.select_strategy("adaptive")

    assert lab.selected_strategy_id == :adaptive
    assert lab.selected_strategy.name == "Adaptive"
    assert lab.selected_strategy.why =~ "assistant should decide"
    assert hd(lab.log).detail =~ "Adaptive"
  end
end
