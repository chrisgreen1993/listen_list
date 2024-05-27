defmodule Mix.Tasks.ImportReleasesFromApi do
  use Mix.Task

  @requirements ["app.config"]

  @shortdoc "Manually fetch new releases from Reddit and store them in the database"
  def run(_args) do
    {:ok, _} = Application.ensure_all_started(:listen_list)
    ListenList.Jobs.ImportReleasesJob.run()
  end
end
