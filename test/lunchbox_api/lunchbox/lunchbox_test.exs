defmodule LunchboxApi.LunchboxTest do
  use LunchboxApi.DataCase

  alias LunchboxApi.Lunchbox

  describe "foods" do
    setup do
      user = LunchboxApi.Factory.insert(:user)
      {:ok, user: user}
    end
    alias LunchboxApi.Lunchbox.Food

    @valid_attrs %{name: "some name", status: "some status"}
    @update_attrs %{name: "some updated name", status: "some updated status"}
    @invalid_attrs %{name: nil, status: nil}

    defp food_fixture(user, attrs \\ %{}) do
      attrs = attrs |> Enum.into(@valid_attrs) |> Map.put(:user_id, user.id)
      {:ok, food} = Lunchbox.create_food(attrs)
      food
    end

    test "list_foods/0 returns all foods", %{user: user} do
      food = food_fixture(user)
      assert Lunchbox.list_foods() == [food]
    end

    test "get_food!/1 returns the food with given id", %{user: user} do
      food = food_fixture(user)
      assert Lunchbox.get_food!(food.id) == food
    end

    test "create_food/1 with valid data creates a food", %{user: user} do
      attrs = Map.put(@valid_attrs, :user_id, user.id)
      assert {:ok, %Food{} = food} = Lunchbox.create_food(attrs)
      assert food.name == "some name"
      assert food.status == "some status"
    end

    test "create_food/1 with invalid data returns error changeset", %{user: user} do
      invalid = Map.put(@invalid_attrs, :user_id, user.id)
      assert {:error, %Ecto.Changeset{}} = Lunchbox.create_food(invalid)
    end

    test "update_food/2 with valid data updates the food", %{user: user} do
      food = food_fixture(user)
      assert {:ok, %Food{} = food} = Lunchbox.update_food(food, @update_attrs)
      assert food.name == "some updated name"
      assert food.status == "some updated status"
    end

    test "update_food/2 with invalid data returns error changeset", %{user: user} do
      food = food_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Lunchbox.update_food(food, @invalid_attrs)
      assert food == Lunchbox.get_food!(food.id)
    end

    test "delete_food/1 deletes the food", %{user: user} do
      food = food_fixture(user)
      assert {:ok, %Food{}} = Lunchbox.delete_food(food)
      assert_raise Ecto.NoResultsError, fn -> Lunchbox.get_food!(food.id) end
    end

    test "change_food/1 returns a food changeset", %{user: user} do
      food = food_fixture(user)
      assert %Ecto.Changeset{} = Lunchbox.change_food(food)
    end
  end
end
