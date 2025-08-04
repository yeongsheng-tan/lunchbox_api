defmodule LunchboxApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :email, :string, null: false
      add :name, :string
      add :provider, :string, null: false
      add :provider_id, :string
      
      timestamps()
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:provider, :provider_id], name: :users_provider_provider_id_index)
  end
end
