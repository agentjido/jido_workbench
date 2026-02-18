# Script for populating the database.
#
# Run with:
#   mix run priv/repo/seeds.exs

alias AgentJido.Accounts

case System.get_env("ADMIN_EMAIL") do
  email when is_binary(email) and email != "" ->
    case Accounts.get_user_by_email(email) do
      nil ->
        {:ok, user} = Accounts.register_user(%{email: email})
        {:ok, _admin_user} = Accounts.promote_user_to_admin(user)
        IO.puts("Created admin user: #{email}")

      user ->
        {:ok, _admin_user} = Accounts.promote_user_to_admin(user)
        IO.puts("Promoted existing user to admin: #{email}")
    end

  _ ->
    :ok
end
