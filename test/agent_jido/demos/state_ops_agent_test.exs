defmodule AgentJido.Demos.StateOpsAgentTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.StateOps.{
    ClearTempDataAction,
    DeleteNestedValueAction,
    MergeMetadataAction,
    ReplaceAllAction,
    SetNestedValueAction
  }

  alias AgentJido.Demos.StateOpsAgent

  test "set_state merges metadata" do
    agent = StateOpsAgent.new(state: %{counter: 10, name: "x"})

    {agent, []} = StateOpsAgent.cmd(agent, {MergeMetadataAction, %{metadata: %{version: "1.0"}}})

    assert agent.state.counter == 10
    assert agent.state.metadata.version == "1.0"
  end

  test "replace_state replaces full state" do
    agent = StateOpsAgent.new()
    new_state = %{counter: 0, name: "fresh", step: :reset, config: %{timeout: 2000}}
    {agent, []} = StateOpsAgent.cmd(agent, {ReplaceAllAction, %{new_state: new_state}})

    assert agent.state.name == "fresh"
    assert agent.state.step == :reset
    refute Map.has_key?(agent.state, :metadata)
  end

  test "delete_keys removes temp and cache" do
    agent = StateOpsAgent.new()
    {agent, []} = StateOpsAgent.cmd(agent, ClearTempDataAction)

    refute Map.has_key?(agent.state, :temp)
    refute Map.has_key?(agent.state, :cache)
  end

  test "set_path and delete_path mutate nested config" do
    agent = StateOpsAgent.new()

    {agent, []} =
      StateOpsAgent.cmd(agent, {SetNestedValueAction, %{path: [:config, :timeout], value: 5000}})

    assert agent.state.config.timeout == 5000

    {agent, []} =
      StateOpsAgent.cmd(agent, {DeleteNestedValueAction, %{path: [:config, :secret]}})

    refute Map.has_key?(agent.state.config, :secret)
  end
end
