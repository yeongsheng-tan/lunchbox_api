defmodule LunchboxApiWeb.AuthTestHelpers do
  @moduledoc """
  Helpers for authentication in tests.
  """
  
  import Plug.Conn
  import Mox
  
  @test_secret "test_secret"
  
  def valid_user_attrs do
    # Generate a binary ID that matches the :binary_id type in the User schema
    {:ok, binary_id} = Ecto.UUID.dump("550e8400-e29b-41d4-a716-446655440000")
    
    %{
      id: binary_id,
      email: "test@example.com",
      name: "Test User",
      provider: "test"
    }
  end
  
  def generate_valid_token(user_or_id) when is_binary(user_or_id) do
    # If a string ID is provided, create a minimal user map
    generate_valid_token(%{id: user_or_id, email: "test@example.com", name: "Test User", provider: "test"})
  end
  
  def generate_valid_token(user_attrs) when is_map(user_attrs) do
    # For testing purposes, we'll use a simple token format
    # In a real test, you'd use your actual JWT module
    header = Base.url_encode64(Jason.encode!(%{typ: "JWT", alg: "HS256"}), padding: false)
    
    # Handle different ID formats
    user_id = 
      case user_attrs.id do
        # If it's already a binary string, use it as is
        id when is_binary(id) -> id
        # If it's a map with a :value key, use that (for Ecto.UUID)
        %{value: value} -> to_string(value)
        # For any other case, convert to string
        id -> to_string(id)
      end
    
    # Use provided attributes or defaults
    email = Map.get(user_attrs, :email, "test@example.com")
    name = Map.get(user_attrs, :name, "Test User")
    provider = Map.get(user_attrs, :provider, "test")
    
    payload = %{
      "sub" => to_string(user_id),
      "email" => email,
      "name" => name,
      "provider" => provider,
      "exp" => System.system_time(:second) + 3600
    }
    
    encoded_payload = Base.url_encode64(Jason.encode!(payload), padding: false)
    signature = :crypto.mac(:hmac, :sha256, @test_secret, "#{header}.#{encoded_payload}")
    
    "#{header}.#{encoded_payload}.#{Base.url_encode64(signature, padding: false)}"
  end
  
  def add_auth_header(conn, token) do
    put_req_header(conn, "authorization", "Bearer #{token}")
  end
  
  def setup_auth_mocks do
:ok
  end
  
  def setup_oauth_success(provider) do
    stub(LunchboxApi.Auth.OAuth.Mock, :get_user_info, fn
      ^provider, %{access_token: _} -> 
        {:ok, %{
          email: "test@example.com",
          name: "Test User",
          avatar_url: "https://example.com/avatar.jpg",
          provider: provider,
          provider_id: "12345"
        }}
    end)
    
    stub(LunchboxApi.Auth.Mock, :generate_token, fn _user -> 
      {:ok, "test.token.here"} 
    end)
  end
  
  def setup_oauth_failure(provider) do
    stub(LunchboxApi.Auth.OAuth.Mock, :get_user_info, fn
      ^provider, _token -> {:error, "Authentication failed"}
    end)
  end
end
