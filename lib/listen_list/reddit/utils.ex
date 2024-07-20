defmodule ListenList.Reddit.Utils do
  alias ListenList.Reddit.Embed
  @new_release_identifier "[FRESH ALBUM]"

  # Not a great way to decide, but it's all we've got
  @artist_album_delimiter " - "

  def new_release_identifier, do: @new_release_identifier

  defp release_field_mappers do
    %{
      "id" => &%{reddit_id: &1},
      "url" => &%{url: remove_invalid_url(&1)},
      "score" => &%{score: &1},
      "permalink" => &%{post_url: "https://reddit.com" <> &1},
      "created_utc" => &created_timestamp_to_post_created_at/1,
      "thumbnail" => &%{thumbnail_url: remove_invalid_url(&1)},
      "secure_media" => &%{embed: &1["oembed"]}
    }
  end

  def remove_invalid_url(url) do
    uri = URI.parse(url)
    valid? = uri.scheme != nil && uri.host =~ "."
    if valid?, do: url, else: nil
  end

  # Check that the title is valid and that the post has not been removed
  def valid_post?(%{"removed_by_category" => removed_by_category, "title" => title}) do
    valid_post_title?(title) && is_nil(removed_by_category)
  end

  def valid_post?(%{"title" => title}), do: valid_post_title?(title)

  defp valid_post_title?(title), do: String.starts_with?(title, @new_release_identifier)

  # Extract the artist and album from the post title
  # The title should be in the format "[FRESH ALBUM] Artist - Album"
  defp title_to_artist_and_album(title) do
    title
    |> String.replace(@new_release_identifier, "")
    |> String.trim()
    |> HtmlEntities.decode()
    |> String.split(@artist_album_delimiter)
    |> case do
      [artist, album] when is_binary(artist) and is_binary(album) ->
        %{artist: artist, album: album}

      _ ->
        nil
    end
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

  # Extract artist and album from the post
  # First, if the post has an embed from a supported provider, extract the album details from the description.
  # If there is no embed, or the provider is not supported, or the embed description cannot be parsed, extract the artist and album from the title.
  defp extract_artist_and_album(post) do
    embed = post["secure_media"]["oembed"]

    maybe_album_details =
      with true <- Embed.supported_provider?(embed),
           %{} = album_details <- Embed.extract_album_details(embed) do
        album_details
      else
        _ ->
          title_to_artist_and_album(post["title"])
      end

    case maybe_album_details do
      nil -> %{artist: nil, album: nil, import_status: :in_review}
      %{artist: artist, album: album} -> %{artist: artist, album: album, import_status: :auto}
    end
  end

  def post_to_release(post, import_type) do
    Enum.reduce(release_field_mappers(), %{}, fn {k, function}, acc ->
      if value = Map.get(post, k) do
        Map.merge(acc, function.(value))
      else
        acc
      end
    end)
    |> Map.merge(extract_artist_and_album(post))
    |> Map.merge(%{post_raw: post, import_type: import_type})
  end
end
