defmodule LunchboxApiWeb.TimeControllerTest do
  import Plug.Conn
  import Phoenix.ConnTest
  import Plug.BasicAuth
  use LunchboxApiWeb.ConnCase

  # get auth username
  @username System.get_env("BASIC_AUTH_USERNAME")
  @password System.get_env("BASIC_AUTH_PASSWORD")

  # setup auth on conn
  setup %{conn: _conn} do
    conn =
      build_conn()
      |> using_basic_auth(@username, @password)
      |> put_req_header("accept", "application/json")

    {:ok, conn: conn}
  end

  # basic auth
  defp using_basic_auth(conn, username, password) do
    conn |> put_req_header("authorization", encode_basic_auth(username, password))
  end

  describe "GET /api/v1/time_now" do
    test "returns a dummy datetime string", %{conn: conn} do
      conn = get(conn, "/api/v1/time_now")

      # Verify the endpoint is reachable
      assert %{"time" => time_string} = json_response(conn, 200)
      IO.inspect time_string

    end

    # test "returns a real current datetime string", %{conn: conn} do
    #   conn = get(conn, "/api/v1/time_now")
    #   assert %{"time" => time_string} = json_response(conn, 200)
    #   IO.inspect time_string

    #   # Verify the time string is in ISO 8601 format with timezone
    #   assert {:ok, _returned_datetime, _offset} = DateTime.from_iso8601(time_string)
    # end

    # test "returns a real current datetime string in Singapore timezone", %{conn: conn} do
    #   conn = get(conn, "/api/v1/time_now")
    #   assert %{"time" => time_string} = json_response(conn, 200)
    #   IO.inspect time_string

    #   # Verify the timezone is Singapore (+08:00 or +0800)
    #   assert String.contains?(time_string, "+08:00") or String.contains?(time_string, "+0800")
    # end
  end
end
