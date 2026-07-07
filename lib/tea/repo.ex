defmodule Tea.Repo do
  use Ecto.Repo,
    otp_app: :tea,
    adapter: Ecto.Adapters.Postgres
end
