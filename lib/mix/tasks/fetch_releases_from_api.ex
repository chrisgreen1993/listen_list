defmodule Mix.Tasks.FetchReleasesFromApi do
  use Mix.Task

  @shortdoc "Manually fetch new releases from Reddit and store them in the database"
  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:listen_list)
    ListenList.Jobs.FetchReleasesJob.fetch_releases()
  end
end
