defmodule LunchboxApiWeb.FoodControllerTest do
  use LunchboxApiWeb.ConnCase, async: true
  
  alias LunchboxApi.Lunchbox.Food
  import LunchboxApi.TestAssertions
  
  # Test data constants
  @update_attrs %{name: "Updated Food", status: "unavailable"}
  @invalid_attrs %{name: nil, status: nil}
  
  # Clean setup - only what's needed for food tests
  setup %{conn: conn} do
    # Arrange: Create authenticated connection with real user (needed for food associations)
    {authed_conn, user, _token} = create_authenticated_conn(conn)
    
    {:ok, conn: authed_conn, user: user}
  end

  describe "GET /api/v1/foods" do
    test "returns a list of foods for the current user", %{conn: conn, user: user} do
      # Arrange: Create user's foods and another user's food for isolation testing
      user_foods = [
        insert(:food, user: user, name: "User Food 1"),
        insert(:food, user: user, name: "User Food 2")
      ]
      _other_user_food = insert(:food, user: insert(:user), name: "Other Food")
      
      # Act
      response = get(conn, Routes.food_path(conn, :index))
      
      # Assert: Should return only current user's foods
      assert_food_list_response(response, user_foods)
    end
    
    test "returns empty list when no foods exist", %{conn: conn} do
      # Act
      response = get(conn, Routes.food_path(conn, :index))
      
      # Assert
      assert json_response(response, 200) == %{"data" => []}
    end
  end
  
  describe "GET /api/v1/foods/:id" do
    test "returns the requested food when it exists and belongs to user", %{conn: conn, user: user} do
      # Arrange
      food = insert(:food, user: user, name: "My Food")
      
      # Act
      response = get(conn, Routes.food_path(conn, :show, food.id))
      
      # Assert: Should return the specific food with correct structure
      assert_food_response(response, food)
    end
    
    test "returns 404 when food does not exist", %{conn: conn} do
      # Arrange: Use non-existent food ID
      non_existent_id = Ecto.UUID.generate()
      
      # Act
      response = get(conn, Routes.food_path(conn, :show, non_existent_id))
      
      # Assert: Should return 404 for non-existent resource
      assert_not_found(response)
    end
    
    test "returns 404 when food belongs to another user", %{conn: conn} do
      # Arrange
      other_user = insert(:user)
      food = insert(:food, user: other_user)
      
      # Act
      response = get(conn, Routes.food_path(conn, :show, food.id))
      
      # Assert
      assert response.status == 404
    end
  end
  
  describe "POST /api/v1/foods" do
    test "creates a food with valid data", %{conn: conn, user: user} do
      # Arrange
      food_attrs = %{name: "New Food", status: "available", user_id: user.id}
      
      # Act
      response = post(conn, Routes.food_path(conn, :create), food: food_attrs)
      
      # Assert: Should create food successfully
      created_id = assert_creation_success(response)
      
      # Verify: Food was persisted with correct attributes
      created_food = Repo.get!(Food, created_id)
      assert created_food.name == food_attrs.name
      assert created_food.status == food_attrs.status
      assert created_food.user_id == user.id
    end
    
    test "returns validation errors with invalid data", %{conn: conn} do
      # Arrange
      invalid_attrs = %{name: nil, status: nil}
      
      # Act
      response = post(conn, Routes.food_path(conn, :create), food: invalid_attrs)
      
      # Assert: Should return validation errors
      assert_validation_errors(response)
    end
  end
  
  describe "PATCH /api/v1/foods/:id" do
    test "updates the food when data is valid", %{conn: conn, user: user} do
      # Arrange
      food = insert(:food, user: user, name: "Old Name")
      
      # Act
      response = patch(conn, Routes.food_path(conn, :update, food.id), food: @update_attrs)
      
      # Assert
      assert %{"data" => %{"id" => id}} = json_response(response, 200)
      
      # Verify the food was updated in the database
      updated_food = Repo.get!(Food, id)
      assert updated_food.name == @update_attrs.name
      assert updated_food.status == @update_attrs.status
    end
    
    test "returns error when updating with invalid data", %{conn: conn, user: user} do
      # Arrange
      food = insert(:food, user: user)
      
      # Act
      response = patch(conn, Routes.food_path(conn, :update, food.id), food: @invalid_attrs)
      
      # Assert
      assert json_response(response, 422)["errors"] != %{}
    end
    
    test "returns 404 when updating non-existent food", %{conn: conn} do
      # Act
      response = patch(conn, Routes.food_path(conn, :update, Ecto.UUID.generate()), food: @update_attrs)
      
      # Assert
      assert response.status == 404
    end
    
    test "returns 404 when updating food owned by another user", %{conn: conn} do
      # Arrange
      other_user = insert(:user)
      food = insert(:food, user: other_user)
      
      # Act
      response = patch(conn, Routes.food_path(conn, :update, food.id), food: @update_attrs)
      
      # Assert
      assert response.status == 404
    end
  end
  
  describe "DELETE /api/v1/foods/:id" do
    test "deletes the food", %{conn: conn, user: user} do
      # Arrange
      food = insert(:food, user: user)
      
      # Act
      response = delete(conn, Routes.food_path(conn, :delete, food.id))
      
      # Assert
      assert response.status == 204
      
      # Verify the food was deleted from the database
      refute Repo.get(Food, food.id)
    end
    
    test "returns 404 when deleting non-existent food", %{conn: conn} do
      # Act
      response = delete(conn, Routes.food_path(conn, :delete, Ecto.UUID.generate()))
      
      # Assert
      assert response.status == 404
    end
    
    test "returns 404 when deleting food owned by another user", %{conn: conn} do
      # Arrange
      other_user = insert(:user)
      food = insert(:food, user: other_user)
      
      # Act
      response = delete(conn, Routes.food_path(conn, :delete, food.id))
      
      # Assert
      assert response.status == 404
      
      # Verify the food was not deleted
      assert Repo.get(Food, food.id)
    end
  end
end
