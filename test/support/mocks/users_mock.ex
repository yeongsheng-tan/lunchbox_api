defmodule LunchboxApi.Users.Mock do
  @moduledoc """
  Mock for the Users context.
  """
  @behaviour LunchboxApi.Users.Behaviour
  
  @test_email "test@example.com"
  @test_name "Test User"
  @test_provider "test"
  
  @impl true
  def get_user(id) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, _} -> 
        # For testing, we'll return a user for any valid UUID
        {:ok, create_test_user(id)}
      :error -> 
        {:error, :not_found}
    end
  end
  
  @impl true
  def get_user(_id), do: {:error, :not_found}
  
  @impl true
  def get_user_by_email(email) when is_binary(email) do
    # For testing, we'll return a user for any email
    {:ok, create_test_user(Ecto.UUID.generate(), %{email: email})}
  end
  
  @impl true
  def create_user(attrs) do
    # Generate a new ID for the user
    id = Ecto.UUID.generate()
    {:ok, create_test_user(id, attrs)}
  end
  
  @impl true
  def find_or_create_user(provider, user_info) do
    # For testing, we'll always create a new user with the provided info
    create_user(Map.merge(%{
      email: @test_email,
      name: @test_name,
      provider: provider
    }, user_info))
  end
  
  # Helper function to create a test user map
  defp create_test_user(id, attrs \\ %{}) do
    # Convert string ID to binary if needed
    binary_id = 
      case Ecto.UUID.cast(id) do
        {:ok, uuid} -> uuid
        _ -> id
      end
    
    # Merge with default attributes
    Map.merge(%{
      id: binary_id,
      email: @test_email,
      name: @test_name,
      provider: @test_provider,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }, attrs)
  end
end
