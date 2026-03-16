defmodule AgentJido.ReleaseCatalogTest do
  use ExUnit.Case, async: true

  alias AgentJido.Pages.LivebookParser
  alias AgentJido.ReleaseCatalog

  test "exposes current package versions and requirements from ecosystem metadata" do
    assert ReleaseCatalog.version("jido") == "2.1.0"
    assert ReleaseCatalog.requirement("jido") == "~> 2.1"
    assert ReleaseCatalog.version("jido_ai") == "2.0.0"
    assert ReleaseCatalog.requirement("jido_ai") == "~> 2.0"
    assert ReleaseCatalog.version("req_llm") == "1.7.1"
    assert ReleaseCatalog.requirement("req_llm") == "~> 1.7"
  end

  test "renders mix dependency snippets from release metadata" do
    assert ReleaseCatalog.mix_dep("jido") == ~s({:jido, "~> 2.1"})
    assert ReleaseCatalog.mix_dep("jido_ai") == ~s({:jido_ai, "~> 2.0"})
    assert ReleaseCatalog.mix_dep("req_llm") == ~s({:req_llm, "~> 1.7"})
  end

  test "expands placeholders in static markdown and livebook content" do
    raw = """
    %{
      title: "Placeholder Example"
    }
    ---
    ```elixir
    Mix.install([
      {{mix_dep:jido}},
      {{mix_dep:jido_ai}},
      {{mix_dep:req_llm}}
    ])
    ```
    """

    {attrs, body} = LivebookParser.parse("placeholder-example.md", raw)

    assert attrs.title == "Placeholder Example"
    assert body =~ ~s({:jido, "~> 2.1"})
    assert body =~ ~s({:jido_ai, "~> 2.0"})
    assert body =~ ~s({:req_llm, "~> 1.7"})
    refute body =~ "{{mix_dep:"
  end

  test "actual docs sources expand released dependencies instead of github main guidance" do
    source =
      File.read!(Path.expand("../../priv/pages/docs/getting-started/first-llm-agent.livemd", __DIR__))

    {_attrs, body} =
      LivebookParser.parse(
        Path.expand("../../priv/pages/docs/getting-started/first-llm-agent.livemd", __DIR__),
        source
      )

    assert body =~ ~s({:jido, "~> 2.1"})
    assert body =~ ~s({:jido_ai, "~> 2.0"})
    assert body =~ ~s({:req_llm, "~> 1.7"})
    refute body =~ ~s(github: "agentjido/jido_ai")
  end
end
