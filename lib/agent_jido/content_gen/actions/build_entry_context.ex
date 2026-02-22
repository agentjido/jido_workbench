defmodule AgentJido.ContentGen.Actions.BuildEntryContext do
  @moduledoc false

  use Jido.Action,
    name: "content_gen_build_entry_context",
    description: "Builds the initial context map for one content generation entry"

  alias AgentJido.ContentGen.Actions.Helpers

  @impl true
  def run(params, _context) do
    entry = Map.get(params, :entry) || Map.get(params, "entry")
    run_opts = Map.get(params, :run_opts) || Map.get(params, "run_opts")

    {:ok, Helpers.default_context(entry, run_opts)}
  end
end
