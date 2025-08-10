defmodule LunchboxApiWeb.TimeController do
  use LunchboxApiWeb, :controller

  def time_now(conn, _params) do
    # Get current UTC time and add Singapore offset (+08:00)
    utc_time = DateTime.utc_now()
    singapore_offset = 8 * 60 * 60  # 8 hours in seconds
    singapore_time = DateTime.add(utc_time, singapore_offset, :second)

    # Format as ISO8601 with Singapore timezone
    time_string = DateTime.to_iso8601(singapore_time) |> String.replace("Z", "+08:00")

    json(conn, %{time: time_string})
  end
end
