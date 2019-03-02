ExUnit.start()
# Ecto.Adapters.SQL.Sandbox.mode(LunchboxApi.Repo, :manual)
sandbox = Application.get_env(:lunchbox_api, LunchboxApi.Repo)[:pool]
sandbox.mode(LunchboxApi.Repo, :manual)
