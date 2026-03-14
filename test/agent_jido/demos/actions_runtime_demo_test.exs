defmodule AgentJido.Demos.ActionsRuntimeDemoTest do
  use ExUnit.Case, async: false

  alias AgentJido.Demos.ActionsRuntimeDemo

  test "llm family returns deterministic envelope-style results" do
    result = ActionsRuntimeDemo.run_family(:llm)

    assert result.id == "llm"
    assert result.succeeded == true
    assert length(result.calls) == 3

    [chat, complete, generated] = result.calls

    assert chat.module =~ "FixtureChatAction"
    assert chat.result.model == "fixture:haiku"
    assert chat.result.text =~ "Elixir"

    assert complete.module =~ "FixtureCompleteAction"
    assert complete.result.text =~ "OTP"

    assert generated.module =~ "FixtureGenerateObjectAction"
    assert generated.result.object.title == "Jido AI roadmap"
    assert generated.result.object.confidence == 0.93
  end

  test "tool-calling family lists tools and executes deterministic tool flow" do
    result = ActionsRuntimeDemo.run_family(:tool_calling)

    assert result.id == "tool_calling"
    assert result.succeeded == true
    assert length(result.calls) == 3

    [listed, executed, called] = result.calls

    assert listed.module == "Jido.AI.Actions.ToolCalling.ListTools"
    assert listed.result.count == 1
    assert hd(listed.result.tools).name == "convert_temperature"

    assert executed.module == "Jido.AI.Actions.ToolCalling.ExecuteTool"
    assert executed.result.result.converted_value == 22.2
    assert executed.result.result.output_unit == "celsius"

    assert called.module =~ "FixtureCallWithToolsAction"
    assert called.result.content =~ "22.2C"
    assert called.result.turns == 2
  end

  test "retrieval family uses runtime retrieval actions against the in-process store" do
    result = ActionsRuntimeDemo.run_family(:retrieval)

    assert result.id == "retrieval"
    assert result.succeeded == true
    assert length(result.calls) == 4

    recall = Enum.find(result.calls, &(&1.label == "RecallMemory"))
    clear = List.last(result.calls)

    assert recall.module == "Jido.AI.Actions.Retrieval.RecallMemory"
    assert recall.result.retrieval.count == 2
    assert Enum.any?(recall.result.retrieval.memories, &String.contains?(&1.text, "Seattle"))

    assert clear.module == "Jido.AI.Actions.Retrieval.ClearMemory"
    assert clear.result.retrieval.cleared == 2
  end

  test "quota family reports usage and resets the scope" do
    result = ActionsRuntimeDemo.run_family(:quota)

    assert result.id == "quota"
    assert result.succeeded == true
    assert length(result.calls) == 3

    [status, reset, after_reset] = result.calls

    assert status.module == "Jido.AI.Actions.Quota.GetStatus"
    assert status.result.quota.usage.requests == 2
    assert status.result.quota.usage.total_tokens == 420

    assert reset.module == "Jido.AI.Actions.Quota.Reset"
    assert reset.result.quota.reset == true

    assert after_reset.module == "Jido.AI.Actions.Quota.GetStatus"
    assert after_reset.result.quota.usage.requests == 0
    assert after_reset.result.quota.usage.total_tokens == 0
  end
end
