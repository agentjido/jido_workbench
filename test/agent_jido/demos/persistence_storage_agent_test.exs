defmodule AgentJido.Demos.PersistenceStorageAgentTest do
  use ExUnit.Case, async: true

  alias AgentJido.Demos.PersistenceStorage.{AddNoteAction, IncrementAction}
  alias AgentJido.Demos.PersistenceStorageAgent
  alias Jido.Persist
  alias Jido.Storage.ETS

  test "hibernate and thaw preserve updated state" do
    table = String.to_atom("persist_storage_test_#{System.unique_integer([:positive])}")
    storage = {ETS, table: table}

    agent = PersistenceStorageAgent.new(id: "persist-1")
    {agent, []} = PersistenceStorageAgent.cmd(agent, {IncrementAction, %{amount: 5}})
    {agent, []} = PersistenceStorageAgent.cmd(agent, {AddNoteAction, %{note: "saved"}})

    :ok = Persist.hibernate(storage, agent)

    assert {:ok, restored} = Persist.thaw(storage, PersistenceStorageAgent, "persist-1")
    assert restored.state.counter == 5
    assert restored.state.notes == ["saved"]
  end

  test "thaw returns not_found when checkpoint is absent" do
    table = String.to_atom("persist_storage_test_#{System.unique_integer([:positive])}")
    storage = {ETS, table: table}

    assert {:error, :not_found} = Persist.thaw(storage, PersistenceStorageAgent, "missing")
  end
end
