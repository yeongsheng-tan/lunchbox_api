defmodule LunchboxApiWeb.AuthControllerTest do
  use LunchboxApiWeb.ConnCase, async: true

  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup %{conn: conn} do
    # Set the host for URL generation
    conn = %{conn | host: "www.example.com"}
    {:ok, conn: conn}
  end

  describe "request/2" do
    test "handles OAuth2 response errors", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :request, "github"))
      assert redirected_to(conn) =~ "github.com/login/oauth/authorize"
    end


    test "returns error for unsupported provider", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :request, "unsupported"))
      assert json_response(conn, 400) == %{"error" => "Failed to initialize OAuth client: Unsupported provider: unsupported"}
    end
  end

  describe "callback/2" do
    test "returns token and user info on successful authentication", %{conn: conn} do
      # Arrange: OAuth mock is configured in test_helper.exs to return user info

      # Act: Make the callback request with valid code
      conn = get(conn, Routes.auth_path(conn, :callback, "github"), %{"code" => "test-code"})

      # Assert: Should return token and user info from OAuth mock
      response = json_response(conn, 200)
      assert is_binary(response["token"])
      assert response["user"]["email"] == "oauth_test@example.com"
      assert response["user"]["name"] == "OAuth Test User"
      assert response["user"]["provider"] == "github"
      assert is_binary(response["user"]["id"])
    end

    test "returns error when code is missing", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :callback, "github"), %{})
      assert json_response(conn, 400) == %{"error" => "Missing required parameter: code"}
    end

    test "handles authentication failure with error message", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :callback, "github"), %{"code" => "invalid-code"})
      assert json_response(conn, 400) == %{"error" => "OAuth error: 404 - %{\"error\" => \"Not Found\"}"}
    end

    test "handles OAuth2 response errors", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :callback, "github"), %{"code" => "bad-code"})
      assert json_response(conn, 400) == %{"error" => "OAuth error: 404 - %{\"error\" => \"Not Found\"}"}
    end

  end

  describe "refresh/2" do
    test "returns not implemented", %{conn: conn} do
      conn = post(conn, Routes.auth_path(conn, :refresh), %{"refresh_token" => "test-token"})
      assert json_response(conn, 501) == %{"error" => "Token refresh not implemented"}
    end
  end

  describe "delete/2" do
    test "logs out the user", %{conn: conn} do
      conn = delete(conn, Routes.auth_path(conn, :delete))
      assert json_response(conn, 200) == %{"message" => "Logged out successfully"}
    end
  end
end
