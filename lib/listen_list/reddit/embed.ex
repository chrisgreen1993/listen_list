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
    regex = ~r/Listen to (?<album>.+?) on Spotify\. (?<artist>.+?) · /

    case Regex.named_captures(regex, description) do
      %{"album" => album, "artist" => artist} ->
        %{album: album, artist: artist}

      _ ->
        nil
    end
  end

  def extract_album_details(%{
        "provider_name" => unquote(@providers[:bandcamp]),
        "description" => description
      }) do
    regex = ~r/(?<album>.+) by (?<artist>.+), released/

    case Regex.named_captures(regex, description) do
      %{"album" => album, "artist" => artist} ->
        %{album: album, artist: artist}

      _ ->
        nil
    end
  end

  def extract_album_details(_),
    do: nil
end
