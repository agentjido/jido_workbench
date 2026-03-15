defmodule AgentJido.ContentGen.Actions.AuditAndGate do
  @moduledoc false

  use Jido.Action,
    name: "content_gen_audit_and_gate",
    description: "Runs audit checks and applies dry-run/apply gating decisions"

  alias AgentJido.ContentGen.Actions.Helpers
  alias AgentJido.ContentGen.Audit.ContentAuditor
  alias AgentJido.ContentGen.Writer

  @impl true
  def run(%{halted?: true} = context, _runtime_context), do: {:ok, context}

  def run(context, _runtime_context) do
    audit =
      ContentAuditor.audit(context.entry, context.target, context.candidate,
        source_index: context.source_index,
        route_patterns: context.route_patterns,
        planned_routes: context.planned_routes
      )

    audit_errors = length(audit.errors)

    base_entry_result = base_entry_result(context, audit)
    context = Map.put(context, :audit, audit)

    handle_audit_gate(context, base_entry_result, audit, audit_errors)
  end

  defp base_entry_result(context, audit) do
    Helpers.base_entry_result(context)
    |> Map.merge(%{
      parse_mode: context.parse_mode,
      audit: audit,
      diff: context.diff,
      citations: context.candidate.citations,
      audit_notes: context.candidate.audit_notes,
      content_hash: Helpers.content_hash(context.candidate.raw),
      candidate_path: context.candidate_path,
      backend_meta: context.backend_meta
    })
  end

  defp handle_audit_gate(context, base_entry_result, audit, audit_errors) do
    cond do
      context.update_mode == :audit_only ->
        audit_only_context(context, base_entry_result, audit_errors)

      context.fail_on_audit and audit_errors > 0 ->
        {:ok,
         halted_context(
           context,
           base_entry_result,
           :audit_failed,
           "audit gates failed",
           Helpers.verification_for_audit_failure(context, audit)
         )}

      true ->
        run_write_gate(context, base_entry_result, audit_errors)
    end
  end

  defp run_write_gate(context, base_entry_result, audit_errors) do
    case Writer.churn_guard(context.existing, context.candidate.raw, audit_errors) do
      {:error, reason} ->
        {:ok,
         halted_context(
           context,
           base_entry_result,
           :churn_blocked,
           reason,
           skipped_or_default_verification(context, "verification skipped: churn guard blocked write")
         )}

      :ok ->
        finalize_candidate_state(context, base_entry_result)
    end
  end

  defp finalize_candidate_state(context, base_entry_result) do
    cond do
      Writer.noop?(Helpers.existing_raw(context.existing), context.candidate.raw) ->
        {:ok,
         halted_context(
           context,
           base_entry_result,
           :skipped_noop,
           "generated output matches existing content",
           skipped_or_default_verification(context, "verification skipped: generated output is a no-op")
         )}

      context.apply? ->
        {:ok, ready_to_persist_context(context, base_entry_result)}

      true ->
        {:ok,
         halted_context(
           context,
           base_entry_result,
           :dry_run_candidate,
           "dry-run (not applied)",
           skipped_or_default_verification(context, "verification skipped: rerun with --apply")
         )}
    end
  end

  defp ready_to_persist_context(context, base_entry_result) do
    %{
      context
      | status: :ready_to_persist,
        reason: "candidate ready",
        entry_result: base_entry_result
    }
  end

  defp halted_context(context, base_entry_result, status, reason, verification) do
    %{
      context
      | status: status,
        reason: reason,
        verification: verification,
        halted?: true,
        entry_result:
          Map.merge(base_entry_result, %{
            status: status,
            reason: reason,
            verification: verification
          })
    }
  end

  defp skipped_or_default_verification(context, skipped_reason) do
    if context.verify? do
      Helpers.skipped_verification(skipped_reason)
    else
      Helpers.default_verification()
    end
  end

  defp audit_only_context(context, base_entry_result, audit_errors) do
    status = if audit_errors == 0, do: :audit_only_passed, else: :audit_failed
    reason = "audit_only"

    halt_after_step = not context.verify?

    {:ok,
     %{
       context
       | status: status,
         reason: reason,
         halted?: halt_after_step,
         entry_result:
           Map.merge(base_entry_result, %{
             status: status,
             reason: reason
           })
     }}
  end
end
