defmodule LunchboxApiWeb.Router do
  use LunchboxApiWeb, :router

  alias LunchboxApi.Guardian

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

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  scope "/", LunchboxApiWeb do
    pipe_through :browser
    get "/", FoodController, :index
  end

  scope "/api/v1", LunchboxApiWeb do
    pipe_through :api
    
    post "/sign_up", UserController, :create
    post "/sign_in", UserController, :sign_in
  end

  scope "/api/v1", LunchboxApiWeb do
    pipe_through [:api, :jwt_authenticated]

    get "/me", UserController, :show_current_user
    resources "/users", UserController, except: [:new, :edit]
    delete "/users", UserController, :delete
    put "/users", UserController, :update
    
    resources "/foods", FoodController, except: [:new, :edit]
    delete "/foods", FoodController, :delete
    put "/foods", FoodController, :update
  end
end
