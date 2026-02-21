defmodule AgentJido.ContentGen.ModelRouterTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentGen.ModelRouter

  test "routes docs/reference to req_llm by default" do
    entry = %{section: "docs"}
    target = %{route: "/docs/reference/packages/jido", format: :md}

    decision = ModelRouter.choose(entry, target, %{})

    assert decision.backend == :req_llm
    assert decision.model == "google:gemini-2.5-pro"
  end

  test "routes livebook output to codex by default" do
    entry = %{section: "docs"}
    target = %{route: "/docs/concepts/actions", format: :livemd}

    decision = ModelRouter.choose(entry, target, %{})

    assert decision.backend == :codex
    assert decision.model == nil
  end

  test "honors explicit backend/model overrides" do
    entry = %{section: "docs"}
    target = %{route: "/docs/reference/glossary", format: :md}

    decision =
      ModelRouter.choose(entry, target, %{
        backend: :codex,
        model: "o3"
      })

    assert decision.backend == :codex
    assert decision.model == "o3"
    assert decision.reason == "forced_backend_codex"
  end
end
