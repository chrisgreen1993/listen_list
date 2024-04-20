defmodule ListenList.Repo.Migrations.AddImportColumnsToReleases do
  use Ecto.Migration

  def change do
    execute(
      "CREATE TYPE import_status AS ENUM ('auto', 'in_review', 'manual', 'rejected')",
      "DROP TYPE import_status"
    )

    execute(
      "CREATE TYPE import_type AS ENUM ('api', 'file')",
      "DROP TYPE import_type"
    )

    alter table(:releases) do
      add :import_status, :string
      add :import_type, :string
      modify :artist, :text, null: true
      modify :album, :text, null: true
    end
  end
end
