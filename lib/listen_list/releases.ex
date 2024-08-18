defmodule ListenList.Releases do
  @moduledoc """
  The Releases context.
  """

  import Ecto.Query, warn: false
  alias ListenList.Repo

  alias ListenList.Releases.Release
  alias ListenList.Utils.Time
  alias ListenList.Releases.Macros

  require ListenList.Releases.Macros
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

  def list_releases_for_import_status(import_status, limit) do
    query =
      from r in Release,
        select: [:id, :artist, :album, :post_url, :post_raw, :score, :import_status, :import_type],
        where: r.import_status == ^import_status,
        order_by: [desc: r.score],
        limit: ^limit

    Repo.all(query)
  end

  def list_releases_for_period(start_date, end_date, limit, offset \\ 0) do
    query =
      from r in Release,
        select: [:id, :thumbnail_url, :artist, :album, :score, :post_url, :url, :post_created_at],
        where: r.import_status in [:manual, :auto],
        where: r.post_created_at >= ^start_date,
        where: r.post_created_at < ^end_date,
        # Use id so we have consistent ordering for the same scores
        order_by: [desc: r.score, asc: r.id],
        limit: ^limit,
        offset: ^offset

    Repo.all(query)
  end

  def list_top_releases_for_weekly_email() do
    DateTime.utc_now()
    |> Time.end_of_release_period(:week)
    |> list_top_releases_grouped_by_period(:week,
      max_per_period: 4,
      max_periods: 1
    )
    |> Enum.at(0)
  end

  # Group releases by period (week, month, year) and return the top releases within that period
  # as well as a start and end date.
  def list_top_releases_grouped_by_period(start_date, period, opts) do
    defaults = [min_per_period: 4]

    [min_per_period: min_per_period, max_per_period: max_per_period, max_periods: max_periods] =
      Keyword.merge(defaults, opts)

    if min_per_period > max_per_period do
      raise ArgumentError, "min_per_period must not be greater than max_per_period"
    end

    Time.past_intervals_for_period(start_date, period, max_periods)
    |> Enum.map(fn %{start_date: start_date, end_date: end_date} ->
      releases = list_releases_for_period(start_date, end_date, max_per_period)

      %{
        period_type: period,
        period_start: DateTime.to_date(start_date),
        period_end: DateTime.to_date(end_date),
        releases: releases
      }
    end)
    |> Enum.filter(fn %{releases: releases} ->
      # only return periods with enough releases
      length(releases) >= min_per_period
    end)
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
      on_conflict: Macros.create_or_update_conflict_action(),
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
