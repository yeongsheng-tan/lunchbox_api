defmodule LunchboxApi.Auth.OAuth do
  @moduledoc """
  OAuth2 client configuration and user info retrieval for GitHub.
  """
  @behaviour LunchboxApi.Auth.OAuth.Behaviour

  alias OAuth2.{Client, Response}

  @github_auth_url "https://github.com/login/oauth/authorize"
  @github_token_url "https://github.com/login/oauth/access_token"
  @github_user_url "https://api.github.com/user"
  @github_user_email_url "https://api.github.com/user/emails"

  # Get the configured implementation (mock in test, real in dev/prod)
  defp impl do
    Application.get_env(:lunchbox_api, :oauth_impl, __MODULE__)
  end

  @doc """
  Returns the OAuth2 client for the given provider.
  """
  @spec client(String.t(), String.t()) :: {:ok, OAuth2.Client.t()} | {:error, String.t()}
  def client(provider, redirect_uri) do
    if impl() == __MODULE__ do
      # Use real implementation
      case provider do
        "github" -> github_client(redirect_uri)
        _ -> {:error, "Unsupported provider: #{provider}"}
      end
    else
      # Delegate to the configured implementation (e.g., mock in tests)
      impl().client(provider, redirect_uri)
    end
  end

  @doc """
  Exchanges an authorization code for an access token.
  """
  @spec get_token(OAuth2.Client.t(), keyword()) :: {:ok, OAuth2.Client.t()} | {:error, OAuth2.Response.t() | String.t()}
  def get_token(client, params) do
    if impl() == __MODULE__ do
      # Use real implementation
      OAuth2.Client.get_token(client, params)
    else
      # Delegate to the configured implementation (e.g., mock in tests)
      impl().get_token(client, params)
    end
  end

  @doc """
  Fetches user information from the OAuth2 provider.
  """
  @spec get_user_info(String.t(), map()) :: {:ok, map()} | {:error, String.t()}
  def get_user_info(provider, token) do
    if impl() == __MODULE__ do
      # Use real implementation
      case provider do
        "github" -> get_github_user(token)
        _ -> {:error, "Unsupported provider: #{provider}"}
      end
    else
      # Delegate to the configured implementation (e.g., mock in tests)
      impl().get_user_info(provider, token)
    end
  end

  defp github_client(redirect_uri) do
    config = Application.get_env(:lunchbox_api, :github_oauth)

    client = OAuth2.Client.new([
      client_id: config[:client_id],
      client_secret: config[:client_secret],
      authorize_url: @github_auth_url,
      token_url: @github_token_url,
      redirect_uri: redirect_uri,
      params: %{scope: "user:email"}
    ])

    {:ok, client}
  end

  defp get_github_user(%{access_token: access_token} = _token) do
    with {:ok, %Response{body: user, status_code: 200}} <-
           Client.get(Client.new(token: access_token), @github_user_url),
         {:ok, %Response{body: emails, status_code: 200}} <-
           Client.get(Client.new(token: access_token), @github_user_email_url) do
      primary_email = emails |> Enum.find(&(&1["primary"]))

      user_info = %{
        email: primary_email["email"],
        name: user["name"] || user["login"],
        avatar_url: user["avatar_url"],
        provider: "github",
        provider_id: to_string(user["id"])
      }

      {:ok, user_info}
    else
      error -> {:error, "Failed to fetch GitHub user: #{inspect(error)}"}
    end
  end
end
