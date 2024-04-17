defmodule ListenList.Repo.Migrations.AlterFieldsToUseTextInReleases do
  use Ecto.Migration

  def change do
    alter table(:releases) do
      modify :artist, :text
      modify :album, :text
      modify :url, :text
      modify :post_url, :text
      modify :thumbnail_url, :text
    end
  end
end
