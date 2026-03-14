defmodule AgentJido.Demos.SkillsRuntimeFoundations.CalculatorSkill do
  @moduledoc """
  Module-backed skill used by the public skills runtime foundations example.
  """

  use Jido.AI.Skill,
    name: "demo-runtime-calculator",
    description: "Performs arithmetic with tool-based execution for the skills runtime foundations demo.",
    license: "Apache-2.0",
    allowed_tools: ~w(add subtract multiply divide),
    tags: ["demo", "skills", "math", "runtime"],
    body: """
    # Demo Runtime Calculator

    Use arithmetic tools for every operation in this demo.

    ## Workflow
    1. Identify the arithmetic request.
    2. Select the matching math tool.
    3. Return the computed result with a short explanation.
    """
end
