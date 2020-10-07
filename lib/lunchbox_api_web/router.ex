defmodule LunchboxApiWeb.Router do
  use LunchboxApiWeb, :router

  pipeline :browser do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LunchboxApiWeb do
    pipe_through [:browser]
    get "/", FoodController, :index
  end

  scope "/api/v1", LunchboxApiWeb do
    pipe_through [:api]

    resources "/foods", FoodController, except: [:new, :edit]
  end
end
