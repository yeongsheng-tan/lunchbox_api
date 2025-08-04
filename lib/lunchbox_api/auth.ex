defmodule LunchboxApi.Auth do
  @moduledoc """
  Authentication context for handling JWT and OAuth2 authentication.
  """
  @behaviour LunchboxApi.Auth.Behaviour

  defp jwt_impl do
    Application.get_env(:lunchbox_api, :jwt_impl, LunchboxApi.Auth.JWT)
  end

  defp users_impl do
    Application.get_env(:lunchbox_api, :users_impl, LunchboxApi.Users)
  end

  defp oauth_impl do
    Application.get_env(:lunchbox_api, :oauth_impl, LunchboxApi.Auth.OAuth)
  end

  @doc """
  Authenticates a user via OAuth2 provider.
  """
  @spec authenticate(String.t(), String.t(), String.t()) :: {:ok, map()} | {:error, String.t()}
  def authenticate(provider, code, redirect_uri) do
    require Logger
    Logger.debug("Auth.authenticate/3 - Starting authentication for provider: #{provider}")

    with {:ok, client} <- oauth_impl().client(provider, redirect_uri) do
      Logger.debug("Auth.authenticate/3 - Got client for provider: #{provider}")

      # Use the OAuth implementation's get_token/2 function instead of OAuth2.Client.get_token/2
      case oauth_impl().get_token(client, code: code) do
        {:ok, %{token: token} = _client_with_token} ->
          Logger.debug("Auth.authenticate/3 - Got token for provider: #{provider}")

          case oauth_impl().get_user_info(provider, token) do
            {:ok, user_info} ->
              Logger.debug("Auth.authenticate/3 - Got user info for provider: #{provider}")
              users_impl().find_or_create_user(provider, user_info)

            error ->
              Logger.error("Auth.authenticate/3 - Error getting user info: #{inspect(error)}")
              error
          end

        error ->
          Logger.error("Auth.authenticate/3 - Error getting token: #{inspect(error)}")
          error
      end
    else
      error ->
        Logger.error("Auth.authenticate/3 - Error getting client: #{inspect(error)}")
        error
    end
  end

  @doc """
  Generates a JWT token for the given user.
  """
  @spec generate_token(map()) :: {:ok, String.t()}
  def generate_token(user) do
    jwt_impl().generate_token(user)
  end

  @doc """
  Verifies a JWT token and returns the associated user.
  """
  @spec verify_token(String.t()) :: {:ok, map()} | {:error, String.t()}
  def verify_token(token) do
    with {:ok, claims} <- jwt_impl().verify_token(token),
         user_id <- Map.get(claims, "sub"),
         {:ok, user} <- users_impl().get_user(user_id) do
      {:ok, user}
    else
      error -> error
    end
  end
end
