defmodule ListenListWeb.ReleaseLive.Index do
  use ListenListWeb, :live_view

  alias ListenList.Music

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :releases, Music.list_releases())}
  end
end
