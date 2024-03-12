defmodule ListenListWeb.ReleaseLiveTest do
  use ListenListWeb.ConnCase

  import Phoenix.LiveViewTest
  import ListenList.MusicFixtures

  @create_attrs %{type: "some type", title: "some title", url: "some url"}
  @update_attrs %{type: "some updated type", title: "some updated title", url: "some updated url"}
  @invalid_attrs %{type: nil, title: nil, url: nil}

  defp create_release(_) do
    release = release_fixture()
    %{release: release}
  end

  describe "Index" do
    setup [:create_release]

    test "lists all releases", %{conn: conn, release: release} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Listing Releases"
      assert html =~ release.type
    end
  end
end
