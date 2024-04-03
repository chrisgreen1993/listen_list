defmodule ListenList.Music.Release do
  use Ecto.Schema
  import Ecto.Changeset

  schema "releases" do
    field :title, :string
    field :url, :string
    field :reddit_id, :string
    field :score, :integer
    field :post_url, :string
    field :post_raw, :map
    field :post_created_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(release, attrs) do
    release
    |> cast(attrs, [:title, :url, :reddit_id, :score, :post_url, :post_raw, :post_created_at])
    |> validate_required([
      :title,
      :url,
      :reddit_id,
      :score,
      :post_url,
      :post_raw,
      :post_created_at
    ])
    |> unique_constraint(:reddit_id)
  end

  def to_storable_map(release) do
    Map.take(release, __schema__(:fields))
  end
end
