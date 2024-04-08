defmodule ListenList.Reddit do
  @moduledoc """
  Module for fetching new posts from the subreddit /r/indieheads.
  """

  alias HTTPoison
  alias HtmlEntities
  require Logger

  @new_release_identifier "[FRESH ALBUM]"

  @subreddit_search_endpoint "https://www.reddit.com/r/indieheads/search.json?"

  @default_api_options [
    q: "self:no[FRESH ALBUM]",
    restrict_sr: "on",
    sort: "new",
    limit: 100,
    t: "all"
  ]

  # fetch new releases using the Reddit search API
  # This will keep paging through the search results using the after param
  # but Reddit will only ever return ~250 search results
  def fetch_new_releases(api_options \\ []) do
    query_params = Keyword.merge(@default_api_options, api_options)

    search_url =
      @subreddit_search_endpoint <> URI.encode_query(query_params)

    case HTTPoison.get(search_url) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, %{"data" => %{"children" => posts, "after" => next_after}}} = Jason.decode(body)

        releases =
          posts
          |> Enum.filter(&valid_post_title?(&1["data"]["title"]))
          |> Enum.map(&post_to_release/1)

        if next_after do
          # add the after param so we can fetch the next page of results
          next_api_options = Keyword.put(api_options, :after, next_after)
          releases ++ fetch_new_releases(next_api_options)
        else
          releases
        end

      {:ok, %{status_code: status_code}} ->
        Logger.error("HTTP request failed with status code #{status_code}")
        []

      {:error, reason} ->
        Logger.error("HTTP request failed with reason #{inspect(reason)}")
        []
    end
  end

  defp release_field_mappers do
    %{
      "id" => {:reddit_id, & &1},
      "title" => {:title, &clean_post_title/1},
      "url" => {:url, & &1},
      "score" => {:score, & &1},
      "permalink" => {:post_url, &("https://reddit.com" <> &1)},
      "created_utc" => {:post_created_at, &DateTime.from_unix!(trunc(&1))},
      "thumbnail" => {:thumbnail_url, &if(&1 == "default", do: nil, else: &1)}
    }
  end

  defp valid_post_title?(title) do
    title
    |> String.trim()
    |> String.starts_with?(@new_release_identifier)
  end

  defp clean_post_title(title) do
    title
    |> String.replace(@new_release_identifier, "")
    |> String.trim()
    |> HtmlEntities.decode()
  end

  defp post_to_release(%{"data" => post_data} = post) do
    Enum.reduce(release_field_mappers(), %{}, fn {k, {new_key, function}}, acc ->
      if value = Map.get(post_data, k) do
        Map.put(acc, new_key, function.(value))
      else
        acc
      end
    end)
    |> Map.put(:post_raw, post)
  end
end
