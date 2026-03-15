defmodule AgentJido.Demos.WeatherMultiTurnContext.RuntimeDemoTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.WeatherMultiTurnContext.RuntimeDemo

  test "full conversation preserves city context and records one deterministic retry" do
    demo =
      RuntimeDemo.new("seattle")
      |> RuntimeDemo.run_all()

    assert demo.assistant.current_city == "Seattle"
    assert length(demo.assistant.turns) == 3
    assert length(demo.assistant.retry_events) == 1
    assert Enum.at(demo.assistant.turns, 1).response =~ "Seattle"
    assert Enum.at(demo.assistant.turns, 1).response =~ "umbrella"
    assert Enum.at(demo.assistant.turns, 2).response =~ "outdoor"
    assert Enum.at(demo.assistant.turns, 2).response =~ "indoor"
  end

  test "city presets reset the conversation and follow the selected location" do
    demo =
      RuntimeDemo.new()
      |> RuntimeDemo.select_city("denver")
      |> RuntimeDemo.run_turn(:forecast)

    assert demo.assistant.selected_city.city == "Denver"
    assert demo.assistant.current_city == "Denver"
    assert List.last(demo.assistant.turns).response =~ "Denver"
  end
end
