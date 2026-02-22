defmodule AgentJido.ContentGen.ModelRouterTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentGen.ModelRouter

  test "uses req_llm two-pass defaults" do
    entry = %{section: "docs"}
    target = %{route: "/docs/reference/packages/jido", format: :md}

    decision = ModelRouter.choose(entry, target, %{})

    assert decision.backend == :req_llm
    assert decision.pipeline == :two_pass
    assert decision.planner_model == "anthropic:claude-sonnet-4-5"
    assert decision.writer_model == "google:gemini-2.5-pro"
    assert decision.model == "google:gemini-2.5-pro"
  end

  test "keeps req_llm for livebook output" do
    entry = %{section: "docs"}
    target = %{route: "/docs/concepts/actions", format: :livemd}

    decision = ModelRouter.choose(entry, target, %{})

    assert decision.backend == :req_llm
    assert decision.pipeline == :two_pass
  end

  test "normalizes codex backend and keeps fixed planner/writer pair" do
    entry = %{section: "docs"}
    target = %{route: "/docs/reference/glossary", format: :md}

    decision = ModelRouter.choose(entry, target, %{backend: :codex})

    assert decision.backend == :req_llm
    assert decision.planner_model == "anthropic:claude-sonnet-4-5"
    assert decision.writer_model == "google:gemini-2.5-pro"
    assert decision.model == "google:gemini-2.5-pro"
    assert decision.reason == "codex_requested_but_req_llm_enforced_two_pass"
  end

  test "maps legacy configured aliases to supported models" do
    entry = %{section: "docs"}
    target = %{route: "/docs/reference/glossary", format: :md}

    Application.put_env(:agent_jido, :content_gen_planner_model, "anthropic:claude-sonnet-4.6")
    Application.put_env(:agent_jido, :content_gen_writer_model, "google:gemini-3.1-pro")

    on_exit(fn ->
      Application.put_env(:agent_jido, :content_gen_planner_model, "anthropic:claude-sonnet-4-5")
      Application.put_env(:agent_jido, :content_gen_writer_model, "google:gemini-2.5-pro")
    end)

    decision = ModelRouter.choose(entry, target, %{})

    assert decision.planner_model == "anthropic:claude-sonnet-4-5"
    assert decision.writer_model == "google:gemini-2.5-pro"
    assert decision.model == "google:gemini-2.5-pro"
  end
end
