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
    plug :fetch_session
  end

  pipeline :api_auth do
    plug :ensure_authenticated
  end

  scope "/", LunchboxApiWeb do
    pipe_through :browser
    get "/", FoodController, :index
  end

  scope "/api/v1", LunchboxApiWeb do
    pipe_through :api
    post      "/users/sign_in", UserController, :sign_in
  end
  
  scope "/api/v1", LunchboxApiWeb do
    pipe_through [:api, :api_auth]

    resources "/users",         UserController, except: [:new, :edit]
    resources "/foods",         FoodController, except: [:new, :edit]
    resources "/foods",         FoodController, except: [:new, :edit]
  end

  defp ensure_authenticated(conn, _opts) do
    current_user_id = get_session(conn, :current_user_id)

    if current_user_id do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(LunchboxApiWeb.ErrorView)
      |> render("401.json", message: "Unauthenticated user!")
      |> halt()
    end
  end
end
