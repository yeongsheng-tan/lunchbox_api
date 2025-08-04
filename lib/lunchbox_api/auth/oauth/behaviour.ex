defmodule LunchboxApi.Auth.OAuth.Behaviour do
  @moduledoc """
  Behaviour for OAuth operations.
  """
  
  @type client :: map()
  @type token :: map()
  @type user_info :: map()
  @type error :: {:error, String.t()}
  
  @callback client(String.t(), String.t()) :: {:ok, client()} | error()
  @callback get_token(client(), keyword()) :: {:ok, client()} | error()
  @callback get_user_info(String.t(), token()) :: {:ok, user_info()} | error()
end
