defmodule ListenList.Repo.Migrations.RemoveTitleColumnFromReleases do
  use Ecto.Migration

  def change do
    alter table(:releases) do
      remove :title
    end
  end
end
