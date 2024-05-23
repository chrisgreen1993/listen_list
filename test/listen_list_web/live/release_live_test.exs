defmodule ListenListWeb.ReleaseLiveTest do
  use ListenListWeb.ConnCase

  import Phoenix.LiveViewTest
  import ListenList.MusicFixtures

  defp create_release(_) do
    release = release_fixture()
    %{release: release}
  end

  describe "Index" do
    setup [:create_release]

    test "lists all releases", %{conn: conn, release: release} do
      {:ok, _index_live, html} = live(conn, ~p"/")

      assert html =~ "Listen List"
    end
  end
end
