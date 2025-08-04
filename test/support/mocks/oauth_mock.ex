defmodule LunchboxApi.Auth.OAuth.Mock do
  @moduledoc """
  Mock for the OAuth module - GitHub only.
  """
  @behaviour LunchboxApi.Auth.OAuth.Behaviour

  alias OAuth2.{Client, Response}

  @impl true
  def client("github", redirect_uri) do
    config = Application.get_env(:lunchbox_api, :github_oauth)

    client = %Client{
      client_id: config[:client_id],
      client_secret: config[:client_secret],
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token",
      redirect_uri: redirect_uri,
      site: "https://github.com"
    }

    {:ok, client}
  end

  def client(provider, _redirect_uri) do
    {:error, "Unsupported provider: #{provider}"}
  end

  @impl true
  def get_token(client, code: code) do
    # Simulate a successful token response
    token = %OAuth2.AccessToken{
      access_token: "test_access_token_#{code}",
      token_type: "Bearer",
      expires_at: System.system_time(:second) + 3600,
      refresh_token: "test_refresh_token_#{code}",
      other_params: %{"scope" => "user:email"}
    }

    {:ok, %{client | token: token}}
  end

  @impl true
  def get_user_info("github", %{access_token: _token}) do
    {:ok, %{
      email: "test@example.com",
      name: "Test User",
      avatar_url: "https://example.com/avatar.jpg",
      provider: "github",
      provider_id: "12345"
    }}
  end

  def get_user_info(provider, _token) do
    {:error, %Response{
      status_code: 400,
      body: %{"error" => "Unsupported provider: #{provider}"}
    }}
  end
end
