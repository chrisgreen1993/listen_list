defmodule ListenList.Reddit.File do
  alias ListenList.Reddit.Utils

  # fetch releases from a reddit dump file in chunks
  # We use a stream here as the dump files are huge and we don't want to run out of memory
  def fetch_releases(file_path, opts) do
    limit = Keyword.get(opts, :limit) || :infinity
    chunk_size = Keyword.get(opts, :chunk_size) || 200

    file_path
    |> create_json_stream()
    |> Stream.filter(&Utils.valid_post?(&1))
    |> Stream.map(&Utils.post_to_release(&1, :file))
    |> maybe_limit(limit)
    |> Stream.chunk_every(chunk_size)
  end

  defp maybe_limit(stream, :infinity), do: stream
  defp maybe_limit(stream, limit), do: Stream.take(stream, limit)

  defp create_json_stream(file_path) do
    Stream.resource(
      fn -> File.open!(file_path) end,
      fn file ->
        case IO.read(file, :line) do
          :eof -> {:halt, file}
          line -> {[Jason.decode!(line)], file}
        end
      end,
      fn file -> File.close(file) end
    )
  end
end
