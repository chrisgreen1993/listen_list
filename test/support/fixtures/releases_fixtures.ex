defmodule ListenList.ReleasesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ListenList.Releases` context.
  """

  @doc """
  Generate a release.
  """
  def release_fixture(attrs \\ %{}) do
    {:ok, release} =
      attrs
      |> Enum.into(%{
        artist: "some artist",
        album: "some album",
        url: "some url",
        reddit_id: "some reddit_id",
        score: 1,
        post_url: "some post_url",
        thumbnail_url: "some thumbnail_url",
        post_raw: %{},
        post_created_at: DateTime.from_unix!(0),
        import_status: :auto,
        import_type: :api
      })
      |> ListenList.Releases.create_release()

    release
  end
end
