defmodule ListenList.MusicFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ListenList.Music` context.
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
        title: "some title",
        url: "some url",
        reddit_id: "some reddit_id",
        score: 1,
        post_url: "some post_url",
        thumbnail_url: "some thumbnail_url",
        post_raw: %{},
        post_created_at: DateTime.from_unix!(0)
      })
      |> ListenList.Music.create_release()

    release
  end
end
