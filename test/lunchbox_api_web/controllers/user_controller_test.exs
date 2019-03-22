defmodule LunchboxApiWeb.UserControllerTest do
  use LunchboxApiWeb.ConnCase

  alias LunchboxApi.Accounts
  alias LunchboxApi.Accounts.User

  @create_attrs %{
    email: "some_email@mail.com",
    password: "some_password_098765",
    password_confirmation: "some_password_098765"
  }
  @update_attrs %{
    email: "some_updated_email@mymail.com",
    password: "some_password_zyxwv",
    password_confirmation: "some_password_zyxwv"
  }
  @invalid_attrs %{email: nil, password: nil, password_confirmation: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      hashed_password = Argon2.add_hash(@create_attrs.password)
      assert %{
               "id" => id,
               "email" => "some_email@mail.com",
               "password_hash" => hashed_password
             } = json_response(conn, 200)["data"]
      refute Map.get(json_response(conn, 200)["data"], :password)
    end
    
    test "does not create a user when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
      assert %{"email" => _email, "password" => _password} = json_response(conn, 422)["errors"]
      refute json_response(conn, 422)["meta"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
