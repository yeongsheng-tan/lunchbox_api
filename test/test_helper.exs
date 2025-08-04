ExUnit.start(
  timeout: 5_000,
  colors: [enabled: true],
  trace: false,
  capture_log: true
)

Ecto.Adapters.SQL.Sandbox.mode(LunchboxApi.Repo, :manual)
Mox.defmock(LunchboxApi.Auth.Mock, for: LunchboxApi.Auth.Behaviour)
Mox.defmock(LunchboxApi.Auth.OAuth.Mock, for: LunchboxApi.Auth.OAuth.Behaviour)
Mox.defmock(LunchboxApi.Users.Mock, for: LunchboxApi.Users.Behaviour)
Mox.defmock(LunchboxApi.Auth.JWT.Mock, for: LunchboxApi.Auth.JWT.Behaviour)


Application.put_env(:lunchbox_api, :users_impl, LunchboxApi.Users.Mock)
Application.put_env(:lunchbox_api, :jwt_impl, LunchboxApi.Auth.JWT.Mock)
Application.put_env(:lunchbox_api, :oauth_impl, LunchboxApi.Auth.OAuth.Mock)

Mox.set_mox_global()

# Fast mocks
test_user_id = "00000000-0000-4000-8000-000000000000"
test_user = %LunchboxApi.Users.User{id: test_user_id, email: "test@example.com", name: "Test User", provider: "test"}

Mox.stub(LunchboxApi.Auth.Mock, :verify_token, fn _token -> {:ok, test_user} end)
Mox.stub(LunchboxApi.Auth.Mock, :generate_token, fn _user -> {:ok, "fast.test.token"} end)
Mox.stub(LunchboxApi.Users.Mock, :get_user, fn _id -> {:ok, test_user} end)
Mox.stub(LunchboxApi.Users.Mock, :find_or_create_user, fn _provider, user_info ->
  {:ok, %LunchboxApi.Users.User{
    id: Map.get(user_info, :id, test_user_id),
    email: Map.get(user_info, :email, "test@example.com"),
    name: Map.get(user_info, :name, "Test User"),
    provider: Map.get(user_info, :provider, "test")
  }}
end)
Mox.stub(LunchboxApi.Users.Mock, :find_or_create_user, fn _provider, user_info ->
  {:ok, %LunchboxApi.Users.User{
    id: Map.get(user_info, :id, test_user_id),
    email: Map.get(user_info, :email, "test@example.com"),
    name: Map.get(user_info, :name, "Test User"),
    provider: Map.get(user_info, :provider, "test")
  }}
end)
Mox.stub(LunchboxApi.Auth.JWT.Mock, :generate_token, fn _user -> {:ok, "fast.test.token"} end)
Mox.stub(LunchboxApi.Auth.JWT.Mock, :verify_token, fn
  "fast.test.token" -> {:ok, %{"sub" => test_user_id, "email" => "test@example.com", "name" => "Test User", "provider" => "test"}}
  token ->
    # Handle tokens in format "test_token_{user_id}"
    case String.split(token, "_", parts: 3) do
      ["test", "token", user_id] -> {:ok, %{"sub" => user_id}}
      _ -> {:error, "Invalid token"}
    end
end)

# OAuth mock - only external service we mock
Mox.stub(LunchboxApi.Auth.OAuth.Mock, :client, fn provider, redirect_uri ->
  case provider do
    "github" ->
      {:ok, %OAuth2.Client{
        authorize_url: "https://github.com/login/oauth/authorize",
        token_url: "https://github.com/login/oauth/access_token",
        site: "https://api.github.com",
        client_id: "test_client",
        client_secret: "test_secret",
        redirect_uri: redirect_uri
      }}
    _ -> {:error, "Unsupported provider: #{provider}"}
  end
end)

Mox.stub(LunchboxApi.Auth.OAuth.Mock, :get_token, fn _client, params ->
  case params[:code] do
    "test-code" -> {:ok, %{token: %{access_token: "test_access_token"}}}
    "bad-code" -> {:error, %OAuth2.Response{status_code: 404, body: %{"error" => "Not Found"}}}
    "invalid-code" -> {:error, %OAuth2.Response{status_code: 404, body: %{"error" => "Not Found"}}}
    _ -> {:ok, %{token: %{access_token: "test_access_token"}}}
  end
end)

Mox.stub(LunchboxApi.Auth.OAuth.Mock, :get_user_info, fn _provider, _token ->
  {:ok, %{
    id: "oauth_user_123",
    email: "oauth_test@example.com",
    name: "OAuth Test User",
    provider: "github"
  }}
end)



# Configure ExUnit
ExUnit.configure(
  # Enable colors in test output
  colors: [enabled: true],
  # Print stacktraces
  stacktrace: true,
  # Timeout for tests (in milliseconds)
  timeout: 30_000
)

# Import all test support files
# This ensures our factory is available in all tests
