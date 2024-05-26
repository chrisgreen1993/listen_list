defmodule ListenList.Jobs.WeeklyEmailJob do
  alias ListenList.Mailer
  alias ListenList.Music
  alias ListenList.Email
  alias ListenList.Subscribers
  require Logger

  def run do
    subscribers = Subscribers.list_confirmed_subscribers()
    Logger.info("Sending weekly email to #{length(subscribers)} subscribers")
    releases = Music.list_top_releases_this_week()

    if releases do
      subscribers
      |> Enum.map(fn subscriber ->
        token = Subscribers.Token.sign_unsubscribe_token(subscriber.id)
        Email.weekly_releases(subscriber, releases, token)
      end)
      |> Mailer.deliver_many()

      Logger.info("Weekly email sent")
    else
      Logger.warning("No releases: Cannot send weekly email")
    end
  end
end
