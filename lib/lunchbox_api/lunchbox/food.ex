defmodule LunchboxApi.Lunchbox.Food do
  use Ecto.Schema
  import Ecto.Changeset

  schema "foods" do
    field :name, :string
    field :status, :string

    belongs_to :user, LunchboxApi.Users.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [:name, :status, :user_id])
    |> validate_required([:name, :status, :user_id])
  end
end
