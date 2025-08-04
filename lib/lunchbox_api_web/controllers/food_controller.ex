defmodule LunchboxApiWeb.FoodController do
  @moduledoc """
  Controller for managing food resources.
  
  Provides CRUD operations for foods with user-based authorization.
  All operations require authentication and users can only access their own foods.
  
  ## Authentication
  
  All endpoints require a valid JWT token in the Authorization header:
  ```
  Authorization: Bearer <jwt_token>
  ```
  
  ## Endpoints
  
  - `GET /api/v1/foods` - List user's foods
  - `GET /api/v1/foods/:id` - Get specific food
  - `POST /api/v1/foods` - Create new food
  - `PATCH /api/v1/foods/:id` - Update food
  - `DELETE /api/v1/foods/:id` - Delete food
  
  ## Response Format
  
  All responses follow the JSON API format:
  ```json
  {
    "data": {
      "id": 123,
      "name": "Pizza",
      "status": "available",
      "inserted_at": "2023-01-01T00:00:00",
      "updated_at": "2023-01-01T00:00:00"
    }
  }
  ```
  """
  
  use LunchboxApiWeb, :controller

  alias LunchboxApi.Lunchbox
  alias LunchboxApi.Lunchbox.Food
  alias LunchboxApi.Repo
  import Ecto.Query

  action_fallback LunchboxApiWeb.FallbackController

  @doc """
  Lists all foods for the authenticated user.
  
  ## Parameters
  - `conn` - Phoenix connection with authenticated user
  - `_params` - Request parameters (unused)
  
  ## Returns
  - `200` - JSON list of user's foods
  - `401` - If user is not authenticated
  
  ## Example Response
  ```json
  {
    "data": [
      {
        "id": 1,
        "name": "Pizza",
        "status": "available",
        "inserted_at": "2023-01-01T00:00:00",
        "updated_at": "2023-01-01T00:00:00"
      }
    ]
  }
  ```
  """
  def index(conn, _params) do
    current_user = conn.assigns.current_user
    foods = Repo.all(from f in Food, where: f.user_id == ^current_user.id)
    json(conn, %{"data" => Enum.map(foods, &food_response/1)})
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
    current_user = conn.assigns.current_user
    with {:ok, food} <- fetch_food(current_user, id) do
      json(conn, %{"data" => food_response(food)})
    else
      _ -> send_resp(conn, :not_found, "")
    end
  end

  def update(conn, %{"id" => id, "food" => food_params}) do
    current_user = conn.assigns.current_user
    with {:ok, food} <- fetch_food(current_user, id) do
      case Lunchbox.update_food(food, food_params) do
        {:ok, %Food{} = updated} -> json(conn, %{"data" => food_response(updated)})
        {:error, changeset} -> 
          errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
          conn |> put_status(:unprocessable_entity) |> json(%{"errors" => errors})
      end
    else
      _ -> send_resp(conn, :not_found, "")
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    with {:ok, food} <- fetch_food(current_user, id),
         {:ok, %Food{}} <- Lunchbox.delete_food(food) do
      send_resp(conn, :no_content, "")
    else
      _ -> send_resp(conn, :not_found, "")
    end
  end

  # Helper to fetch food belonging to user, handling cast errors
  defp fetch_food(user, id) do
    try do
      case Repo.get_by(Food, id: id, user_id: user.id) do
        nil -> {:error, :not_found}
        food -> {:ok, food}
      end
    rescue
      Ecto.Query.CastError -> {:error, :not_found}
    end
  end

  defp food_response(%Food{} = food) do
    %{
      "id" => food.id,
      "name" => food.name,
      "status" => food.status,
      "inserted_at" => to_iso(food.inserted_at),
      "updated_at" => to_iso(food.updated_at)
    }
  end

  defp to_iso(%NaiveDateTime{} = ndt) do
    NaiveDateTime.to_iso8601(ndt)
  end
end
