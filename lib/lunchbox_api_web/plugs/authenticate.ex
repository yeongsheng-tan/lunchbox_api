defmodule LunchboxApiWeb.Plugs.Authenticate do
  @moduledoc """
  Plug to authenticate requests using JWT tokens.
  """
  import Plug.Conn
  
  def init(opts), do: opts

  def call(conn, _opts) do
    case get_token(conn) do
      {:ok, token} ->
        case LunchboxApi.Auth.verify_token(token) do
          {:ok, user} ->
            conn
            |> assign(:current_user, user)
            
          {:error, reason} ->
            conn
            |> put_status(:unauthorized)
            |> Phoenix.Controller.json(%{error: "Invalid token: #{reason}"})
            |> halt()
        end
        
      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.json(%{error: reason})
        |> halt()
    end
  end
  
  defp get_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> {:ok, token}
      _ -> {:error, "Missing or invalid authorization header"}
    end
  end
end
