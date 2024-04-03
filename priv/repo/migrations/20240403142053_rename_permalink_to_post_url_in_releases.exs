defmodule ListenList.Repo.Migrations.RenamePermalinkToPostUrlInReleases do
  use Ecto.Migration

  def change do
    rename table(:releases), :permalink, to: :post_url
  end
end
