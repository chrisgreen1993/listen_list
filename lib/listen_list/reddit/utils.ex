defmodule ListenList.Reddit.Utils do
  @new_release_identifier "[FRESH ALBUM]"

  # Not a great way to decide, but it's all we've got
  @artist_album_delimiter " - "

  def new_release_identifier, do: @new_release_identifier

  defp release_field_mappers do
    %{
      "id" => &%{reddit_id: &1},
      "title" => &title_to_artist_and_album/1,
      "url" => &%{url: &1},
      "score" => &%{score: &1},
      "permalink" => &%{post_url: "https://reddit.com" <> &1},
      "created_utc" => &%{post_created_at: DateTime.from_unix!(trunc(&1))},
      "thumbnail" => &%{thumbnail_url: if(&1 == "default", do: nil, else: &1)}
    }
  end

  def valid_post_title?(title) do
    title
    |> String.trim()
    |> String.starts_with?(@new_release_identifier) &&
      String.contains?(title, @artist_album_delimiter)
  end

  defp title_to_artist_and_album(title) do
    [artist, album] =
      title
      |> String.replace(@new_release_identifier, "")
      |> String.trim()
      |> HtmlEntities.decode()
      |> String.split(@artist_album_delimiter, parts: 2)

    %{artist: artist, album: album}
  end

  def post_to_release(%{"data" => post_data} = post) do
    Enum.reduce(release_field_mappers(), %{}, fn {k, function}, acc ->
      if value = Map.get(post_data, k) do
        Map.merge(acc, function.(value))
      else
        acc
      end
    end)
    |> Map.put(:post_raw, post)
  end
end
