defmodule Mix.Tasks.ImportReleasesFromFile do
  alias ListenList.Music
  alias ListenList.Repo
  use Mix.Task

  require Logger

  @requirements ["app.config"]

  @shortdoc "Fetches releases from a reddit dump file and inserts them into the DB"
  def run([file_path | opts]) do
    {:ok, _} = Application.ensure_all_started(:listen_list)

    limit = opts |> Enum.at(0) |> maybe_to_integer()
    chunk_size = opts |> Enum.at(1) |> maybe_to_integer()

    Logger.info(
      "Importing #{if limit, do: limit, else: "all"} releases from #{file_path} - Chunk size: #{if chunk_size, do: chunk_size, else: 200}"
    )

    # Run this in a transaction so we can rollback them all if something goes wrong
    Repo.transaction(
      fn ->
        ListenList.Reddit.File.fetch_releases(file_path, limit: limit, chunk_size: chunk_size)
        |> Enum.each(fn releases ->
          Logger.info(
            "Attempting to insert #{length(releases)} releases. Starting ID: #{List.first(releases)[:reddit_id]}"
          )

          {changed_rows, _} = Music.create_or_update_releases(releases)
          Logger.info("Inserted #{changed_rows} releases")
        end)
      end,
      # This is long running and we don't want it to timeout
      timeout: :infinity
    )

    Logger.info("Import complete!")
  end

  def maybe_to_integer(nil), do: nil
  def maybe_to_integer(string), do: String.to_integer(string)
end
