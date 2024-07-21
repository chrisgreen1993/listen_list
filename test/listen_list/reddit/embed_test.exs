defmodule ListenList.Reddit.EmbedTest do
  use ExUnit.Case
  alias ListenList.Reddit.Embed

  describe "supported_provider?" do
    test "returns true for supported providers" do
      assert Embed.supported_provider?(%{"provider_name" => "Spotify"})
      assert Embed.supported_provider?(%{"provider_name" => "BandCamp"})
    end

    test "returns false for unsupported providers" do
      refute Embed.supported_provider?(%{"provider_name" => "YouTube"})
    end
  end

  describe "extract_album_details" do
    test "extracts album and artist if the embed provider is Spotify and the release is an album" do
      embed_desc =
        "Listen to Embed Album 123!!! on Spotify. Embed Artist 123!!! · Album · 2024 · 11 songs."

      embed = %{"provider_name" => "Spotify", "description" => embed_desc}
      expected = %{album: "Embed Album 123!!!", artist: "Embed Artist 123!!!"}

      assert Embed.extract_album_details(embed) == expected
    end

    test "extracts album and artist if the embed provider is Spotify and the release is an Ep" do
      embed_desc =
        "Listen to Embed Album 123!!! on Spotify. Embed Artist 123!!! · Ep · 2024 · 11 songs."

      embed = %{"provider_name" => "Spotify", "description" => embed_desc}
      expected = %{album: "Embed Album 123!!!", artist: "Embed Artist 123!!!"}

      assert Embed.extract_album_details(embed) == expected
    end

    test "extracts album and artist if the embed provider is Spotify and the description uses the old format and the release is an album" do
      embed_desc =
        "Embed Album 123!!!, an animal, an album by Embed Artist 123!!! on Spotify"

      embed = %{"provider_name" => "Spotify", "description" => embed_desc}
      expected = %{album: "Embed Album 123!!!, an animal", artist: "Embed Artist 123!!!"}

      assert Embed.extract_album_details(embed) == expected
    end

    test "extracts album and artist if the embed provider is Spotify and the description uses the old format and the release is a single" do
      embed_desc =
        "Embed Album 123!!!, a test, a single by Embed Artist 123!!! on Spotify"

      embed = %{"provider_name" => "Spotify", "description" => embed_desc}
      expected = %{album: "Embed Album 123!!!, a test", artist: "Embed Artist 123!!!"}

      assert Embed.extract_album_details(embed) == expected
    end

    test "extracts album and artist if the embed provider is BandCamp" do
      embed_desc =
        "Embed Album 123!!! by Embed Artist 123!!!, released 24 May 2024 1. Track One 2. Track Two."

      embed = %{"provider_name" => "BandCamp", "description" => embed_desc}
      expected = %{album: "Embed Album 123!!!", artist: "Embed Artist 123!!!"}

      assert Embed.extract_album_details(embed) == expected
    end

    test "returns nil if the embed provider is supported but the description cannot be parsed" do
      embed_desc =
        "Embed Album INCORRECT Embed Artist, released 24 May 2024 1. Track One 2. Track Two."

      embed = %{"provider_name" => "BandCamp", "description" => embed_desc}
      assert Embed.extract_album_details(embed) == nil
    end

    test "returns nil for unsupported providers" do
      provider_info = %{"provider_name" => "YouTube", "description" => "Some description"}
      assert Embed.extract_album_details(provider_info) == nil
    end
  end
end
