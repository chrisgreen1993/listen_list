defmodule ListenList.Jobs.FetchReleasesJob do
  use GenServer

  alias ListenList.Reddit
  alias ListenList.Music
  require Logger

  def start_link(period_in_millis) do
    GenServer.start_link(__MODULE__, period_in_millis, name: __MODULE__)
  end

  @impl true
  def init(period_in_millis) do
    handle_info(:fetch_releases, period_in_millis)
    {:ok, period_in_millis}
  end

  @impl true
  def handle_info(:fetch_releases, period_in_millis) do
    fetch_releases()
    schedule_work(period_in_millis)
    {:noreply, period_in_millis}
  end

  defp schedule_work(period_in_millis) do
    Process.send_after(self(), :fetch_releases, period_in_millis)
  end

  def fetch_releases do
    releases = Reddit.fetch_new_releases()
    Music.create_or_update_releases(releases)
  end
end
