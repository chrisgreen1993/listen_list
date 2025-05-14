defmodule ListenList.Reddit.Post do
  alias ListenList.Reddit.Embed
  @new_release_identifier "[FRESH ALBUM]"

  def new_release_identifier, do: @new_release_identifier

  defp release_field_mappers do
    %{
      "id" => &%{reddit_id: &1},
      "url" => &%{url: remove_invalid_url(&1)},
      "score" => &%{score: &1},
      "permalink" => &%{post_url: "https://reddit.com" <> &1},
      "created_utc" => &created_timestamp_to_post_created_at/1,
      "thumbnail" => &%{thumbnail_url: &1 |> HtmlEntities.decode() |> remove_invalid_url()},
      "secure_media" => &%{embed: &1["oembed"]}
    }
  end

  defp remove_invalid_url(url) do
    uri = URI.parse(url)
    valid? = uri.scheme != nil && uri.host =~ "."
    if valid?, do: url, else: nil
  end

  # Check that the title is valid and that the post has not been removed
  def valid?(%{"removed_by_category" => removed_by_category, "title" => title}) do
    valid_title?(title) && is_nil(removed_by_category)
  end

  def valid?(%{"title" => title}), do: valid_title?(title)

  defp valid_title?(title), do: String.starts_with?(title, @new_release_identifier)

  # Extract the artist and album from the post title
  # The title should be in the format "[FRESH ALBUM] Artist - Album"
  # where - can be any type of unicode dash
  def title_to_artist_and_album(title) do
    cleaned_title =
      title
      |> String.replace(@new_release_identifier, "")
      |> String.trim()
      |> HtmlEntities.decode()

    # Match the delimeter between artist and album, this can be any type od unicode dash
    # either once or twice, with at least one spaceon each side
    delimiter_regex_string = "\\s+\\p{Pd}{1,2}\\s+"

    # This matches the artist and album, with the artist being non-greedy
    # so that it stops at the first occurence of the delimiter
    # Note that this is not ideal, as an artist name could contain a match for the delimiter,
    # therefore causing us to put artist information in the album field.
    # However, it is more likely that the album name will contain delimeter matches than the artist name.
    regex = ~r/(?<artist>.+?)#{delimiter_regex_string}(?<album>.+)/u

    case Regex.named_captures(regex, cleaned_title) do
      %{"artist" => artist, "album" => album} ->
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

  def build_release(post, import_type) do
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
