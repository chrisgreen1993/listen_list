defmodule ListenList.Admin do
  alias ListenList.Reddit.Post
  alias ListenList.Releases
  alias ListenList.Repo

  require Logger

  def list_releases_in_review(limit \\ 10, fields \\ []),
    do: list_releases_for_import_status(:in_review, limit, fields)

  def list_releases_for_import_status(import_status, limit \\ 10, fields \\ []) do
    releases =
      Releases.list_releases_for_import_status(import_status, limit)
      |> Enum.map(&fields_to_print(&1, fields))

    Scribe.print(releases, width: 200)
  end

  defp fields_to_print(release, fields) do
    %{
      id: release.id,
      album: release.album,
      artist: release.artist,
      score: release.score,
      post_url: release.post_url,
      import_status: release.import_status,
      raw_title: release.post_raw["title"]
    }
    |> take_keys(fields)
  end

  defp take_keys(release, []), do: release
  defp take_keys(release, keys), do: Map.take(release, keys)

  def reject_release(release_id) do
    release = Releases.get_release!(release_id)
    Releases.update_release(release, %{import_status: :rejected})
    nil
  end

  def update_release_album_arist_manual(release_id, artist, album) do
    release = Releases.get_release!(release_id)
    Releases.update_release(release, %{album: album, artist: artist, import_status: :manual})
    nil
  end

  def update_releases_for_import_status_from_post(import_status, limit \\ 10, chunk_size \\ 200) do
    releases_in_review = Releases.list_releases_for_import_status(import_status, limit)

    Logger.info("Updating #{length(releases_in_review)} releases in review")

    releases =
      Enum.map(releases_in_review, &Post.post_to_release(&1.post_raw, &1.import_type))

    Repo.transaction(fn ->
      Enum.chunk_every(releases, chunk_size)
      |> Enum.each(fn releases_chunk ->
        Logger.info(
          "Attempting to insert #{length(releases_chunk)} releases. Starting ID: #{List.first(releases_chunk)[:reddit_id]}"
        )

        {changed_rows, _} = Releases.create_or_update_releases(releases_chunk)
        Logger.info("Inserted #{changed_rows} releases")
      end)
    end)
  end

  def update_release_from_post(id) do
    release = Releases.get_release!(id)
    updated_release = Post.post_to_release(release.post_raw, release.import_type)
    Releases.create_or_update_releases([updated_release])
  end
end
