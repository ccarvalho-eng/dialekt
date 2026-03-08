defmodule Dialekt.Repo do
  use Ecto.Repo,
    otp_app: :dialekt,
    adapter: Ecto.Adapters.Postgres
end
