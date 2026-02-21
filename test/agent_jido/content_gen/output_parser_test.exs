defmodule AgentJido.ContentGen.OutputParserTest do
  use ExUnit.Case, async: true

  alias AgentJido.ContentGen.OutputParser

  test "parses strict JSON envelope output" do
    json = ~s({"frontmatter":{"title":"T","description":"D"},"body_markdown":"# Body","citations":["x"],"audit_notes":["y"]})

    assert {:ok, parsed} = OutputParser.parse(json)
    assert parsed.frontmatter.title == "T"
    assert parsed.body_markdown =~ "# Body"
    assert parsed.citations == ["x"]
  end

  test "falls back to markdown envelope when model returns non-json chatter" do
    raw = """
    Here is the output:
    ```markdown
    # Agents

    Use `Jido.Agent`.
    ```
    """

    assert {:ok, parsed} = OutputParser.parse(raw)
    assert parsed.frontmatter == %{}
    assert parsed.body_markdown =~ "# Agents"
    assert "fallback_markdown_envelope" in parsed.audit_notes
  end

  test "parses fenced json envelope with nested braces in body_markdown" do
    raw = """
    ```json
    {
      "frontmatter": {"title": "Agents", "description": "Guide"},
      "body_markdown": "## Example\\n\\nUse %{count: 1} safely.",
      "citations": ["Jido.Agent"],
      "audit_notes": ["ok"]
    }
    ```
    """

    assert {:ok, parsed} = OutputParser.parse(raw)
    assert parsed.frontmatter.title == "Agents"
    assert parsed.body_markdown =~ "%{count: 1}"
    assert parsed.citations == ["Jido.Agent"]
    assert parsed.audit_notes == ["ok"]
  end

  test "fallback prefers fuller body when fenced block is too small" do
    raw = """
    Caller: {:ok, payload}
    # Agents Guide

    This is a long paragraph explaining agent lifecycle hooks, command handling, and strategy choices.
    It should remain in the fallback body even if a short fenced block appears below.

    ```text
    tiny
    ```
    """

    assert {:ok, parsed} = OutputParser.parse(raw)
    assert parsed.body_markdown =~ "# Agents Guide"
    assert parsed.body_markdown =~ "long paragraph"
    refute parsed.body_markdown =~ "Caller:"
  end

  test "returns error for empty output" do
    assert {:error, _} = OutputParser.parse("   ")
  end
end
