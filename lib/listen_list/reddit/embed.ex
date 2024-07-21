defmodule ListenList.Reddit.Embed do
  @providers [spotify: "Spotify", bandcamp: "BandCamp"]

  def supported_provider?(%{"provider_name" => provider_name}) do
    Enum.member?(Keyword.values(@providers), provider_name)
  end

  def supported_provider?(_), do: false

  def extract_album_details(%{
        "provider_name" => unquote(@providers[:spotify]),
        "description" => description
      }) do
    # Spotify can have two different formats for the description
    # The newer format: "Listen to Album on Spotify. Artist · Album · 2024 · 11 songs."
    # The older format: "Album, an album by Artist on Spotify"
    # We try to match both formats
    regexes = [
      ~r/Listen to (?<album>.+) on Spotify\. (?<artist>.+?) · /,
      ~r/(?<album>.+), an? .+? by (?<artist>.+?) on Spotify/
    ]

    decoded_description = HtmlEntities.decode(description)

    Enum.reduce_while(regexes, nil, fn regex, _ ->
      case Regex.named_captures(regex, decoded_description) do
        %{"album" => album, "artist" => artist} ->
          {:halt, %{album: album, artist: artist}}

        _ ->
          {:cont, nil}
      end
    end)
  end

  def extract_album_details(%{
        "provider_name" => unquote(@providers[:bandcamp]),
        "title" => title
      }) do
    regex = ~r/(?<album>.+), by (?<artist>.+)/
    decoded_title = HtmlEntities.decode(title)

    case Regex.named_captures(regex, decoded_title) do
      %{"album" => album, "artist" => artist} ->
        %{album: album, artist: artist}

      _ ->
        nil
    end
  end

  def extract_album_details(_),
    do: nil
end
