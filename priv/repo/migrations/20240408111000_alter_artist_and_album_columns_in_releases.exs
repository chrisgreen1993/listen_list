defmodule ListenList.Repo.Migrations.AlterArtistAndAlbumColumnsInReleases do
  use Ecto.Migration

  def change do
    alter table(:releases) do
      modify :artist, :string, null: false
      modify :album, :string, null: false
    end
  end
end
