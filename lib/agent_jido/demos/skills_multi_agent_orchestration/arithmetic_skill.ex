defmodule AgentJido.Demos.SkillsMultiAgentOrchestration.ArithmeticSkill do
  @moduledoc """
  Module-backed arithmetic specialist for the multi-skill orchestration demo.
  """

  use Jido.AI.Skill,
    name: "demo-orchestrator-arithmetic",
    description: "Handles arithmetic-only requests in the deterministic orchestration demo.",
    license: "Apache-2.0",
    allowed_tools: ~w(multiply add),
    tags: ["demo", "skills", "math", "orchestration"],
    body: """
    # Demo Arithmetic Specialist

    Use arithmetic tools to break a compound math expression into ordered steps.

    ## Workflow
    1. Multiply first.
    2. Add the final offset.
    3. Return the final result with the intermediate values.
    """

  @doc "Executes the fixed arithmetic request used by the public orchestration demo."
  @spec run_demo_request() :: map()
  def run_demo_request do
    multiplied = 42 * 17
    total = multiplied + 100

    %{
      skill_name: manifest().name,
      tool_trace: [
        %{tool: "multiply", input: "42 * 17", output: Integer.to_string(multiplied)},
        %{tool: "add", input: "#{multiplied} + 100", output: Integer.to_string(total)}
      ],
      response: "Arithmetic specialist computed 42 * 17 + 100 = #{total}.",
      value: total
    }
  end
end
