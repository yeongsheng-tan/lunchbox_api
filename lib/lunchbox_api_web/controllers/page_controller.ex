defmodule LunchboxApiWeb.PageController do
  use LunchboxApiWeb, :controller

  def favicon(conn, _params) do
    send_resp(conn, 204, "")
  end
end
