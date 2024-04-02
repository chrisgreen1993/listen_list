defmodule ListenList.Repo.Migrations.AlterPostCreatedAtColumnInReleases do
  use Ecto.Migration

  def change do
    alter table(:releases) do
      modify :post_created_at, :timestamptz, null: false
    end
  end
end
