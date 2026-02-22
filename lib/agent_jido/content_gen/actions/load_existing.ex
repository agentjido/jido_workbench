defmodule AgentJido.ContentGen.Actions.LoadExisting do
  @moduledoc false

  use Jido.Action,
    name: "content_gen_load_existing",
    description: "Loads existing page content when present"

  alias AgentJido.ContentGen.Actions.Helpers
  alias AgentJido.ContentGen.Writer

  @impl true
  def run(%{halted?: true} = context, _runtime_context), do: {:ok, context}

  def run(%{target: target} = context, _runtime_context) when is_map(target) do
    case Writer.read_existing(target.read_path) do
      {:ok, existing} ->
        {:ok, Map.put(context, :existing, existing)}

      :missing ->
        if context.update_mode == :audit_only do
          failed =
            Helpers.halt_with_entry_result(
              context,
              :skipped_missing_for_audit,
              "audit_only requires an existing target file",
              "load_existing"
            )

          {:ok, failed}
        else
          {:ok, Map.put(context, :existing, nil)}
        end

      {:error, reason} ->
        failed =
          Helpers.halt_with_entry_result(
            context,
            :generation_failed,
            reason,
            "load_existing"
          )

        {:ok, failed}
    end
  end

  def run(context, _runtime_context) do
    failed =
      Helpers.halt_with_entry_result(
        context,
        :generation_failed,
        "target path was not resolved before loading existing content",
        "load_existing"
      )

    {:ok, failed}
  end
end
