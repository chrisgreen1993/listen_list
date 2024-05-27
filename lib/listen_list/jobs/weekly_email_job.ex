defmodule ListenList.Jobs.WeeklyEmailJob do
  alias ListenList.Mailer
  alias ListenList.Music
  alias ListenList.Email
  alias ListenList.Subscribers
  require Logger

  def run do
    subscribers =
      Subscribers.list_confirmed_subscribers()
      |> Enum.map(fn subscriber ->
        token = Subscribers.Token.sign_unsubscribe_token(subscriber.id)

        %{
          email: subscriber.email,
          name: subscriber.name,
          token: token
        }
      end)

    Logger.info("Sending weekly email to #{length(subscribers)} subscribers")
    releases = Music.list_top_releases_for_weekly_email()

    if releases do
      Email.weekly_releases(subscribers, releases) |> Mailer.deliver!()

      Logger.info("Weekly email sent")
    else
      Logger.warning("No releases: Cannot send weekly email")
    end
  end
end
