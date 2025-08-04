defmodule LunchboxApi.AuthTestSupport do
  @moduledoc """
  Authentication test support using real implementations.
  Follows FAST principles - each test gets its own clean auth state.
  """

  import LunchboxApi.Factory
  alias LunchboxApi.TestData

  @doc """
  Creates an authenticated connection with database user for tests that need persistence.
  """
  def create_authenticated_conn(conn, user_overrides \\ %{}) do
    default_id = if Map.has_key?(user_overrides, :id), do: user_overrides.id, else: "00000000-0000-4000-8000-000000000000"
    user_attrs = TestData.user_attrs(Map.merge(%{id: default_id}, user_overrides))
    user = insert(:user, user_attrs)

    token = "test_token_#{user.id}"
    authed_conn =
      conn
      |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")

    {authed_conn, user, token}
  end

  @doc """
  Creates a lightweight authenticated connection for unit tests.
  """
  def create_lightweight_auth_conn(conn, user_overrides \\ %{}) do
    user_attrs = TestData.user_attrs(user_overrides)
    user = struct(LunchboxApi.Users.User, Map.put(user_attrs, :id, "00000000-0000-4000-8000-000000000000"))

    token = "test_token_#{user.id}"
    authed_conn =
      conn
      |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")

    {authed_conn, user, token}
  end

  @doc """
  Creates an invalid token for testing authentication failures.
  """
  def invalid_token, do: "invalid.jwt.token"

  @doc """
  Creates a malformed auth header for testing.
  """
  def malformed_auth_header, do: "InvalidFormat"

  @doc """
  Creates an authenticated connection with real JWT token for integration tests.
  This bypasses mocks and uses the actual JWT implementation.
  """
  def create_real_authenticated_conn(conn, user_overrides \\ %{}) do
    user_attrs = TestData.user_attrs(user_overrides)
    user = insert(:user, user_attrs)

    {:ok, token} = LunchboxApi.Auth.JWT.generate_token(user)

    authed_conn =
      conn
      |> Plug.Conn.put_req_header("authorization", "Bearer #{token}")

    {authed_conn, user, token}
  end
end
