defmodule ListenList.Music.Release do
  use Ecto.Schema
  import Ecto.Changeset

  schema "releases" do
    field :type, :string
    field :title, :string
    field :url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(release, attrs) do
    release
    |> cast(attrs, [:title, :type, :url])
    |> validate_required([:title, :type, :url])
  end
end
