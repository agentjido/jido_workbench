defmodule AgentJido.ContentAssistantTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentAssistant
  alias AgentJido.ContentAssistant.Response
  alias AgentJido.ContentAssistant.Result

  defmodule RetrievalStub do
    def query_with_status(_query, opts) do
      Keyword.fetch!(opts, :stub_response)
    end
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
      url: "/ecosystem/req-llm",
      source_type: :ecosystem,
      score: 0.82
    }
  ]

  describe "respond/2" do
    test "returns deterministic response for citation-backed retrieval" do
      assert {:ok, %Response{} = response} =
               ContentAssistant.respond("What is an agent?",
                 retrieval_module: RetrievalStub,
                 retrieval_opts: [stub_response: {:ok, @citations, :success}],
                 llm: nil
               )

      assert response.answer_mode == :deterministic
      assert response.llm_attempted? == false
      assert response.llm_enhanced? == false
      assert response.enhancement_blocked_reason == nil
      assert response.answer_markdown =~ "Found 2 relevant references"
      assert response.answer_markdown =~ "Sources: Docs, Ecosystem."
    end

    test "ignores llm options and still returns deterministic response" do
      assert {:ok, %Response{} = response} =
               ContentAssistant.respond("What is an agent?",
                 retrieval_module: RetrievalStub,
                 retrieval_opts: [stub_response: {:ok, @citations, :success}],
                 llm: :stubbed_llm,
                 llm_complete_fun: fn _llm, _prompt, _context, _opts -> {:ok, "unused"} end
               )

      assert response.answer_mode == :deterministic
      assert response.llm_attempted? == false
      assert response.llm_enhanced? == false
      assert response.enhancement_blocked_reason == nil
      assert response.answer_markdown =~ "Found 2 relevant references"
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
