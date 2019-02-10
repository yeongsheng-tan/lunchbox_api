defmodule LunchboxApiWeb.Router do
  use LunchboxApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", LunchboxApiWeb do
    pipe_through :api

    resources "/foods", FoodController, except: [:new, :edit]

    resources "/foods", FoodController, except: [:new, :edit]
  end
end
