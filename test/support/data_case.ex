defmodule AgentJido.DataCase do
  @moduledoc """
  Test case template for tests that need database access.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      alias AgentJido.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import AgentJido.DataCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(AgentJido.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(AgentJido.Repo, {:shared, self()})
    end

    :ok
  end
end
