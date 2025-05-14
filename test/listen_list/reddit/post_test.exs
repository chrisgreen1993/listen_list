defmodule ListenList.Reddit.PostTest do
  use ExUnit.Case
  alias ListenList.Reddit.Post

  def release_has_expected_keys?(release) do
    expected_keys = [
      :reddit_id,
      :artist,
      :album,
      :url,
      :score,
      :post_url,
      :post_created_at,
      :thumbnail_url,
      :post_raw,
      :import_status,
      :import_type,
      :embed
    ]

    expected_keys |> Enum.all?(&Map.has_key?(release, &1))
  end

  def post_fixture(overrides \\ %{}) do
    Map.merge(
      %{
        "id" => "123",
        "title" => "[FRESH ALBUM] Artist - Album ",
        "url" => "https://reddit.com",
        "score" => 100,
        "permalink" => "/r/indieheads/123",
        "created_utc" => 1_614_556_800,
        "thumbnail" => "https://thumbnail.com/12345.jpeg",
        "secure_media" => %{"oembed" => %{"html" => "<iframe></iframe>"}}
      },
      overrides
    )
  end

  describe "valid?" do
    test "returns true if the post has a valid identifier and delimeter" do
      post = %{"title" => "[FRESH ALBUM] Artist - Album", "removed_by_category" => nil}
      assert Post.valid?(post)
    end

    test "returns false if the post does not have a valid identifier" do
      post = %{"title" => "Artist - Album", "removed_by_category" => nil}
      refute Post.valid?(post)
    end

    test "returns false if the post has been removed" do
      post = %{"title" => "[FRESH ALBUM] Artist - Album", "removed_by_category" => "deleted"}
      refute Post.valid?(post)
    end
  end

  describe "build_release" do
    test "returns a release with the artist and album extracted from the embed data if it is Spotify" do
      embed_desc = "Listen to Embed Album on Spotify. Embed Artist · Album · 2024 · 11 songs."
      embed_data = %{"oembed" => %{"provider_name" => "Spotify", "description" => embed_desc}}

      release = Post.build_release(post_fixture(%{"secure_media" => embed_data}), :api)
      assert release_has_expected_keys?(release)
      assert release[:album] == "Embed Album"
      assert release[:artist] == "Embed Artist"
    end

    test "returns a release with the artist and album extracted from the embed data if it is BandCamp" do
      embed_title = "Embed Album, by Embed Artist"
      embed_data = %{"oembed" => %{"provider_name" => "BandCamp", "title" => embed_title}}

      release = Post.build_release(post_fixture(%{"secure_media" => embed_data}), :api)
      assert release_has_expected_keys?(release)
      assert release[:album] == "Embed Album"
      assert release[:artist] == "Embed Artist"
    end

    test "returns a release with the album and artist from the title field if the embed provider is not supported" do
      embed_desc = "Embed Album by Embed Artist"
      embed_data = %{"oembed" => %{"provider_name" => "YouTube", "description" => embed_desc}}

      release = Post.build_release(post_fixture(%{"secure_media" => embed_data}), :api)
      assert release_has_expected_keys?(release)
      assert release[:album] == "Album"
      assert release[:artist] == "Artist"
    end

    test "returns the album and artist from the title field if the embed description cannpt be parsed" do
      embed_desc =
        "Embed Album INCORRECT Embed Artist, released 24 May 2024 1. Track One 2. Track Two."

      embed_data = %{"oembed" => %{"provider_name" => "BandCamp", "description" => embed_desc}}

      release = Post.build_release(post_fixture(%{"secure_media" => embed_data}), :api)
      assert release_has_expected_keys?(release)
      assert release[:album] == "Album"
      assert release[:artist] == "Artist"
    end

    test "returns a release with the original post data in post_raw" do
      post = post_fixture()
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:post_raw] == post
    end

    test "returns a releases with the full post_url" do
      post = post_fixture()
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:post_url] == "https://reddit.com" <> post["permalink"]
    end

    test "returns a release with post_created_at DateTime" do
      post = post_fixture()
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:post_created_at] == DateTime.from_unix!(1_614_556_800)
    end

    test "returns a release with post_created_at DateTime when the timestamp is string" do
      post = post_fixture(%{"created_utc" => "1614556800"})
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:post_created_at] == DateTime.from_unix!(1_614_556_800)
    end

    test "returns a release with thumbnail_url if the url is valid" do
      post = post_fixture()
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:thumbnail_url] == "https://thumbnail.com/12345.jpeg"
    end

    test "returns a release with thumbnail_url as nil if the url is invalid" do
      post = post_fixture(%{"thumbnail" => "invalid_url"})
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:thumbnail_url] == nil
    end

    test "returns a release with thumbnail_url decoded if it contains html entities" do
      post =
        post_fixture(%{
          "thumbnail" => "https://thumbnail.com/123456.jpeg?param1=value1&amp;param2=value2"
        })

      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)

      assert release[:thumbnail_url] ==
               "https://thumbnail.com/123456.jpeg?param1=value1&param2=value2"
    end

    test "returns a release with import_status as :auto if the title has a delimeter" do
      post = post_fixture()
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:import_status] == :auto
    end

    test "returns a release with import_status as :in_review if the title does not have a delimeter" do
      post = post_fixture(%{"title" => "[FRESH ALBUM] Artist Album"})
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:import_status] == :in_review
    end

    test "returns a release with import_status as :in_review if the delimeter isn't valid" do
      post = post_fixture(%{"title" => "[FRESH ALBUM] Artist -Album"})
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:import_status] == :in_review
    end

    test "returns a release with import_type as :api" do
      post = post_fixture()
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:import_type] == :api
    end

    test "returns a release with import_type as :file" do
      post = post_fixture()
      release = Post.build_release(post, :file)
      assert release_has_expected_keys?(release)
      assert release[:import_type] == :file
    end

    test "returns a release with the embed data" do
      post = post_fixture()
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:embed] == %{"html" => "<iframe></iframe>"}
    end

    test "returns a release with the url if it is valid" do
      post = post_fixture()
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:url] == "https://reddit.com"
    end

    test "returns a release with the url as nil if it is invalid" do
      post = post_fixture(%{"url" => "invalid_url"})
      release = Post.build_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:url] == nil
    end
  end

  describe "build_release title parsing" do
    @title_test_cases [
      %{
        title: "[FRESH ALBUM] Artist \u002D Album 1",
        expected_artist: "Artist",
        expected_album: "Album 1"
      },
      %{
        title: "[FRESH ALBUM] Artist \u2014 Album 2",
        expected_artist: "Artist",
        expected_album: "Album 2"
      },
      %{
        title: "[FRESH ALBUM] Artist \u2013 Album 3",
        expected_artist: "Artist",
        expected_album: "Album 3"
      },
      %{
        title: "[FRESH ALBUM] Artist \u002D\u002D Album 4",
        expected_artist: "Artist",
        expected_album: "Album 4"
      },
      %{
        title: "[FRESH ALBUM] Artist \u2014\u2014 Album 5",
        expected_artist: "Artist",
        expected_album: "Album 5"
      },
      %{
        title: "[FRESH ALBUM] Artist \u2013\u2013 Album 6",
        expected_artist: "Artist",
        expected_album: "Album 6"
      },
      %{
        title: "[FRESH ALBUM] Artist-Thing \u002D Album \u002D More Stuff",
        expected_artist: "Artist-Thing",
        expected_album: "Album - More Stuff"
      }
    ]

    Enum.each(@title_test_cases, fn %{
                                      title: title,
                                      expected_artist: artist,
                                      expected_album: album
                                    } ->
      test "returns a release with the title transformed into artist and album for '#{title}'" do
        post = post_fixture(%{"title" => unquote(title)})
        release = Post.build_release(post, :api)
        assert release_has_expected_keys?(release)
        assert release[:album] == unquote(album)
        assert release[:artist] == unquote(artist)
      end
    end)
  end
end
