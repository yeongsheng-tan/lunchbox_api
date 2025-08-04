defmodule LunchboxApi.TestHelpers do
  @moduledoc """
  Fast test helpers using mocks for speed.
  """
  
  import LunchboxApi.Factory
  
  @test_user_id "00000000-0000-4000-8000-000000000000"
  @test_token "fast.test.token"
  
  @doc """
  Creates a fast authenticated connection using mocked services.
  This is the fastest option for most tests.
  """
  def create_fast_authenticated_conn(conn, _user_attrs \\ %{}) do
    # Use the test user that matches our global mocks
    user = %LunchboxApi.Users.User{
      id: @test_user_id,
      email: "test@example.com",
      name: "Test User",
      provider: "test"
    }
    
    # Add authentication header with the mocked token
    authed_conn = 
      conn
      |> Plug.Conn.put_req_header("authorization", "Bearer #{@test_token}")
    
    {authed_conn, user, @test_token}
  end
  
  @doc """
  Creates an authenticated connection with real database user.
  Only use when you need database persistence for the test.
  """
  def create_authenticated_conn(conn, user_attrs \\ %{}) do
    # Create a real user in the database
    user = insert(:user, Map.merge(%{id: @test_user_id}, user_attrs))
    
    # Use the mocked token
    authed_conn = 
      conn
      |> Plug.Conn.put_req_header("authorization", "Bearer #{@test_token}")
    
    {authed_conn, user, @test_token}
  end
  
  @doc """
  Creates a lightweight user struct for testing without DB operations.
  """
  def build_test_user(attrs \\ %{}) do
    base_attrs = %{
      id: @test_user_id,
      email: "test@example.com",
      name: "Test User",
      provider: "test",
      provider_id: "test_123",
      inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
    
    struct(LunchboxApi.Users.User, Map.merge(base_attrs, attrs))
  end
end