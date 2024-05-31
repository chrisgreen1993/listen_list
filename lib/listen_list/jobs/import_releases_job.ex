defmodule ListenList.Jobs.ImportReleasesJob do
  alias ListenList.Reddit
  alias ListenList.Releases
  require Logger

  def run do
    Logger.info("Importing new releases")
    access_token = Reddit.API.fetch_access_token()
    releases = Reddit.API.fetch_new_releases(access_token)
    {changed_rows, _} = Releases.create_or_update_releases(releases)
    Logger.info("Inserted #{changed_rows} releases")
  end
end
