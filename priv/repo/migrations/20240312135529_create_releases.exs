defmodule ListenList.Repo.Migrations.CreateReleases do
  use Ecto.Migration

  def change do
    create table(:releases) do
      add :title, :string
      add :url, :string
      add :reddit_id, :string, null: false
      add :score, :integer
      add :permalink, :string
      add :post_raw, :map

      timestamps(type: :timestamptz)
    end

    create unique_index(:releases, [:reddit_id])
  end
end
