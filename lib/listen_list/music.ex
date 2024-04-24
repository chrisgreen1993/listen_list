defmodule ListenList.Music do
  @moduledoc """
  The Music context.
  """

  import Ecto.Query, warn: false
  alias ListenList.Repo

  alias ListenList.Music.Release

  require Logger

  @doc """
  Returns the list of releases.

  ## Examples

      iex> list_releases()
      [%Release{}, ...]

  """
  def list_releases do
    Repo.all(Release)
  end

  def list_top_releases(period \\ :week) do
    days =
      case period do
        :week -> 7
        :month -> 30
        :year -> 365
      end

    query =
      from r in Release,
        select: [:id, :thumbnail_url, :artist, :album, :score, :post_url, :url, :post_created_at],
        where: r.post_created_at >= ^DateTime.add(DateTime.utc_now(), -days, :day),
        where: r.import_status in [:manual, :auto],
        order_by: [desc: r.score],
        limit: 50

    Repo.all(query)
  end

  @doc """
  Gets a single release.

  Raises `Ecto.NoResultsError` if the Release does not exist.

  ## Examples

      iex> get_release!(123)
      %Release{}

      iex> get_release!(456)
      ** (Ecto.NoResultsError)

  """
  def get_release!(id), do: Repo.get!(Release, id)

  @doc """
  Creates a release.

  ## Examples

      iex> create_release(%{field: value})
      {:ok, %Release{}}

      iex> create_release(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_release(attrs \\ %{}) do
    %Release{}
    |> Release.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a release.

  ## Examples

      iex> update_release(release, %{field: new_value})
      {:ok, %Release{}}

      iex> update_release(release, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_release(%Release{} = release, attrs) do
    release
    |> Release.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a release.

  ## Examples

      iex> delete_release(release)
      {:ok, %Release{}}

      iex> delete_release(release)
      {:error, %Ecto.Changeset{}}

  """
  def delete_release(%Release{} = release) do
    Repo.delete(release)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking release changes.

  ## Examples

      iex> change_release(release)
      %Ecto.Changeset{data: %Release{}}

  """
  def change_release(%Release{} = release, attrs \\ %{}) do
    Release.changeset(release, attrs)
  end

  # Macro to generate the ON CONFLICT clause for the release import
  # The update: parameter doesn't let us to build fragments dynamically,
  # so instead we use a macro do do it.
  # this generates fragments that update all fields except for import_status, artist and album
  # if import_status has a value of 'manual' or 'rejected' we keep the existing value
  defmacro create_or_update_conflict_action() do
    # We do not want to update the id or inserted_at fields
    fields = Release.__schema__(:fields) -- [:id, :inserted_at]

    set_list =
      Enum.map(fields, fn field ->
        case field do
          field when field in [:artist, :album, :import_status] ->
            # for these fields we generate an SQL case statement to check the existing value in import_status
            quote do
              {unquote(field),
               fragment(
                 "CASE WHEN ? IN ('manual', 'rejected') THEN ? ELSE excluded.? END",
                 field(r, :import_status),
                 field(r, ^unquote(field)),
                 literal(^Atom.to_string(unquote(field)))
               )}
            end

          _ ->
            # the rest of the fields we just update with the new value
            quote do
              {unquote(field), fragment("excluded.?", literal(^Atom.to_string(unquote(field))))}
            end
        end
      end)

    quote do
      from(r in Release, update: [set: unquote(set_list)])
    end
  end

  # Create or update releases
  # insert_all only takes maps so we need to validate changesets manually
  def create_or_update_releases(releases) do
    valid_releases =
      Enum.map(releases, fn release ->
        %Release{}
        |> Release.changeset(release)
        |> Ecto.Changeset.apply_action(:insert)
        |> case do
          {:ok, record} ->
            release_to_map_for_insert(record)

          {:error, changeset} ->
            Logger.error(
              "Invalid release: #{inspect(release)}, changeset: #{inspect(changeset.errors)}"
            )

            nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    Repo.insert_all(Release, valid_releases,
      on_conflict: create_or_update_conflict_action(),
      conflict_target: :reddit_id
    )
  end

  # Convert a release to a bare map with timestamps for insert_all
  defp release_to_map_for_insert(%Release{} = release) do
    current_time = DateTime.utc_now()

    release
    |> Release.to_storable_map()
    # Drop id otherwise we'll get not null violations
    |> Map.drop([:id])
    |> Map.merge(%{inserted_at: current_time, updated_at: current_time})
  end
end
