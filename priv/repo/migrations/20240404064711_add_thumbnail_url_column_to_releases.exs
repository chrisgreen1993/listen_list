defmodule ListenList.Repo.Migrations.AddThumbnailUrlColumnToReleases do
  use Ecto.Migration

  def change do
    alter table(:releases) do
      add :thumbnail_url, :string
    end
  end
end
