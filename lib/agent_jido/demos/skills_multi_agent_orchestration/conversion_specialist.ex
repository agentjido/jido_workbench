defmodule AgentJido.Demos.SkillsMultiAgentOrchestration.ConversionSpecialist do
  @moduledoc """
  Deterministic conversion helpers used by the file-backed unit conversion skill.
  """

  @doc "Converts the demo temperature request from Fahrenheit to Celsius."
  @spec convert_demo_temperature() :: map()
  def convert_demo_temperature do
    fahrenheit = 98.6
    celsius = Float.round((fahrenheit - 32.0) * 5.0 / 9.0, 1)

    %{
      skill_name: "demo-unit-converter",
      tool_trace: [
        %{
          tool: "convert_temperature",
          input: "98.6 Fahrenheit -> Celsius",
          output: "#{format_float(celsius, 1)} Celsius"
        }
      ],
      response: "Conversion specialist converted 98.6°F to #{format_float(celsius, 1)}°C.",
      celsius: celsius
    }
  end

  @doc "Converts the demo distance request from kilometers to miles."
  @spec convert_demo_distance() :: map()
  def convert_demo_distance do
    kilometers = 5.0
    miles = Float.round(kilometers * 0.621_371, 2)

    %{
      skill_name: "demo-unit-converter",
      tool_trace: [
        %{
          tool: "convert_distance",
          input: "5.0 kilometers -> miles",
          output: "#{format_float(miles, 2)} miles"
        }
      ],
      response: "Conversion specialist converted 5.0 kilometers to #{format_float(miles, 2)} miles.",
      miles: miles
    }
  end

  defp format_float(value, decimals) do
    :erlang.float_to_binary(value, decimals: decimals)
  end
end
