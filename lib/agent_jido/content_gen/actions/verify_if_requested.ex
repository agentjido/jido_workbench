defmodule AgentJido.ContentGen.Actions.VerifyIfRequested do
  @moduledoc false

  use Jido.Action,
    name: "content_gen_verify_if_requested",
    description: "Runs verification checks when verification is enabled"

  alias AgentJido.ContentGen.Actions.Helpers

  @impl true
  def run(%{verify?: false} = context, _runtime_context), do: {:ok, context}

  def run(%{verify?: true, apply?: true, update_mode: mode} = context, _runtime_context)
      when mode in [:improve, :regenerate] do
    {:ok, Map.put(context, :verify_after_persist?, true)}
  end

  def run(%{verify?: true, halted?: true, update_mode: mode} = context, _runtime_context)
      when mode != :audit_only do
    {:ok, context}
  end

  def run(%{verify?: true} = context, _runtime_context) do
    verification = run_verification(context)
    entry_result = Map.get(context, :entry_result, Helpers.base_entry_result(context))

    if context.status == :audit_only_passed and Helpers.verification_failed?(verification) do
      {:ok,
       %{
         context
         | status: :verification_failed,
           reason: "verification checks failed",
           halted?: true,
           verification: verification,
           entry_result:
             Map.merge(entry_result, %{
               status: :verification_failed,
               reason: "verification checks failed",
               verification: verification
             })
       }}
    else
      {:ok,
       %{
         context
         | verification: verification,
           entry_result: Map.put(entry_result, :verification, verification)
       }}
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
end
