defmodule LunchboxApi.Repo.Migrations.CreateFoods do
  use Ecto.Migration

  def change do
    create table(:foods) do
      add :name, :string
      add :status, :string

      timestamps()
    end
  end
end
