defmodule ListenList.Repo.Migrations.AddArtistAndAlbumColumnsToReleases do
  use Ecto.Migration

  def change do
    alter table(:releases) do
      add :artist, :string
      add :album, :string
    end
  end
end
