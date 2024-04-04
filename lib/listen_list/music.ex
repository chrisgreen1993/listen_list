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
        select: [:id, :title, :score, :post_url, :url],
        where: r.post_created_at >= ^DateTime.add(DateTime.utc_now(), -days, :day),
        order_by: [desc: r.score],
        limit: 20

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
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
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
