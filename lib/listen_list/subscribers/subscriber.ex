defmodule ListenList.Subscribers.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscribers" do
    field :name, :string
    field :token, :string
    field :email, :string
    field :token_created_at, :utc_datetime_usec
    field :confirmed_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:name, :email, :token_created_at, :token, :confirmed_at])
    |> validate_required([:name, :email, :token_created_at, :token, :confirmed_at])
  end
end
