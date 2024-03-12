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
        title: "some title",
        type: "some type",
        url: "some url"
      })
      |> ListenList.Music.create_release()

    release
  end
end
