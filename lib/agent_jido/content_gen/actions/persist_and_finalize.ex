defmodule AgentJido.ContentGen.Actions.PersistAndFinalize do
  @moduledoc false

  use Jido.Action,
    name: "content_gen_persist_and_finalize",
    description: "Persists candidate content when requested and returns normalized entry result"

  alias AgentJido.ContentGen.Actions.Helpers
  alias AgentJido.ContentGen.Writer

  @impl true
  def run(context, _runtime_context) do
    context =
      cond do
        context.halted? ->
          context

        context.update_mode == :audit_only ->
          context
          |> Map.put_new(:status, :audit_only_passed)
          |> Map.put_new(:reason, "audit_only")

        context.apply? ->
          persist_candidate(context)

        true ->
          context
          |> Map.put(:status, :dry_run_candidate)
          |> Map.put(:reason, "dry-run (not applied)")
      end

    final_entry_result = finalize_entry_result(context)

    {:ok,
     context
     |> Map.put(:entry_result, final_entry_result)
     |> Map.put(:id, final_entry_result.id)
     |> Map.put(:status, final_entry_result.status)}
  end

  defp persist_candidate(context) do
    case Writer.write(context.target.target_path, context.candidate.raw) do
      :ok ->
        after_write(context)

      {:error, reason} ->
        %{
          context
          | status: :generation_failed,
            reason: reason,
            halted?: true,
            verification:
              if(context.verify?, do: Helpers.skipped_verification("verification skipped: write failed"), else: Helpers.default_verification())
        }
    end
  end

  defp after_write(context) do
    verify_after_persist? = Map.get(context, :verify_after_persist?, false)

    verification = verification_for_persist(context, verify_after_persist?)

    if verify_after_persist? and Helpers.verification_failed?(verification) do
      verification_failure_context(context, verification)
    else
      case Helpers.maybe_cleanup_converted_source(context.target, verification) do
        :ok ->
          %{
            context
            | status: :written,
              reason: "applied to target",
              verification: verification
          }

        {:error, cleanup_reason} ->
          %{
            context
            | status: :generation_failed,
              reason: cleanup_reason,
              halted?: true,
              verification: verification
          }
      end
    end
  end

  defp run_verification(context) do
    verify_opts = Helpers.maybe_verify_opts(context)

    try do
      context.verifier.verify(
        context.entry,
        context.target,
        context.candidate,
        context.audit,
        [docs_format: context.docs_format] ++ verify_opts
      )
    rescue
      error ->
        Helpers.failed_verification("verification crashed: #{Exception.message(error)}")
    catch
      kind, reason ->
        Helpers.failed_verification("verification crashed (#{kind}): #{inspect(reason)}")
    end
  end

  defp finalize_entry_result(context) do
    base =
      context.entry_result ||
        Helpers.base_entry_result(context)

    base
    |> Map.put(:status, context.status || base[:status] || :unknown)
    |> Map.put(:reason, context.reason || base[:reason])
    |> Map.put(:verification, finalized_verification(context, base))
    |> Map.put(:workflow_step_failures, context.step_failures || [])
    |> maybe_put_optional_result_fields(context)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp verification_for_persist(context, true), do: run_verification(context)
  defp verification_for_persist(context, false), do: context.verification || Helpers.default_verification()

  defp verification_failure_context(context, verification) do
    case Helpers.rollback_failed_conversion(context.target) do
      :ok ->
        %{
          context
          | status: :verification_failed,
            reason: "verification checks failed",
            halted?: true,
            verification: verification
        }

      {:error, rollback_reason} ->
        %{
          context
          | status: :generation_failed,
            reason:
              "#{verification.command_output_excerpt || "verification failed"} " <>
                "(rollback failed: #{rollback_reason})",
            halted?: true,
            verification: verification
        }
    end
  end

  defp finalized_verification(context, base) do
    context.verification ||
      base[:verification] ||
      Helpers.default_verification()
  end

  defp maybe_put_optional_result_fields(result, context) do
    [
      {:route, context.target && context.target.route},
      {:target_path, context.target && context.target.target_path},
      {:read_path, context.target && context.target.read_path},
      {:conversion_source_path, context.target && context.target.conversion_source_path},
      {:format, context.target && context.target.format},
      {:parse_mode, context.parse_mode},
      {:backend_meta, context.backend_meta},
      {:candidate_path, context.candidate_path},
      {:audit, context.audit},
      {:diff, context.diff},
      {:content_hash, context.candidate && Helpers.content_hash(context.candidate.raw)},
      {:citations, context.candidate && context.candidate.citations},
      {:audit_notes, context.candidate && context.candidate.audit_notes},
      {:output_excerpt, context.output_excerpt}
    ]
    |> Enum.reduce(result, fn {key, value}, acc -> maybe_put(acc, key, value) end)
  end
end
