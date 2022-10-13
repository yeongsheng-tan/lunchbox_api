defmodule LunchboxApiWeb.Router do
  use LunchboxApiWeb, :router
  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LunchboxApiWeb.LayoutView, :root}
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
    live "/", PageLive, :index
  end

  scope "/api/v1", LunchboxApiWeb do
    pipe_through [:api, :authenticated]
    resources "/foods", FoodController, except: [:new, :edit]
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:browser, :authenticated]
      live_dashboard "/dashboard", metrics: LunchboxApiWeb.Telemetry
    end
  end
end
