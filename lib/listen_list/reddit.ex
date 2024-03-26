defmodule ListenList.Reddit do
  @moduledoc """
  Module for fetching new posts from the subreddit /r/indieheads.
  """

  alias HTTPoison
  require Logger


  @post_data_key_map %{
    "id" => "reddit_id",
    "title" => "title",
    "url" => "url",
    "score" => "score",
    "permalink" => "permalink"
  }

  @query_params [
    q: "self:no[FRESH ALBUM]",
    restrict_sr: "on",
    sort: "new",
    limit: 5,
    t: "month"
  ]


  def fetch_new_releases do
    search_url = "https://www.reddit.com/r/indieheads/search.json?" <> URI.encode_query(@query_params)

    case HTTPoison.get(search_url) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, %{"data" => %{"children" => posts}}} = Jason.decode(body)
        Enum.map(posts, &parse_post/1)

      {:ok, %{status_code: status_code}} ->
        Logger.error("HTTP request failed with status code #{status_code}")

      {:error, reason} ->
        Logger.error("HTTP request failed with reason #{inspect(reason)}")
    end
  end

  defp parse_post(%{"data" => data}) do
    data
    |> Map.take(Map.keys(@post_data_key_map))
    |> Enum.map(fn {k, v} -> {String.to_atom(Map.get(@post_data_key_map, k)), v} end)
    |> Enum.into(%{})
    |> Map.put(:raw_post, data)
  end
end