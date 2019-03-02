defmodule LunchboxApiWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with channels
      use Phoenix.ChannelTest

      # The default endpoint for testing
      @endpoint LunchboxApiWeb.Endpoint
    end
  end

  setup tags do
    # :ok = Ecto.Adapters.SQL.Sandbox.checkout(LunchboxApi.Repo)
    sandbox = Application.get_env(:lunchbox_api, LunchboxApi.Repo)[:pool]
    :ok = sandbox.checkout(LunchboxApi.Repo)

    unless tags[:async] do
      # Ecto.Adapters.SQL.Sandbox.mode(LunchboxApi.Repo, {:shared, self()})
      :ok = sandbox.checkout(LunchboxApi.Repo)
    end

    # :ok
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
