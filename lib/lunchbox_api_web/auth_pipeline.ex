defmodule LunchboxApi.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline, otp_app: :lunchbox_api,
                              module: LunchboxApi.Guardian,
                              error_handler: LunchboxApi.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
