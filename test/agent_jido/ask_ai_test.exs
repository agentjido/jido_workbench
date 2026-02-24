defmodule AgentJido.ContentAssistantTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias AgentJido.ContentAssistant
  alias AgentJido.ContentAssistant.Response
  alias AgentJido.ContentAssistant.Result

  defmodule RetrievalStub do
    def query_with_status(_query, opts) do
      Keyword.fetch!(opts, :stub_response)
    end
  end

  defmodule BudgetBlockedStub do
    def allow_llm?(_context), do: {:error, :budget_exhausted}
  end

  defmodule TurnstileBlockedStub do
    def verify(_token, _remote_ip), do: {:error, :missing_token}
  end

  @citations [
    %Result{
      title: "Agents",
      snippet: "Agents model state, lifecycle, and command execution boundaries.",
      url: "/docs/concepts/agents",
      source_type: :docs,
      score: 0.98
    },
    %Result{
      title: "ReqLLM",
      snippet: "ReqLLM provides provider-agnostic LLM calls with structured output support.",
      url: "/ecosystem#req-llm",
      source_type: :ecosystem,
      score: 0.82
    }
  ]

  describe "respond/2" do
    test "returns deterministic response when llm is unavailable" do
      assert {:ok, %Response{} = response} =
               ContentAssistant.respond("What is an agent?",
                 retrieval_module: RetrievalStub,
                 retrieval_opts: [stub_response: {:ok, @citations, :success}],
                 llm: nil
               )

      assert response.answer_mode == :deterministic
      assert response.llm_attempted? == false
      assert response.llm_enhanced? == false
      assert response.enhancement_blocked_reason == :llm_unconfigured
      assert response.answer_markdown =~ "I searched the site content"
      assert response.answer_markdown =~ "/docs/concepts/agents"
    end

    test "returns llm response when enhancement succeeds" do
      llm_complete_fun = fn _llm, prompt, _context, opts ->
        send(self(), {:llm_prompt, prompt})
        send(self(), {:llm_system_prompt, opts[:system_prompt]})
        {:ok, "Grounded answer from LLM."}
      end

      assert {:ok, %Response{} = response} =
               ContentAssistant.respond("What is an agent?",
                 retrieval_module: RetrievalStub,
                 retrieval_opts: [stub_response: {:ok, @citations, :success}],
                 llm: :stubbed_llm,
                 llm_complete_fun: llm_complete_fun
               )

      assert response.answer_mode == :llm
      assert response.llm_attempted? == true
      assert response.llm_enhanced? == true
      assert response.enhancement_blocked_reason == nil
      assert response.answer_markdown == "Grounded answer from LLM."

      assert_received {:llm_prompt, prompt}
      assert prompt =~ "What is an agent?"
      assert prompt =~ "/docs/concepts/agents"

      assert_received {:llm_system_prompt, system_prompt}
      assert is_binary(system_prompt)
    end

    test "returns quota fallback when llm returns rate-limited" do
      llm_complete_fun = fn _llm, _prompt, _context, _opts -> {:error, :rate_limited} end

      log =
        capture_log(fn ->
          assert {:ok, %Response{} = response} =
                   ContentAssistant.respond("What is an agent?",
                     retrieval_module: RetrievalStub,
                     retrieval_opts: [stub_response: {:ok, @citations, :success}],
                     llm: :stubbed_llm,
                     llm_complete_fun: llm_complete_fun
                   )

          assert response.answer_mode == :quota_fallback
          assert response.llm_attempted? == true
          assert response.llm_enhanced? == false
          assert response.answer_markdown =~ "I searched the site content"
        end)

      assert log =~ "ContentAssistant LLM enhancement failed"
    end

    test "returns deterministic fallback when llm call raises" do
      llm_complete_fun = fn _llm, _prompt, _context, _opts ->
        raise "llm request crashed"
      end

      log =
        capture_log(fn ->
          assert {:ok, %Response{} = response} =
                   ContentAssistant.respond("What is an agent?",
                     retrieval_module: RetrievalStub,
                     retrieval_opts: [stub_response: {:ok, @citations, :success}],
                     llm: :stubbed_llm,
                     llm_complete_fun: llm_complete_fun
                   )

          assert response.answer_mode == :deterministic_fallback
          assert response.llm_attempted? == true
          assert response.llm_enhanced? == false
          assert response.answer_markdown =~ "I searched the site content"
        end)

      assert log =~ "ContentAssistant LLM enhancement failed"
    end

    test "returns deterministic response when budget guard blocks llm" do
      assert {:ok, %Response{} = response} =
               ContentAssistant.respond("What is an agent?",
                 retrieval_module: RetrievalStub,
                 retrieval_opts: [stub_response: {:ok, @citations, :success}],
                 llm: :stubbed_llm,
                 llm_budget_module: BudgetBlockedStub
               )

      assert response.answer_mode == :deterministic
      assert response.llm_attempted? == false
      assert response.enhancement_blocked_reason == :budget
      assert response.answer_markdown =~ "I searched the site content"
    end

    test "returns deterministic response when turnstile blocks llm" do
      assert {:ok, %Response{} = response} =
               ContentAssistant.respond("What is an agent?",
                 retrieval_module: RetrievalStub,
                 retrieval_opts: [stub_response: {:ok, @citations, :success}],
                 llm: :stubbed_llm,
                 require_turnstile: true,
                 turnstile_token: "",
                 turnstile_module: TurnstileBlockedStub
               )

      assert response.answer_mode == :deterministic
      assert response.llm_attempted? == false
      assert response.enhancement_blocked_reason == :turnstile
      assert response.answer_markdown =~ "I searched the site content"
    end

    test "marks retrieval fallback when fallback results are available" do
      assert {:ok, %Response{} = response} =
               ContentAssistant.respond("agents",
                 retrieval_module: RetrievalStub,
                 retrieval_opts: [stub_response: {:ok, @citations, :fallback}],
                 llm: nil
               )

      assert response.retrieval_status == :fallback
      assert response.answer_mode == :deterministic
      assert response.citations != []
    end

    test "returns no_results when retrieval has no citations" do
      assert {:ok, %Response{} = response} =
               ContentAssistant.respond("unknown",
                 retrieval_module: RetrievalStub,
                 retrieval_opts: [stub_response: {:ok, [], :success}],
                 llm: :stubbed_llm
               )

      assert response.answer_mode == :no_results
      assert response.answer_markdown == ""
      assert response.citations == []
      assert response.llm_attempted? == false
    end
  end
end
