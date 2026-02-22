defmodule AgentJido.ContentGen.PromptBuilder do
  @moduledoc """
  Compatibility wrapper around `AgentJido.ContentGen.Prompts`.
  """

  alias AgentJido.ContentGen.Prompts

  @spec build(map(), map(), map()) :: String.t()
  def build(entry, target, opts), do: Prompts.build(entry, target, opts)

  @spec build_structure_pass(map(), map(), map()) :: String.t()
  def build_structure_pass(entry, target, opts), do: Prompts.build_structure_pass(entry, target, opts)

  @spec build_writing_pass(map(), map(), map(), map()) :: String.t()
  def build_writing_pass(entry, target, opts, structure_plan),
    do: Prompts.build_writing_pass(entry, target, opts, structure_plan)
end
