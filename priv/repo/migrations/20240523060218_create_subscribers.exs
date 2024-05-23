defmodule ListenList.Repo.Migrations.CreateSubscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :name, :text, null: false
      add :email, :text, null: false
      add :token_created_at, :timestamptz
      add :token, :text
      add :confirmed_at, :timestamptz

      timestamps(type: :timestamptz)
    end

    create unique_index(:subscribers, [:email])
    create unique_index(:subscribers, [:token])
  end
end
