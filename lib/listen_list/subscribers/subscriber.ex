defmodule ListenList.Subscribers.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscribers" do
    field :name, :string
    field :email, :string
    field :confirmed_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:name, :email, :confirmed_at])
    |> validate_required([:name, :email])
    |> unique_constraint(:email)
  end

  def confirm_changeset(subscriber) do
    change(subscriber, confirmed_at: DateTime.utc_now())
  end
end
