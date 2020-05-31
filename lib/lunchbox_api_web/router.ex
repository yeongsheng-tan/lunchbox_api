defmodule LunchboxApiWeb.Router do
  use LunchboxApiWeb, :router
  import Plug.BasicAuth

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

  pipeline :authenticated do
    plug :basic_auth,
      username: System.get_env("BASIC_AUTH_USERNAME"),
      password: System.get_env("BASIC_AUTH_PASSWORD")
  end

  scope "/", LunchboxApiWeb do
    pipe_through [:browser, :authenticated]
    get "/", FoodController, :index
  end

  scope "/api/v1", LunchboxApiWeb do
    pipe_through [:api, :authenticated]

    resources "/foods", FoodController, except: [:new, :edit]
  end
end
