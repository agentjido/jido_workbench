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

    base_entry_result =
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

    context = Map.put(context, :audit, audit)

    cond do
      context.update_mode == :audit_only ->
        audit_only_context(context, base_entry_result, audit_errors)

      context.fail_on_audit and audit_errors > 0 ->
        verification = Helpers.verification_for_audit_failure(context, audit)

        {:ok,
         %{
           context
           | status: :audit_failed,
             reason: "audit gates failed",
             verification: verification,
             halted?: true,
             entry_result:
               Map.merge(base_entry_result, %{
                 status: :audit_failed,
                 reason: "audit gates failed",
                 verification: verification
               })
         }}

      true ->
        case Writer.churn_guard(context.existing, context.candidate.raw, audit_errors) do
          {:error, reason} ->
            verification =
              if context.verify? do
                Helpers.skipped_verification("verification skipped: churn guard blocked write")
              else
                Helpers.default_verification()
              end

            {:ok,
             %{
               context
               | status: :churn_blocked,
                 reason: reason,
                 verification: verification,
                 halted?: true,
                 entry_result:
                   Map.merge(base_entry_result, %{
                     status: :churn_blocked,
                     reason: reason,
                     verification: verification
                   })
             }}

          :ok ->
            cond do
              Writer.noop?(Helpers.existing_raw(context.existing), context.candidate.raw) ->
                verification =
                  if context.verify? do
                    Helpers.skipped_verification("verification skipped: generated output is a no-op")
                  else
                    Helpers.default_verification()
                  end

                {:ok,
                 %{
                   context
                   | status: :skipped_noop,
                     reason: "generated output matches existing content",
                     verification: verification,
                     halted?: true,
                     entry_result:
                       Map.merge(base_entry_result, %{
                         status: :skipped_noop,
                         reason: "generated output matches existing content",
                         verification: verification
                       })
                 }}

              context.apply? ->
                {:ok,
                 %{
                   context
                   | status: :ready_to_persist,
                     reason: "candidate ready",
                     entry_result: base_entry_result
                 }}

              true ->
                verification =
                  if context.verify? do
                    Helpers.skipped_verification("verification skipped: rerun with --apply")
                  else
                    Helpers.default_verification()
                  end

                {:ok,
                 %{
                   context
                   | status: :dry_run_candidate,
                     reason: "dry-run (not applied)",
                     verification: verification,
                     halted?: true,
                     entry_result:
                       Map.merge(base_entry_result, %{
                         status: :dry_run_candidate,
                         reason: "dry-run (not applied)",
                         verification: verification
                       })
                 }}
            end
        end
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
