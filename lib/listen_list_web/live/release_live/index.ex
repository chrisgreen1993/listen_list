defmodule ListenListWeb.ReleaseLive.Index do
  use ListenListWeb, :live_view

  alias ListenList.Music

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, releases: Music.list_top_releases(:week), selected_period: :week)}
  end

  @impl true
  def handle_event("change_period", %{"period" => period}, socket) do
    releases = Music.list_top_releases(String.to_atom(period))
    {:noreply, assign(socket, releases: releases, selected_period: String.to_atom(period))}
  end
end
