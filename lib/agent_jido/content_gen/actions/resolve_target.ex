defmodule AgentJido.ContentGen.Actions.ResolveTarget do
  @moduledoc false

  use Jido.Action,
    name: "content_gen_resolve_target",
    description: "Resolves the destination route/path for the selected content-plan entry"

  alias AgentJido.ContentGen.Actions.Helpers
  alias AgentJido.ContentGen.PathResolver

  @impl true
  def run(%{halted?: true} = context, _runtime_context), do: {:ok, context}

  def run(context, _runtime_context) do
    case PathResolver.resolve(context.entry,
           page_index: context.page_index,
           docs_format: context.docs_format
         ) do
      {:skip, :skipped_non_file_target, payload} ->
        {:ok, skipped_non_file_context(context, payload)}

      {:ok, target} ->
        if Helpers.safe_target_path?(target.target_path) do
          {:ok, Map.put(context, :target, target)}
        else
          failed =
            context
            |> Map.put(:target, target)
            |> Helpers.halt_with_entry_result(
              :generation_failed,
              "target path must resolve under priv/pages/: #{target.target_path}",
              "resolve_target"
            )

          {:ok, failed}
        end
    end
  end

  defp skipped_non_file_context(context, payload) do
    entry = context.entry
    reason = "non-file-backed route in v1"

    entry_result = %{
      id: entry.id,
      title: entry.title,
      section: entry.section,
      order: entry.order,
      route: payload.route,
      target_path: nil,
      read_path: nil,
      conversion_source_path: nil,
      format: nil,
      existed_before: false,
      update_mode: context.update_mode,
      verification: Helpers.default_verification(),
      status: :skipped_non_file_target,
      reason: reason,
      workflow_step_failures: []
    }

    %{
      context
      | status: :skipped_non_file_target,
        reason: reason,
        halted?: true,
        entry_result: entry_result
    }
  end
end
