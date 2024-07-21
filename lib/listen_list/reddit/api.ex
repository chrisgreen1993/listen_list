defmodule ListenList.Reddit.API do
  @moduledoc """
  Module for fetching new posts from the subreddit /r/indieheads.
  """

  alias HTTPoison
  alias HtmlEntities
  alias ListenList.Reddit.Post
  require Logger

  @user_agent "listenlist-reddit"

  @access_token_endpoint "https://www.reddit.com/api/v1/access_token"

  @subreddit_search_endpoint "https://oauth.reddit.com/r/indieheads/search"

  @default_api_options [
    q: "self:no" <> Post.new_release_identifier(),
    restrict_sr: "on",
    sort: "new",
    limit: 100,
    t: "all"
  ]

  # Fetch the access token for redit oauth, using the client credentials flow
  def fetch_access_token() do
    [client_id: client_id, client_secret: client_secret] =
      Application.get_env(:listen_list, :reddit_oauth)

    headers = [
      {"User-Agent", @user_agent},
      {"Authorization", "Basic #{Base.encode64(client_id <> ":" <> client_secret)}"}
    ]

    form_body = [
      {"grant_type", "client_credentials"},
      {"duration", "permanent"}
    ]

    case HTTPoison.post(@access_token_endpoint, {:form, form_body}, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, %{"access_token" => access_token}} = Jason.decode(body)
        access_token

      {:ok, %{status_code: status_code}} ->
        Logger.error("HTTP request failed with status code #{status_code}")

      {:error, reason} ->
        Logger.error("HTTP request failed with reason #{inspect(reason)}")
    end
  end

  # fetch new releases using the Reddit search API
  # This will keep paging through the search results using the after param
  # but Reddit will only ever return ~250 search results
  def fetch_new_releases(access_token, api_options \\ []) do
    query_params = Keyword.merge(@default_api_options, api_options)

    search_url =
      @subreddit_search_endpoint <> "?" <> URI.encode_query(query_params)

    headers = [
      {"User-Agent", @user_agent},
      {"Authorization", "Bearer #{access_token}"}
    ]

    case HTTPoison.get(search_url, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        {:ok, %{"data" => %{"children" => posts, "after" => next_after}}} = Jason.decode(body)

        releases =
          posts
          |> Enum.filter(&Post.valid_post?(&1["data"]))
          |> Enum.map(&Post.post_to_release(&1["data"], :api))

        if next_after do
          # add the after param so we can fetch the next page of results
          next_api_options = Keyword.put(api_options, :after, next_after)
          releases ++ fetch_new_releases(access_token, next_api_options)
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
end
