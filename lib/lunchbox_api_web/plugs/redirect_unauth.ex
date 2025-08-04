defmodule LunchboxApiWeb.Plugs.RedirectUnauth do
  @moduledoc """
  A Plug that redirects unauthenticated browser requests to the GitHub OAuth login page.

  This plug is designed to intercept unauthenticated web browser requests to API endpoints
  and redirect them to the GitHub OAuth login flow. It's particularly useful for providing
  a better user experience when users directly access API endpoints from their browser.

  ## How it works

  1. Checks if the request is from a web browser (accepts HTML)
  2. Verifies if the user is not authenticated
  3. If both conditions are met and the path starts with "/api" or "/api/v1/",
     it redirects to the GitHub OAuth login page
  4. API clients (sending JSON/XML) and authenticated users are not redirected

  ## Usage

  Add this plug to your router's browser pipeline:

      pipeline :browser do
        # ... other plugs
        plug LunchboxApiWeb.Plugs.RedirectUnauth
      end
  """
  import Plug.Conn
  import Phoenix.Controller, only: [redirect: 2]

  @behaviour Plug

  @doc """
  Initializes the plug with the given options.

  ## Options

    * `:redirect_to` - The path to redirect to (defaults to "/auth/github")
  """
  @impl true
  def init(opts), do: opts

  @doc """
  Performs the redirection check and redirects if necessary.

  This function is called for each request and will:
  1. Check if the request should be redirected using `should_redirect?/1`
  2. If redirection is needed, it will:
     - Set the HTTP status to 302 (Found)
     - Set the Location header to the GitHub OAuth URL
     - Halt the connection to prevent further processing
  3. If no redirection is needed, it returns the connection unchanged
  """
  @impl true
  def call(conn, _opts) do
    if should_redirect?(conn) do
      conn
      |> put_status(:found)
      |> redirect(to: "/auth/github")
      |> halt()
    else
      conn
    end
  end

  @spec should_redirect?(Plug.Conn.t()) :: boolean()
  defp should_redirect?(conn) do
    path = String.downcase(conn.request_path)
    is_browser_request?(conn) && !authenticated?(conn) && 
      (String.starts_with?(path, "/api") || String.starts_with?(path, "/api/v1/"))
  end

  @doc false
  @spec is_browser_request?(Plug.Conn.t()) :: boolean()
  defp is_browser_request?(conn) do
    case get_req_header(conn, "accept") do
      [accept_header | _] -> String.contains?(accept_header, "text/html")
      _ -> false
    end
  end

  @doc false
  @spec authenticated?(Plug.Conn.t()) :: boolean()
  defp authenticated?(conn) do
    # Check if the user is authenticated by either:
    # 1. Having a current_user assigned to the connection
    # 2. Having an Authorization header present (case-insensitive check)
    has_current_user = !!conn.assigns[:current_user]
    
    has_auth_header = Enum.any?(conn.req_headers, fn {key, _value} -> 
      String.downcase(key) == "authorization" 
    end)
    
    has_current_user || has_auth_header
  end
end
