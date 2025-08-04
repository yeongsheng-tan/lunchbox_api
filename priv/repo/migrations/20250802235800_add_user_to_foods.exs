defmodule LunchboxApi.Repo.Migrations.AddUserToFoods do
  use Ecto.Migration

  def change do
    alter table(:foods) do
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)
    end

    create index(:foods, [:user_id])
  end
end
