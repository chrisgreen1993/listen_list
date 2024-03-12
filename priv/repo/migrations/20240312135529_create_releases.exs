defmodule ListenList.Repo.Migrations.CreateReleases do
  use Ecto.Migration

  def change do
    create table(:releases) do
      add :title, :string
      add :type, :string
      add :url, :string

      timestamps(type: :utc_datetime)
    end
  end
end
