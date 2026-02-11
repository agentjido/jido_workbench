defmodule AgentJido.Repo do
  use Ecto.Repo,
    otp_app: :agent_jido,
    adapter: Ecto.Adapters.Postgres

  @impl true
  def init(_type, config) do
    {:ok, Keyword.put(config, :priv, "priv/repo")}
  end
end
