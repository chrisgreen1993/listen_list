defmodule ListenList.MusicTest do
  use ListenList.DataCase

  alias ListenList.Music

  describe "releases" do
    alias ListenList.Music.Release

    import ListenList.MusicFixtures

    @invalid_attrs %{title: nil, url: nil}

    test "list_releases/0 returns all releases" do
      release = release_fixture()
      assert Music.list_releases() == [release]
    end

    test "get_release!/1 returns the release with given id" do
      release = release_fixture()
      assert Music.get_release!(release.id) == release
    end

    test "create_release/1 with valid data creates a release" do
      valid_attrs = %{
        title: "some title",
        url: "some url",
        reddit_id: "some reddit_id",
        score: 1,
        permalink: "some permalink",
        post_raw: %{}
      }

      assert {:ok, %Release{} = release} = Music.create_release(valid_attrs)
      assert release.title == "some title"
      assert release.url == "some url"
    end

    test "create_release/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Music.create_release(@invalid_attrs)
    end

    test "update_release/2 with valid data updates the release" do
      release = release_fixture()
      update_attrs = %{title: "some updated title", url: "some updated url"}

      assert {:ok, %Release{} = release} = Music.update_release(release, update_attrs)
      assert release.title == "some updated title"
      assert release.url == "some updated url"
    end

    test "update_release/2 with invalid data returns error changeset" do
      release = release_fixture()
      assert {:error, %Ecto.Changeset{}} = Music.update_release(release, @invalid_attrs)
      assert release == Music.get_release!(release.id)
    end

    test "delete_release/1 deletes the release" do
      release = release_fixture()
      assert {:ok, %Release{}} = Music.delete_release(release)
      assert_raise Ecto.NoResultsError, fn -> Music.get_release!(release.id) end
    end

    test "change_release/1 returns a release changeset" do
      release = release_fixture()
      assert %Ecto.Changeset{} = Music.change_release(release)
    end
  end
end
