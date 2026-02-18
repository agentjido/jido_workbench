defmodule Mix.Tasks.Accounts.PromoteAdmin do
  @shortdoc "Promotes a user to admin by email"
  @moduledoc """
  Promotes an existing user to admin by email.

      mix accounts.promote_admin admin@example.com
  """

  use Mix.Task

  @impl Mix.Task
  def run([email]) do
    Mix.Task.run("app.start")

    case AgentJido.Accounts.promote_user_to_admin_by_email(email) do
      {:ok, _user} ->
        Mix.shell().info("Promoted #{email} to admin.")

      {:error, :not_found} ->
        Mix.shell().error("No user found with email: #{email}")

      {:error, changeset} ->
        Mix.shell().error("Failed to promote #{email}: #{inspect(changeset.errors)}")
    end
  end

  def run(_args) do
    Mix.raise("Usage: mix accounts.promote_admin user@example.com")
  end
end
