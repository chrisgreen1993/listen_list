defmodule ListenList.Admin do
  alias ListenList.Releases

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
end
