defmodule LunchboxApi.Auth.JWT.Behaviour do
  @moduledoc """
  Behaviour for JWT token generation and verification.
  """

  @type user :: map()
  @type token :: String.t()
  @type claims :: map()
  @type error_reason :: String.t()

  @doc """
  Generates a JWT token for the given user.
  """
  @callback generate_token(user) :: {:ok, token} | {:error, error_reason}

  @doc """
  Verifies a JWT token and returns the claims.
  """
  @callback verify_token(token) :: {:ok, claims} | {:error, error_reason}
end
