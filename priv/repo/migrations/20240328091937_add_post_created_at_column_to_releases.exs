defmodule ListenList.Repo.Migrations.AddPostCreatedAtColumnToReleases do
  use Ecto.Migration

  def change do
    alter table(:releases) do
      add :post_created_at, :timestamptz
    end
  end
end
