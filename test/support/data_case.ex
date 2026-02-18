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

  @doc """
  A helper that transforms changeset errors into a map of messages.

      assert {:error, changeset} = Accounts.create_user(%{password: "short"})
      assert "should be at least 8 character(s)" in errors_on(changeset).password
  """
  def errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
