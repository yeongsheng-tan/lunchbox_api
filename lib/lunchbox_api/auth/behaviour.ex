defmodule LunchboxApi.Auth.Behaviour do
  @moduledoc """
  Behaviour for authentication context.
  """
  
  @type token :: String.t()
  @type user :: map()
  @type error :: {:error, String.t()}
  
  @callback authenticate(String.t(), String.t(), String.t()) :: {:ok, user()} | error()
  @callback generate_token(map()) :: {:ok, token()} | error()
  @callback verify_token(token()) :: {:ok, map()} | error()
end
