defmodule LunchboxApi.Lunchbox.Food do
  use Ecto.Schema
  import Ecto.Changeset

  schema "foods" do
    field :name, :string
    field :status, :string

    timestamps()
  end

  @doc false
  def changeset(food, attrs) do
    food
    |> cast(attrs, [:name, :status])
    |> validate_required([:name, :status])
  end
end
