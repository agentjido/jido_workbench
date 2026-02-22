defmodule AgentJidoWeb.ContentGenerator.DiffTest do
  use ExUnit.Case, async: true

  alias AgentJidoWeb.ContentGenerator.Diff

  test "builds inline unified diff stats" do
    old_text = "line1\nline2\nline3\n"
    new_text = "line1\nline2 updated\nline3\nline4\n"

    diff = Diff.unified(old_text, new_text)

    assert diff.stats.added == 2
    assert diff.stats.removed == 1
    assert diff.stats.old_lines == 3
    assert diff.stats.new_lines == 4
    assert Enum.any?(diff.lines, &(&1.kind == :remove and &1.text == "line2"))
    assert Enum.any?(diff.lines, &(&1.kind == :add and &1.text == "line2 updated"))
  end

  test "truncates long diff output when max_lines is reached" do
    old_text = Enum.map_join(1..30, "\n", &"old#{&1}")
    new_text = Enum.map_join(1..30, "\n", &"new#{&1}")

    diff = Diff.unified(old_text, new_text, max_lines: 10)

    assert diff.truncated?
    assert length(diff.lines) == 10
    assert diff.total_lines > 10
  end
end
