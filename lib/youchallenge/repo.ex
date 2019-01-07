defmodule Youchallenge.Repo do
  use Ecto.Repo,
    otp_app: :youchallenge,
    adapter: Ecto.Adapters.Postgres
end
