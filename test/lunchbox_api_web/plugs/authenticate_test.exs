defmodule LunchboxApiWeb.Plugs.AuthenticateTest do
  use LunchboxApiWeb.ConnCase, async: true
  
  alias LunchboxApiWeb.Plugs.Authenticate
  
  describe "call/2 - using real JWT implementation" do
    test "allows access with a valid JWT token" do
      # Arrange: Create connection with valid token
      conn = 
        build_conn()
        |> put_req_header("authorization", "Bearer fast.test.token")
      
      # Act: Call the authenticate plug
      result_conn = Authenticate.call(conn, %{})
      
      # Assert: Should authenticate successfully
      refute result_conn.halted
      assert result_conn.assigns.current_user.id == "00000000-0000-4000-8000-000000000000"
      assert result_conn.assigns.current_user.email == "test@example.com"
    end
    
    test "denies access with an invalid token" do
      # Arrange: Create connection with invalid token
      conn = 
        build_conn()
        |> put_req_header("authorization", "Bearer #{invalid_token()}")
      
      # Act: Call the authenticate plug
      result_conn = Authenticate.call(conn, %{})
      
      # Assert: Should deny access
      assert result_conn.halted
      assert result_conn.status == 401
      assert json_response(result_conn, 401)["error"] =~ "Invalid token"
    end
    
    test "denies access without authorization header" do
      # Arrange: Create connection without auth header
      conn = build_conn()
      
      # Act: Call the authenticate plug
      result_conn = Authenticate.call(conn, %{})
      
      # Assert: Should deny access
      assert result_conn.halted
      assert result_conn.status == 401
      assert json_response(result_conn, 401)["error"] == "Missing or invalid authorization header"
    end
    
    test "denies access with malformed authorization header" do
      # Arrange: Create connection with malformed auth header
      conn = 
        build_conn()
        |> put_req_header("authorization", malformed_auth_header())
      
      # Act: Call the authenticate plug
      result_conn = Authenticate.call(conn, %{})
      
      # Assert: Should deny access
      assert result_conn.halted
      assert result_conn.status == 401
      assert json_response(result_conn, 401)["error"] == "Missing or invalid authorization header"
    end
  end
end