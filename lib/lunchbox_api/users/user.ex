defmodule LunchboxApi.Users.User do
  @moduledoc """
  User schema and changesets.
  """
  
  use Ecto.Schema
  import Ecto.Changeset
  
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  
  schema "users" do
    field :email, :string
    field :name, :string
    field :provider, :string
    field :provider_id, :string
    
    timestamps()
  end
  
  @doc """
  Creates a changeset for a user.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :name, :provider, :provider_id])
    |> validate_required([:email, :provider])
    |> unique_constraint(:email)
    |> unique_constraint(:provider_id, name: :users_provider_provider_id_index)
  end
end
