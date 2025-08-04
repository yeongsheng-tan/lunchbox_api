defmodule LunchboxApi.Factory do
  @moduledoc """
  Test data factories using ExMachina.
  """
  use ExMachina.Ecto, repo: LunchboxApi.Repo
  
  alias LunchboxApi.Users.User
  alias LunchboxApi.Lunchbox.Food
  
  def user_factory do
    %User{
      email: sequence(:email, &"user-#{&1}@example.com"),
      name: "Test User",
      provider: "test",
      provider_id: sequence(:provider_id, &"provider_#{&1}"),
      inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
  end
  
  def food_factory do
    %Food{
      name: sequence(:name, &"Food Item #{&1}"),
      status: "available",
      user: build(:user)
    }
  end
  
  def oauth_token_factory do
    %{
      access_token: "test_token_#{System.unique_integer([:positive])}",
      token_type: "bearer",
      expires_in: 3600,
      refresh_token: "test_refresh_token_#{System.unique_integer([:positive])}",
      scope: "user:email"
    }
  end
  
  def oauth_user_info_factory do
    %{
      "email" => sequence(:email, &"user-#{&1}@example.com"),
      "name" => "Test User",
      "id" => to_string(System.unique_integer([:positive])),
      "avatar_url" => "https://example.com/avatar.jpg"
    }
  end
end
