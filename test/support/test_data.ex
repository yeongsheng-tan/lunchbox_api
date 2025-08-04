defmodule LunchboxApi.TestData do
  @moduledoc """
  Centralized test data builders following the Object Mother pattern.
  Provides clean, focused test data without leaky abstractions.
  """



  @doc """
  Creates a minimal user for testing.
  """
  def user_attrs(overrides \\ %{}) do
    base_attrs = %{
      email: "test@example.com",
      name: "Test User",
      provider: "test",
      provider_id: "test_123"
    }

    Map.merge(base_attrs, overrides)
  end

  @doc """
  Creates a minimal food for testing.
  """
  def food_attrs(overrides \\ %{}) do
    base_attrs = %{
      name: "Test Food",
      status: "available"
    }

    Map.merge(base_attrs, overrides)
  end

  @doc """
  Creates valid food update attributes.
  """
  def food_update_attrs(overrides \\ %{}) do
    base_attrs = %{
      name: "Updated Food",
      status: "unavailable"
    }

    Map.merge(base_attrs, overrides)
  end

  @doc """
  Creates invalid food attributes for testing validation.
  """
  def invalid_food_attrs do
    %{name: nil, status: nil}
  end

  @doc """
  Creates OAuth user info for testing OAuth flows.
  """
  def oauth_user_info(provider \\ "github", overrides \\ %{}) do
    base_info = %{
      id: "oauth_123",
      email: "oauth@example.com",
      name: "OAuth User",
      provider: provider
    }

    Map.merge(base_info, overrides)
  end
end
