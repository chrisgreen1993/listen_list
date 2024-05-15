defmodule ListenList.Music.Release do
  use Ecto.Schema
  import Ecto.Changeset

  schema "releases" do
    field :artist, :string
    field :album, :string
    field :url, :string
    field :reddit_id, :string
    field :score, :integer
    field :post_url, :string
    field :thumbnail_url, :string
    field :post_raw, :map
    field :post_created_at, :utc_datetime_usec
    field :import_status, Ecto.Enum, values: [:auto, :in_review, :manual, :rejected]
    field :import_type, Ecto.Enum, values: [:api, :file]
    field :embed, :map

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(release, attrs) do
    release
    |> cast(attrs, [
      :artist,
      :album,
      :url,
      :reddit_id,
      :score,
      :post_url,
      :thumbnail_url,
      :post_raw,
      :post_created_at,
      :import_status,
      :import_type,
      :embed
    ])
    |> validate_required([
      :url,
      :reddit_id,
      :score,
      :post_url,
      :post_raw,
      :post_created_at,
      :import_status,
      :import_type
    ])
    |> validate_inclusion(:import_status, Ecto.Enum.values(__MODULE__, :import_status))
    |> validate_inclusion(:import_type, Ecto.Enum.values(__MODULE__, :import_type))
    |> unique_constraint(:reddit_id)
  end

  def to_storable_map(release) do
    Map.take(release, __schema__(:fields))
  end
end
