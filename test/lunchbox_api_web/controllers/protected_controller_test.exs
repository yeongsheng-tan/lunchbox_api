defmodule LunchboxApiWeb.ProtectedControllerTest do
  use LunchboxApiWeb.ConnCase, async: true
  
  # Test the authentication plug directly with a simple plug pipeline
  describe "authenticated pipeline" do
    # Create a test plug pipeline that includes our authentication
    defmodule TestPipeline do
      import Plug.Conn
      import Phoenix.Controller, only: [json: 2]
      
      # Import the plug we want to test
      alias LunchboxApiWeb.Plugs.Authenticate
      
      # Create a simple plug pipeline for testing
      def call(conn, _opts) do
        conn
        |> put_private(:phoenix_endpoint, LunchboxApiWeb.Endpoint)
        |> put_private(:phoenix_router, LunchboxApiWeb.Router)
        |> put_private(:phoenix_bypass, [])  # Required for Phoenix 1.7+
        |> put_private(:phoenix_format, "html")
        |> put_resp_header("content-type", "application/json")
        |> Authenticate.call(%{})
        |> handle_response()
      end
      
      # Handle the response after authentication
      defp handle_response(%{halted: true} = conn), do: conn
      
      defp handle_response(conn) do
        conn
        |> put_status(200)
        |> json(%{message: "Protected route accessed"})
      end
    end
    
    test "allows access with a valid JWT token" do
      # Arrange: Use the mocked valid token
      conn = 
        :get
        |> Plug.Test.conn("/test/protected")
        |> Plug.Conn.put_req_header("authorization", "Bearer fast.test.token")
        |> TestPipeline.call([])
      
      # Assert: Should allow access
      assert conn.status == 200
      assert json_response(conn, 200) == %{"message" => "Protected route accessed"}
      assert conn.assigns.current_user.id == "00000000-0000-4000-8000-000000000000"
    end
    
    test "denies access without a token" do
      # Arrange: Create a test connection without a token
      conn = 
        :get
        |> Plug.Test.conn("/test/protected")
        |> TestPipeline.call([])
      
      # Act & Assert: Should deny access
      assert conn.status == 401
      assert json_response(conn, 401) == %{"error" => "Missing or invalid authorization header"}
    end
    
    test "denies access with an invalid token" do
      # Arrange: Create a test connection with an invalid token
      conn = 
        :get
        |> Plug.Test.conn("/test/protected")
        |> Plug.Conn.put_req_header("authorization", "Bearer invalid.token.here")
        |> TestPipeline.call([])
      
      # Act & Assert: Should deny access
      assert conn.status == 401
      assert json_response(conn, 401)["error"] =~ "Invalid token"
    end
  end
end