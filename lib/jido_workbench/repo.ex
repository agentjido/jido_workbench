defmodule JidoWorkbench.Repo do
  use Ecto.Repo,
    otp_app: :jido_workbench,
    adapter: Ecto.Adapters.Postgres
end
