defmodule LunchboxApi.Auth.Mock do
  @moduledoc """
  Mock for the Auth context - GitHub only.
  """
  @behaviour LunchboxApi.Auth.Behaviour

  alias LunchboxApi.Users.Mock, as: UsersMock

  @test_email "test@example.com"
  @test_name "Test User"

  @impl true
  def authenticate(provider, code, _redirect_uri) do
    case {provider, code} do
      {"github", _} ->
        # Generate a test user for GitHub auth
        with {:ok, test_user} <- UsersMock.create_user(%{
          email: @test_email,
          name: @test_name,
          provider: provider
        }) do
          {:ok, test_user}
        end

      {_, "invalid-code"} ->
        # Return a 404 error as expected by the test
        {:error, %OAuth2.Response{
          status_code: 404,
          body: %{"error" => "Not Found"},
          headers: [{"content-type", "application/json"}]
        }}

      {_, "bad-code"} ->
        # Return a 401 error as expected by the test
        {:error, %OAuth2.Response{
          status_code: 401,
          body: %{"error" => "Invalid credentials"},
          headers: [{"content-type", "application/json"}]
        }}

      _ ->
        # For any other case, return a 400 error
        {:error, %OAuth2.Response{
          status_code: 400,
          body: %{"error" => "Invalid OAuth configuration"},
          headers: [{"content-type", "application/json"}]
        }}
    end
  end

  @impl true
  def generate_token(user) do
    case user do
      %{id: id} ->
        # Generate a JWT-like token with the user ID
        token = "valid.token.#{id}"
        {:ok, token}
      _ ->
        {:error, oauth_error(400, "Invalid user")}
    end
  end

  @impl true
  def verify_token(token) when is_binary(token) do
    case String.split(token, ".") do
      ["valid", "token", user_id] ->
        # Extract user ID from token and look up the user
        case UsersMock.get_user(user_id) do
          {:ok, user} -> {:ok, user}
          _ -> {:error, oauth_error(404, "User not found")}
        end

      ["expired", "token", _] ->
        {:error, oauth_error(401, "Token expired")}

      _ ->
        {:error, oauth_error(400, "Invalid token")}
    end
  end

  # Helper to create an OAuth2 error response
  defp oauth_error(status_code, message) do
    %OAuth2.Response{
      status_code: status_code,
      body: %{"error" => message},
      headers: [{"content-type", "application/json"}]
    }
  end
end
