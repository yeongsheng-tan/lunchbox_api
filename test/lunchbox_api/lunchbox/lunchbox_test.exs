defmodule LunchboxApi.LunchboxTest do
  use LunchboxApi.DataCase

  alias LunchboxApi.Lunchbox

  describe "foods" do
    alias LunchboxApi.Lunchbox.Food

    @valid_attrs %{name: "some name", status: "some status"}
    @update_attrs %{name: "some updated name", status: "some updated status"}
    @invalid_attrs %{name: nil, status: nil}

    def food_fixture(attrs \\ %{}) do
      {:ok, food} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Lunchbox.create_food()

      food
    end

    test "list_foods/0 returns all foods" do
      food = food_fixture()
      assert Lunchbox.list_foods() == [food]
    end

    test "get_food!/1 returns the food with given id" do
      food = food_fixture()
      assert Lunchbox.get_food!(food.id) == food
    end

    test "create_food/1 with valid data creates a food" do
      assert {:ok, %Food{} = food} = Lunchbox.create_food(@valid_attrs)
      assert food.name == "some name"
      assert food.status == "some status"
    end

    test "create_food/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lunchbox.create_food(@invalid_attrs)
    end

    test "update_food/2 with valid data updates the food" do
      food = food_fixture()
      assert {:ok, %Food{} = food} = Lunchbox.update_food(food, @update_attrs)
      assert food.name == "some updated name"
      assert food.status == "some updated status"
    end

    test "update_food/2 with invalid data returns error changeset" do
      food = food_fixture()
      assert {:error, %Ecto.Changeset{}} = Lunchbox.update_food(food, @invalid_attrs)
      assert food == Lunchbox.get_food!(food.id)
    end

    test "delete_food/1 deletes the food" do
      food = food_fixture()
      assert {:ok, %Food{}} = Lunchbox.delete_food(food)
      assert_raise Ecto.NoResultsError, fn -> Lunchbox.get_food!(food.id) end
    end

    test "change_food/1 returns a food changeset" do
      food = food_fixture()
      assert %Ecto.Changeset{} = Lunchbox.change_food(food)
    end
  end
end
