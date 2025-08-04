defmodule LunchboxApi.Users do
  @moduledoc """
  The Users context for handling user data and authentication.
  """
  
  @behaviour LunchboxApi.Users.Behaviour
  
  alias LunchboxApi.Users.User
  alias LunchboxApi.Repo
  
  @doc """
  Gets a single user by ID.
  Handles both binary and string IDs.
  """
  @impl true
  def get_user(id) when is_binary(id) do
    case Ecto.UUID.cast(id) do
      {:ok, uuid} -> get_user(uuid)
      :error -> {:error, :not_found}
    end
  end
  
  def get_user(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
  
  @doc """
  Gets a single user by email.
  """
  @impl true
  def get_user_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end
  
  @doc """
  Creates a new user.
  """
  @impl true
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
  
  @doc """
  Finds an existing user by provider and user info or creates a new one.
  """
  @impl true
  def find_or_create_user(provider, user_info) do
    email = Map.get(user_info, :email) || Map.get(user_info, "email")
    
    case get_user_by_email(email) do
      {:ok, user} -> 
        {:ok, user}
        
      {:error, :not_found} ->
        attrs = %{
          email: email,
          name: Map.get(user_info, :name) || Map.get(user_info, "name", ""),
          provider: provider,
          provider_id: Map.get(user_info, :id) || Map.get(user_info, "sub") || ""
        }
        
        create_user(attrs)
        
      error -> 
        error
    end
  end
end
