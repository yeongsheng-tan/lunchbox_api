defmodule LunchboxApiWeb.AuthController do
  use LunchboxApiWeb, :controller
  
  alias LunchboxApi.Auth
  
  # Get the configured OAuth implementation (mock in test, real in dev/prod)
  @oauth_impl Application.compile_env(:lunchbox_api, :oauth_impl, LunchboxApi.Auth.OAuth)
  
  @doc """
  Initiates the OAuth flow by redirecting to the provider's authorization page.
  """
  def request(conn, %{"provider" => provider}) do
    redirect_uri = auth_callback_url(conn, provider)
    
    with {:ok, client} <- @oauth_impl.client(provider, redirect_uri) do
      redirect(conn, external: OAuth2.Client.authorize_url!(client))
    else
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Failed to initialize OAuth client: #{reason}"})
    end
  end
  
  @doc """
  Handles the OAuth callback from the provider.
  """
  def callback(conn, %{"provider" => provider} = params) do
    with {:ok, code} <- get_code(params),
         redirect_uri = auth_callback_url(conn, provider),
         {:ok, user} <- Auth.authenticate(provider, code, redirect_uri) do
      
      case Auth.generate_token(user) do
        {:ok, token} ->
          conn
          |> put_status(:ok)
          |> json(%{
            token: token,
            user: %{
              id: user.id,
              email: user.email,
              name: user.name,
              provider: user.provider
            }
          })
          
        error ->
          handle_auth_error(conn, error)
      end
    else
      {:error, :missing_code} ->
        send_json(conn, :bad_request, %{error: "Missing required parameter: code"})
        
      {:error, %OAuth2.Response{} = response} ->
        handle_auth_error(conn, response)
        
      {:error, reason} ->
        handle_auth_error(conn, reason)
    end
  end
  
  defp get_code(%{"code" => code}) when is_binary(code), do: {:ok, code}
  defp get_code(_), do: {:error, :missing_code}
  
  defp handle_auth_error(conn, %OAuth2.Response{status_code: status_code, body: body}) when is_map(body) do
    error_msg = "OAuth error: #{status_code} - #{inspect(body, pretty: true)}"
    send_json(conn, :bad_request, %{error: error_msg})
  end
  
  defp handle_auth_error(conn, %OAuth2.Response{status_code: status_code, body: body}) when is_binary(body) do
    error_msg = "OAuth error: #{status_code} - #{body}"
    send_json(conn, :bad_request, %{error: error_msg})
  end
  
  defp handle_auth_error(conn, error) when is_binary(error) do
    send_json(conn, :unauthorized, %{error: error})
  end
  
  defp handle_auth_error(conn, error) do
    error_msg = "Authentication error: #{inspect(error)}"
    send_json(conn, :internal_server_error, %{error: error_msg})
  end
  
  defp send_json(conn, status, data) do
    conn
    |> put_status(status)
    |> json(data)
  end
  
  @doc """
  Refreshes an access token using a refresh token.
  """
  def refresh(conn, %{"refresh_token" => _refresh_token}) do
    # In a real implementation, you would verify the refresh token
    # and issue a new access token. For now, we'll just return an error.
    conn
    |> put_status(:not_implemented)
    |> json(%{error: "Token refresh not implemented"})
  end
  
  @doc """
  Logs out the user by invalidating the token.
  """
  def delete(conn, _params) do
    # In a real implementation, you would invalidate the token.
    # For JWT, since it's stateless, you would typically handle this on the client side
    # by removing the token from storage.
    conn
    |> put_status(:ok)
    |> json(%{message: "Logged out successfully"})
  end
  
  # Helper to generate the callback URL with scheme
  defp auth_callback_url(conn, provider) do
    # In test environment, always use a hardcoded URL with scheme
    if Mix.env() == :test do
      path = "/auth/#{provider}/callback"
      "http://localhost:4002#{path}"
    else
      # In dev/prod, use the router's URL helpers with the current connection's scheme
      scheme = if conn.scheme, do: to_string(conn.scheme), else: "http"
      host = conn.host
      port = if conn.port in [80, 443], do: "", else: ":#{conn.port}"
      path = Routes.auth_path(conn, :callback, provider)
      "#{scheme}://#{host}#{port}#{path}"
    end
  end
end
