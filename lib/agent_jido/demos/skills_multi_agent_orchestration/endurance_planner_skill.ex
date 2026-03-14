defmodule AgentJido.Demos.SkillsMultiAgentOrchestration.EndurancePlannerSkill do
  @moduledoc """
  Module-backed endurance specialist for the multi-skill orchestration demo.
  """

  use Jido.AI.Skill,
    name: "demo-endurance-planner",
    description: "Estimates calories and follow-up guidance after a distance conversion in the orchestration demo.",
    license: "Apache-2.0",
    allowed_tools: ~w(estimate_calories summarize_effort),
    tags: ["demo", "skills", "fitness", "orchestration"],
    body: """
    # Demo Endurance Planner

    Use converted mileage to estimate energy burn for a simple running scenario.

    ## Workflow
    1. Accept the converted distance in miles.
    2. Multiply by the calories-per-mile assumption.
    3. Return a concise planning note with the calorie estimate.
    """

  @doc "Estimates calories for the demo combined orchestration request."
  @spec estimate_demo_run(float(), pos_integer()) :: map()
  def estimate_demo_run(miles, calories_per_mile) when is_float(miles) and is_integer(calories_per_mile) do
    calories = round(miles * calories_per_mile)

    %{
      skill_name: manifest().name,
      tool_trace: [
        %{
          tool: "estimate_calories",
          input: "#{format_float(miles, 2)} miles at #{calories_per_mile} calories/mile",
          output: "#{calories} calories"
        }
      ],
      response:
        "Endurance planner estimated about #{calories} calories for #{format_float(miles, 2)} miles at #{calories_per_mile} calories per mile.",
      calories: calories
    }
  end

  defp format_float(value, decimals) do
    :erlang.float_to_binary(value, decimals: decimals)
  end
end
