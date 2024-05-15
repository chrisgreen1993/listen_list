defmodule ListenList.Repo.Migrations.AddEmbedColumnToReleases do
  use Ecto.Migration

  def change do
    alter table(:releases) do
      add :embed, :map
    end
  end
end
