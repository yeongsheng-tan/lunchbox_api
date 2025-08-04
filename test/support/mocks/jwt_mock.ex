defmodule LunchboxApi.Auth.JWT.Mock do
  @moduledoc """
  Mock implementation of the JWT module for testing.
  """
  @behaviour LunchboxApi.Auth.JWT.Behaviour

  @impl true
  def generate_token(%{id: id}) when is_binary(id) do
    {:ok, "test_token_#{id}"}
  end

  def generate_token(%{access_token: _}) do
    # Handle case when we get an OAuth token map instead of a user
    {:ok, "test_token_#{System.unique_integer([:positive])}"}
  end

  @impl true
  def verify_token(token) do
    case String.split(token, "_", parts: 3) do
      ["test", "token", user_id] ->
        {:ok, %{"sub" => user_id}}
      _ ->
        {:error, "Invalid token"}
    end
  end
end
