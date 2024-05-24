defmodule YourApp.Repo.Migrations.RemoveTokenAndTokenCreatedAtFromSubscribers do
  use Ecto.Migration

  def change do
    alter table(:subscribers) do
      remove :token
      remove :token_created_at
    end
  end
end
