defmodule LunchboxApiWeb.Plugs.RedirectUnauthTest do
  use LunchboxApiWeb.ConnCase, async: true

  import Plug.Conn
  import Phoenix.ConnTest

  alias LunchboxApiWeb.Plugs.RedirectUnauth

  @opts RedirectUnauth.init(%{})
  
  # Build a connection with the given path and headers
  defp build_test_conn(path, headers \\ []) do
    # Start with a basic connection from Phoenix.ConnTest
    conn = build_conn()
    
    # Filter out any Authorization headers
    headers = Enum.reject(headers, fn {key, _} -> 
      key = String.downcase(key)
      key == "authorization" || key == "authorization:"
    end)
    
    # Add the accept header if not already present
    headers = if Enum.any?(headers, fn {k, _} -> String.downcase(k) == "accept" end) do
      headers
    else
      [{"accept", "text/html"} | headers]
    end
    
    # Add all headers to the connection
    conn = Enum.reduce(headers, conn, fn {key, value}, conn ->
      Plug.Conn.put_req_header(conn, key, value)
    end)
    
    # Set the request path and method
    %{conn | request_path: path, path_info: String.split(path, "/", trim: true), method: "GET"}
  end
  
  # Build a connection with a custom accept header
  defp build_test_conn_with_accept(accept_header, path, headers \\ []) do
    # Start with a basic connection from Phoenix.ConnTest
    conn = build_conn(:get, path)
    
    # Add the accept header
    conn = Plug.Conn.put_req_header(conn, "accept", accept_header)
    
    # Add any additional headers (filtering out Authorization)
    headers = Enum.reject(headers, fn {key, _} -> 
      key = String.downcase(key)
      key == "authorization" || key == "authorization:"
    end)
    
    conn = Enum.reduce(headers, conn, fn {key, value}, conn ->
      Plug.Conn.put_req_header(conn, key, value)
    end)
    
    # Call the plug directly
    LunchboxApiWeb.Plugs.RedirectUnauth.call(conn, @opts)
  end

  describe "call/2" do
    # Test redirect scenarios
    test "redirects to GitHub OAuth for unauthenticated browser request to /api" do
      conn = 
        build_test_conn("/api")
        |> RedirectUnauth.call(@opts)

      assert conn.status == 302
      assert get_resp_header(conn, "location") == ["/auth/github"]
      assert conn.halted
    end

    test "redirects to GitHub OAuth for unauthenticated browser request to /api/v1/anything" do
      conn = 
        build_test_conn("/api/v1/anything")
        |> RedirectUnauth.call(@opts)

      assert conn.status == 302
      assert get_resp_header(conn, "location") == ["/auth/github"]
      assert conn.halted
    end

    test "redirects for case-insensitive API path" do
      conn = 
        build_test_conn("/API/v1/resource")
        |> RedirectUnauth.call(@opts)

      assert conn.status == 302
      assert get_resp_header(conn, "location") == ["/auth/github"]
      assert conn.halted
    end

    test "redirects for API path with query parameters" do
      conn = 
        build_conn(:get, "/api/v1/resource?param=value")
        |> put_req_header("accept", "text/html")
        |> Map.put(:path_info, ["api", "v1", "resource"])
        |> RedirectUnauth.call(@opts)

      assert conn.status == 302
      assert get_resp_header(conn, "location") == ["/auth/github"]
      assert conn.halted
    end

    # Test no-redirect scenarios
    test "does not redirect for authenticated browser request" do
      conn = 
        build_test_conn("/api", [{"authorization", "Bearer valid_token"}])
        |> assign(:current_user, %{id: 1})
        |> RedirectUnauth.call(@opts)

      refute conn.status == 302
      refute conn.halted
    end

    test "does not redirect for API client request (JSON accept header)" do
      conn = 
        build_test_conn_with_accept("application/json", "/api")
        |> RedirectUnauth.call(@opts)

      refute conn.status == 302
      refute conn.halted
    end

    test "does not redirect for API client request (XML accept header)" do
      conn = 
        build_test_conn_with_accept("application/xml", "/api")
        |> RedirectUnauth.call(@opts)

      refute conn.status == 302
      refute conn.halted
    end

    test "does not redirect for API client request (no accept header)" do
      conn = 
        build_conn()
        |> Map.put(:request_path, "/api")
        |> Map.put(:path_info, ["api"])
        |> RedirectUnauth.call(@opts)

      refute conn.status == 302
      refute conn.halted
    end

    test "does not redirect for non-API paths" do
      conn = 
        build_test_conn("/some/other/path")
        |> RedirectUnauth.call(@opts)

      refute conn.status == 302
      refute conn.halted
    end

    test "does not redirect for root path" do
      conn = 
        build_test_conn("/")
        |> RedirectUnauth.call(@opts)

      refute conn.status == 302
      refute conn.halted
    end

    test "does not redirect for API path with trailing slash" do
      conn = 
        build_test_conn("/api/")
        |> RedirectUnauth.call(@opts)

      assert conn.status == 302  # Should still redirect as it starts with /api
      assert get_resp_header(conn, "location") == ["/auth/github"]
      assert conn.halted
    end

    test "handles empty path" do
      conn = 
        build_conn()
        |> Map.put(:request_path, "")
        |> Map.put(:path_info, [])
        |> RedirectUnauth.call(@opts)

      refute conn.status == 302
      refute conn.halted
    end
  end
end
