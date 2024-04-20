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
      "created_utc" => &created_timestamp_to_post_created_at/1,
      "thumbnail" => &%{thumbnail_url: if(&1 == "default", do: nil, else: &1)}
    }
  end

  # Check that the title is valid and that the post has not been removed
  def valid_post?(%{"removed_by_category" => removed_by_category, "title" => title}) do
    valid_post_title?(title) && is_nil(removed_by_category)
  end

  def valid_post?(%{"title" => title}), do: valid_post_title?(title)

  defp valid_post_title?(title) do
    case String.starts_with?(title, @new_release_identifier) do
      false ->
        false

      true ->
        title
        |> String.replace(@new_release_identifier, "")
        |> String.trim()
        |> String.contains?(@artist_album_delimiter)
    end
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

  defp to_integer(value) when is_binary(value), do: String.to_integer(value)
  defp to_integer(value), do: value

  # Convert reddits unix timestamp to a proper DateTime.
  # Note that sometimes the data we get from the historical reddit dumps
  # can have the timestamp as a string instead of an integer
  defp created_timestamp_to_post_created_at(timestamp) do
    post_created_at =
      timestamp
      |> to_integer()
      |> trunc()
      |> DateTime.from_unix!()

    %{post_created_at: post_created_at}
  end

  def post_to_release(post, import_type) do
    Enum.reduce(release_field_mappers(), %{}, fn {k, function}, acc ->
      if value = Map.get(post, k) do
        Map.merge(acc, function.(value))
      else
        acc
      end
    end)
    # For now we default import_status to auto until we implement the logic for this.
    |> Map.merge(%{post_raw: post, import_type: import_type, import_status: :auto})
  end
end
