defmodule ListenList.Email.WeeklyReleases do
  use MjmlEEx, mjml_template: "weekly_releases.mjml.eex"
  use ListenListWeb, :html
  import Swoosh.Email

  def create(subscribers, releases) do
    recipients = Enum.map(subscribers, &{&1.name, &1.email})

    # In order to send bulk emails with a single api call to MailGun,
    # we need to provide these recipient variables which we use in the template as
    # %recipient.name% etc which mailgun then replaces.
    recipient_vars =
      Enum.into(subscribers, %{}, fn subscriber ->
        {subscriber.email, %{name: subscriber.name, unsubscribe_token: subscriber.token}}
      end)

    base_url = ListenListWeb.Endpoint.url()
    unsubscribe_path = "/subscribers/unsubscribe/"
    unsubscribe_url = base_url <> unsubscribe_path

    new()
    |> to(recipients)
    |> from({"Listen List", "notifications@mail.listenlist.app"})
    |> subject("This week's best new music! | Listen List")
    |> html_body(
      render(base_url: base_url, releases: releases.releases, unsubscribe_url: unsubscribe_url)
    )
    |> put_provider_option(:recipient_vars, recipient_vars)
  end
end
