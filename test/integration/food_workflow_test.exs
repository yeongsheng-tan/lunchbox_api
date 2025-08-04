defmodule LunchboxApi.Integration.FoodWorkflowTest do
  @moduledoc """
  Integration tests for complete food management workflows.
  Tests the full stack from HTTP request to database persistence.
  """

  use LunchboxApiWeb.ConnCase, async: false

  import LunchboxApi.TestAssertions
  import LunchboxApi.AuthTestSupport
  alias LunchboxApi.Lunchbox.Food

  setup do
    :ok
  end

  describe "Complete food management workflow" do
    test "user can create, read, update, and delete foods", %{conn: conn} do
      # Arrange: Create authenticated user
      {authed_conn, user, _token} = create_authenticated_conn(conn)

      # Act & Assert: CREATE - User creates a new food
      create_attrs = %{name: "Integration Test Food", status: "available", user_id: user.id}
      create_response = post(authed_conn, Routes.food_path(authed_conn, :create), food: create_attrs)
      food_id = assert_creation_success(create_response)

      # Verify food exists in database
      created_food = Repo.get!(Food, food_id)
      assert created_food.name == "Integration Test Food"
      assert created_food.user_id == user.id

      # Act & Assert: READ - User retrieves the food
      read_response = get(authed_conn, Routes.food_path(authed_conn, :show, food_id))
      assert_food_response(read_response, created_food)

      # Act & Assert: UPDATE - User updates the food
      update_attrs = %{name: "Updated Integration Food", status: "unavailable"}
      update_response = patch(authed_conn, Routes.food_path(authed_conn, :update, food_id), food: update_attrs)
      assert json_response(update_response, 200)

      # Verify update persisted
      updated_food = Repo.get!(Food, food_id)
      assert updated_food.name == "Updated Integration Food"
      assert updated_food.status == "unavailable"

      # Act & Assert: DELETE - User deletes the food
      delete_response = delete(authed_conn, Routes.food_path(authed_conn, :delete, food_id))
      assert_deletion_success(delete_response)

      # Verify deletion
      refute Repo.get(Food, food_id)
    end

    test "user isolation - users can only access their own foods", %{conn: conn} do
      # Arrange: Create two users with different IDs for proper isolation
      {user1_conn, user1, _} = create_authenticated_conn(conn, %{
        id: "11111111-1111-4111-8111-111111111111"
      })
      {user2_conn, _user2, _} = create_authenticated_conn(conn, %{
        id: "22222222-2222-4222-8222-222222222222",
        email: "user2@example.com",
        provider_id: "test_user_2_#{System.unique_integer()}"
      })

      # User 1 creates a food
      create_attrs = %{name: "User 1 Food", status: "available", user_id: user1.id}
      create_response = post(user1_conn, Routes.food_path(user1_conn, :create), food: create_attrs)
      food_id = assert_creation_success(create_response)

      # Act & Assert: User 2 cannot access User 1's food
      read_response = get(user2_conn, Routes.food_path(user2_conn, :show, food_id))
      assert_not_found(read_response)

      # Act & Assert: User 2 cannot update User 1's food
      update_response = patch(user2_conn, Routes.food_path(user2_conn, :update, food_id), food: %{name: "Hacked"})
      assert_not_found(update_response)

      # Act & Assert: User 2 cannot delete User 1's food
      delete_response = delete(user2_conn, Routes.food_path(user2_conn, :delete, food_id))
      assert_not_found(delete_response)

      # Verify food still exists and unchanged
      food = Repo.get!(Food, food_id)
      assert food.name == "User 1 Food"
      assert food.user_id == user1.id
    end

    test "authentication required for all food operations", %{conn: conn} do
      # Arrange: Create a food with authenticated user first
      {authed_conn, user, _} = create_authenticated_conn(conn)
      create_attrs = %{name: "Auth Test Food", status: "available", user_id: user.id}
      create_response = post(authed_conn, Routes.food_path(authed_conn, :create), food: create_attrs)
      food_id = assert_creation_success(create_response)

      # Act & Assert: Unauthenticated requests should fail
      unauth_conn = build_conn() |> put_req_header("accept", "application/json")

      # LIST
      list_response = get(unauth_conn, Routes.food_path(unauth_conn, :index))
      assert list_response.status == 401

      # READ
      read_response = get(unauth_conn, Routes.food_path(unauth_conn, :show, food_id))
      assert read_response.status == 401

      # CREATE
      create_response = post(unauth_conn, Routes.food_path(unauth_conn, :create), food: create_attrs)
      assert create_response.status == 401

      # UPDATE
      update_response = patch(unauth_conn, Routes.food_path(unauth_conn, :update, food_id), food: %{name: "Hacked"})
      assert update_response.status == 401

      # DELETE
      delete_response = delete(unauth_conn, Routes.food_path(unauth_conn, :delete, food_id))
      assert delete_response.status == 401
    end
  end
end
