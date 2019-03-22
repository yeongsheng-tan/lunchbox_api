defmodule LunchboxApiWeb.FoodController do
  use LunchboxApiWeb, :controller

  alias LunchboxApi.Lunchbox
  alias LunchboxApi.Lunchbox.Food

  # plug BasicAuth, use_config: {:lunchbox_api, :lunchbox_auth}
  action_fallback LunchboxApiWeb.FallbackController

  def index(conn, _params) do
    foods = Lunchbox.list_foods()
    render(conn, "index.json", foods: foods)
  end

  def create(conn, %{"food" => food_params}) do
    with {:ok, %Food{} = food} <- Lunchbox.create_food(food_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.food_path(conn, :show, food))
      |> render("show.json", food: food)
    end
  end

  def show(conn, %{"id" => id}) do
    food = Lunchbox.get_food!(id)
    render(conn, "show.json", food: food)
  end

  def update(conn, %{"id" => id, "food" => food_params}) do
    food = Lunchbox.get_food!(id)

    with {:ok, %Food{} = food} <- Lunchbox.update_food(food, food_params) do
      render(conn, "show.json", food: food)
    end
  end

  def delete(conn, %{"id" => id}) do
    food = Lunchbox.get_food!(id)

    with {:ok, %Food{}} <- Lunchbox.delete_food(food) do
      send_resp(conn, :no_content, "")
    end
  end
end
