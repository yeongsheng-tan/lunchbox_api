defmodule LunchboxApiWeb.FoodControllerTest do
  use LunchboxApiWeb.ConnCase

  alias LunchboxApi.Accounts
  alias LunchboxApi.Lunchbox
  alias LunchboxApi.Lunchbox.Food
  alias Plug.Test

  @create_attrs %{
    name: "some name",
    status: "some status"
  }
  @update_attrs %{
    name: "some updated name",
    status: "some updated status"
  }
  @invalid_attrs %{name: nil, status: nil}
  @user_attrs %{
    email: "test_user@gmail.com",
    password: "p@55W0rD",
    password_confirmation: "p@55W0rD"
  }

  setup %{conn: conn} do
    {:ok, conn: conn, current_user: current_user} = setup_current_user(conn)
    # create the jwt token
    {:ok, token, _claims} = LunchboxApi.Guardian.encode_and_sign(current_user)
    # add authorization header to request
    conn = conn
    |> put_req_header("authorization", "Bearer #{token}")
    |> put_req_header("accept", "application/json")
    {:ok, conn: conn, current_user: current_user}
  end

  def fixture(:food) do
    {:ok, food} = Lunchbox.create_food(@create_attrs)
    food
  end

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  def fixture(:current_user) do
    {:ok, current_user} = Accounts.create_user(@user_attrs)
    current_user
  end

  describe "index" do
    test "lists all foods", %{conn: conn} do
      conn = get(conn, Routes.food_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create food" do
    test "renders food when data is valid", %{conn: conn} do
      conn = post(conn, Routes.food_path(conn, :create), food: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.food_path(conn, :show, id))

      assert %{
               "id" => id,
               "name" => "some name",
               "status" => "some status"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.food_path(conn, :create), food: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

   describe "update food" do
     setup [:create_food]

     test "renders food when data is valid", %{conn: conn, food: %Food{id: id} = food} do
       conn = put(conn, Routes.food_path(conn, :update, food), food: @update_attrs)
       assert %{"id" => ^id} = json_response(conn, 200)["data"]

       conn = get(conn, Routes.food_path(conn, :show, id))

       assert %{
                "id" => id,
                "name" => "some updated name",
                "status" => "some updated status"
              } = json_response(conn, 200)["data"]
     end

     test "renders errors when data is invalid", %{conn: conn, food: food} do
       conn = put(conn, Routes.food_path(conn, :update, food), food: @invalid_attrs)
       assert json_response(conn, 422)["errors"] != %{}
     end
   end

   describe "delete food" do
     setup [:create_food]

     test "deletes chosen food", %{conn: conn, food: food} do
       conn = delete(conn, Routes.food_path(conn, :delete, food))
       assert response(conn, 204)

       assert_error_sent 404, fn ->
         get(conn, Routes.food_path(conn, :show, food))
       end
     end
   end

  defp create_food(_) do
    food = fixture(:food)
    {:ok, food: food}
  end

  defp setup_current_user(conn) do
    current_user = fixture(:current_user)

    {:ok,
     conn: Test.init_test_session(conn, current_user_id: current_user.id),
     current_user: current_user}
  end
end
