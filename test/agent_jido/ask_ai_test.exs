defmodule AgentJido.AskAiTest do
  use ExUnit.Case, async: true

  alias AgentJido.AskAi
  alias AgentJido.Search.Result

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

  describe "summarize/3" do
    test "uses llm output when llm call succeeds" do
      llm = fn prompt, _context, opts ->
        send(self(), {:llm_prompt, prompt})
        send(self(), {:llm_system_prompt, opts[:system_prompt]})
        {:ok, "Grounded answer from LLM."}
      end

      assert {:ok, "Grounded answer from LLM.", :llm} = AskAi.summarize("What is an agent?", @citations, llm: llm)
      assert_received {:llm_prompt, prompt}
      assert prompt =~ "What is an agent?"
      assert prompt =~ "/docs/concepts/agents"
      assert_received {:llm_system_prompt, system_prompt}
      assert is_binary(system_prompt)
    end

    test "falls back to deterministic summary when llm is missing" do
      assert {:ok, answer, :deterministic} = AskAi.summarize("What is an agent?", @citations, llm: nil)
      assert answer =~ "I searched the site content"
      assert answer =~ "[Docs]"
    end

    test "returns quota_fallback when llm reports quota or rate-limit errors" do
      llm = fn _prompt, _context, _opts -> {:error, :rate_limited} end

      assert {:ok, answer, :quota_fallback} = AskAi.summarize("What is an agent?", @citations, llm: llm)
      assert answer =~ "I searched the site content"
      assert answer =~ "/docs/concepts/agents"
    end

    test "returns deterministic_fallback for non-quota llm errors" do
      llm = fn _prompt, _context, _opts -> {:error, :provider_unavailable} end

      assert {:ok, answer, :deterministic_fallback} = AskAi.summarize("What is an agent?", @citations, llm: llm)
      assert answer =~ "I searched the site content"
      assert answer =~ "/docs/concepts/agents"
    end

    test "strips markdown code fences from llm output" do
      llm = fn _prompt, _context, _opts -> {:ok, "```markdown\nFinal answer\n```"} end

      assert {:ok, "Final answer", :llm} = AskAi.summarize("What is an agent?", @citations, llm: llm)
    end
  end
end
