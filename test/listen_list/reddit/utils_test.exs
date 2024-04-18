defmodule ListenList.Reddit.UtilsTest do
  use ExUnit.Case
  alias ListenList.Reddit.Utils

  describe "valid_post?" do
    test "returns true if the post has a valid identifier and delimeter" do
      post = %{"title" => "[FRESH ALBUM] Artist - Album", "removed_by_category" => nil}
      assert Utils.valid_post?(post)
    end

    test "returns false if the post does not have a valid identifier" do
      post = %{"title" => "Artist - Album", "removed_by_category" => nil}
      refute Utils.valid_post?(post)
    end

    test "returns false if the post does not have a valid delimiter between album and artist" do
      post = %{"title" => "[FRESH ALBUM] - Artist Album", "removed_by_category" => nil}
      refute Utils.valid_post?(post)
    end

    test "returns false if the post has been removed" do
      post = %{"title" => "[FRESH ALBUM] Artist - Album", "removed_by_category" => "deleted"}
      refute Utils.valid_post?(post)
    end
  end

  describe "post_to_release" do
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
        :post_raw
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
          "thumbnail" => "https://thumbnail.com"
        },
        overrides
      )
    end

    test "returns a release with the title transformed into artist and album" do
      release = Utils.post_to_release(post_fixture())
      assert release_has_expected_keys?(release)
      assert release[:album] == "Album"
      assert release[:artist] == "Artist"
    end

    test "returns a release with the original post data in post_raw" do
      post = post_fixture()
      release = Utils.post_to_release(post)
      assert release_has_expected_keys?(release)
      assert release[:post_raw] == post
    end

    test "returns a releases with the full post_url" do
      post = post_fixture()
      release = Utils.post_to_release(post)
      assert release[:post_url] == "https://reddit.com" <> post["permalink"]
    end

    test "returns a release with post_created_at DateTime" do
      post = post_fixture()
      release = Utils.post_to_release(post)
      assert release[:post_created_at] == DateTime.from_unix!(1_614_556_800)
    end

    test "returns a release with post_created_at DateTime when the timestamp is string" do
      post = post_fixture(%{"created_utc" => "1614556800"})
      release = Utils.post_to_release(post)
      assert release[:post_created_at] == DateTime.from_unix!(1_614_556_800)
    end

    test "returns a release with thumbnail_url" do
      post = post_fixture()
      release = Utils.post_to_release(post)
      assert release[:thumbnail_url] == "https://thumbnail.com"
    end

    test "returns a release with thumbnail_url as nil if its default" do
      post = post_fixture(%{"thumbnail" => "default"})
      release = Utils.post_to_release(post)
      assert release[:thumbnail_url] == nil
    end
  end
end
