defmodule ListenList.Email do
  import Swoosh.Email

  def subscribe_confirmation(subscriber, confirm_token) do
    new()
    |> to({subscriber.name, subscriber.email})
    |> from({"Listen List", "notifications@listenlist.app"})
    |> subject("Confirm your email")
    |> html_body(build_subscribe_confirmation_html(subscriber, confirm_token))
  end

  # TODO: Update this to use mailgun templates
  defp build_subscribe_confirmation_html(subscriber, token) do
    """
    <p>Hi #{subscriber.name},</p>
    <p>Thanks for signing up to our weekly email! Please click the link below to confirm your email address:</p>
    <p><a href="#{ListenListWeb.Endpoint.url()}/subscribers/confirm/#{token}">Confirm your email</a></p>
    <p>Thanks!</p>
    """
  end

  def weekly_releases(subscriber, releases, unsubscribe_token) do
    new()
    |> to({subscriber.name, subscriber.email})
    |> from({"Listen List", "notifications@listenlist.app"})
    |> subject("New music for this week!")
    |> html_body(build_weekly_releases_html(releases.releases, unsubscribe_token))
  end

  # TODO: Update this to use mailgun templates
  defp build_weekly_releases_html(releases, token) do
    releases_html =
      Enum.map(releases, fn release ->
        "<p>#{release.artist} - #{release.album}</p>"
      end)
      |> Enum.join("\n")

    """
    <h1>New Releases</h1>
    #{releases_html}"
    <p><a href="#{ListenListWeb.Endpoint.url()}/subscribers/unsubscribe/#{token}">Unsubscribe</a></p>
    """
  end
end
