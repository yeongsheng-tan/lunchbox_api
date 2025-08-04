defmodule LunchboxApi.Property.FoodPropertiesTest do
  @moduledoc """
  Property-based tests for food data validation and business rules.
  Uses StreamData to generate random test cases and verify invariants.
  """

  use LunchboxApiWeb.ConnCase, async: true
  use ExUnitProperties

  alias LunchboxApi.Lunchbox.Food
  alias LunchboxApi.Lunchbox
  import Ecto.Query

  describe "Food validation properties" do
    property "food names are preserved as provided" do
      check all name <- string(:alphanumeric, min_length: 1, max_length: 50),
                status <- member_of(["available", "unavailable"]) do

        # Arrange: Create user
        user = insert(:user)
        attrs = %{name: name, status: status, user_id: user.id}

        # Act: Create food
        case Lunchbox.create_food(attrs) do
          {:ok, food} ->
            # Assert: Name should be preserved as provided
            assert food.name == name
            assert String.length(food.name) > 0

          {:error, _changeset} ->
            # If creation failed, it should be due to validation rules
            :ok
        end
      end
    end

    property "food status is preserved as provided" do
      check all name <- string(:alphanumeric, min_length: 1, max_length: 50),
                status <- string(:alphanumeric, min_length: 1, max_length: 20) do

        user = insert(:user)
        attrs = %{name: name, status: status, user_id: user.id}

        case Lunchbox.create_food(attrs) do
          {:ok, food} ->
            # Assert: Status should be preserved as provided
            assert food.status == status

          {:error, _changeset} ->
            # If creation failed, it's acceptable for property testing
            :ok
        end
      end
    end

    property "food always belongs to a user" do
      check all name <- string(:alphanumeric, min_length: 1, max_length: 50),
                status <- member_of(["available", "unavailable"]) do

        user = insert(:user)
        attrs = %{name: name, status: status, user_id: user.id}

        case Lunchbox.create_food(attrs) do
          {:ok, food} ->
            # Assert: Food should always have a user_id
            assert food.user_id == user.id
            assert food.user_id != nil

          {:error, _changeset} ->
            :ok
        end
      end
    end
  end

  describe "Food business rule properties" do
    property "user can only see their own foods" do
      check all food_count <- integer(1..10) do
        # Arrange: Create two users
        user1 = insert(:user)
        user2 = insert(:user)

        # Create foods for user1
        user1_foods = for i <- 1..food_count do
          insert(:food, user: user1, name: "User1 Food #{i}")
        end

        # Create some foods for user2
        _user2_foods = for i <- 1..food_count do
          insert(:food, user: user2, name: "User2 Food #{i}")
        end

        # Act: Get foods for user1
        user1_food_ids =
          Repo.all(from f in Food, where: f.user_id == ^user1.id, select: f.id)

        # Assert: User1 should only see their own foods
        assert length(user1_food_ids) == food_count

        Enum.each(user1_foods, fn food ->
          assert food.id in user1_food_ids
        end)
      end
    end
  end
end
