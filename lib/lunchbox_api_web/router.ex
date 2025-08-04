defmodule LunchboxApiWeb.Router do
  use LunchboxApiWeb, :router
  
  # Import authentication plugs
  import Plug.Conn
  alias LunchboxApiWeb.Plugs.Authenticate

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, {LunchboxApiWeb.LayoutView, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authenticated do
    plug LunchboxApiWeb.Plugs.RedirectUnauth
    plug Authenticate
  end
  
  # OAuth routes
  scope "/auth", LunchboxApiWeb do
    pipe_through :api
    
    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/:provider/callback", AuthController, :callback
    
    # Token refresh endpoint
    post "/refresh", AuthController, :refresh
    
    # Logout endpoint
    delete "/logout", AuthController, :delete
  end

  scope "/", LunchboxApiWeb do
    pipe_through([:browser])
    live("/", PageLive, :index)
  end

  scope "/api/v1", LunchboxApiWeb do
    pipe_through([:authenticated, :api])
    resources("/foods", FoodController, except: [:new, :edit])
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through([:authenticated, :browser])
      live_dashboard("/dashboard", metrics: LunchboxApiWeb.Telemetry)
    end
  end
end
