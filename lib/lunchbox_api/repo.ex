defmodule LunchboxApi.Repo do
  use Ecto.Repo,
    otp_app: :lunchbox_api,
    adapter: Ecto.Adapters.Postgres
end
