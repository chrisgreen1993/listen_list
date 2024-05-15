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
          "thumbnail" => "https://thumbnail.com",
          "secure_media" => %{"oembed" => %{"html" => "<iframe></iframe>"}}
        },
        overrides
      )
    end

    test "returns a release with the title transformed into artist and album" do
      release = Utils.post_to_release(post_fixture(), :api)
      assert release_has_expected_keys?(release)
      assert release[:album] == "Album"
      assert release[:artist] == "Artist"
    end

    test "returns a release with the original post data in post_raw" do
      post = post_fixture()
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:post_raw] == post
    end

    test "returns a releases with the full post_url" do
      post = post_fixture()
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:post_url] == "https://reddit.com" <> post["permalink"]
    end

    test "returns a release with post_created_at DateTime" do
      post = post_fixture()
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:post_created_at] == DateTime.from_unix!(1_614_556_800)
    end

    test "returns a release with post_created_at DateTime when the timestamp is string" do
      post = post_fixture(%{"created_utc" => "1614556800"})
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:post_created_at] == DateTime.from_unix!(1_614_556_800)
    end

    test "returns a release with thumbnail_url" do
      post = post_fixture()
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:thumbnail_url] == "https://thumbnail.com"
    end

    test "returns a release with thumbnail_url as nil if its default" do
      post = post_fixture(%{"thumbnail" => "default"})
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:thumbnail_url] == nil
    end

    test "returns a release with import_status as :auto if the title has a delimeter" do
      post = post_fixture()
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:import_status] == :auto
    end

    test "returns a release with import_status as :in_review if the title does not have a delimeter" do
      post = post_fixture(%{"title" => "[FRESH ALBUM] Artist Album"})
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:import_status] == :in_review
    end

    test "returns a release with import_status as :in_review if there is more than one delimeter" do
      post = post_fixture(%{"title" => "[FRESH ALBUM] Artist - ??? - Album"})
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:import_status] == :in_review
    end

    test "returns a release with import_status as :in_review if the fdelimeter isn't valid" do
      post = post_fixture(%{"title" => "[FRESH ALBUM] Artist -Album"})
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:import_status] == :in_review
    end

    test "returns a release with import_type as :api" do
      post = post_fixture()
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:import_type] == :api
    end

    test "returns a release with import_type as :file" do
      post = post_fixture()
      release = Utils.post_to_release(post, :file)
      assert release_has_expected_keys?(release)
      assert release[:import_type] == :file
    end

    test "returns a release with the embed data" do
      post = post_fixture()
      release = Utils.post_to_release(post, :api)
      assert release_has_expected_keys?(release)
      assert release[:embed] == %{"html" => "<iframe></iframe>"}
    end
  end
end
