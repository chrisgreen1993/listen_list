defmodule ListenList.Email do
  import Swoosh.Email

  def subscribe_confirmation(subscriber, token) do
    new()
    |> to({subscriber.name, subscriber.email})
    |> from({"Listen List", "notifications@listenlist.app"})
    |> subject("Confirm your email")
    |> html_body("""
    <p>Hi #{subscriber.name},</p>
    <p>Thanks for signing up to our weekly email! Please click the link below to confirm your email address:</p>
    <p><a href="#{ListenListWeb.Endpoint.url()}/subscribers/confirm/#{token}">Confirm your email</a></p>
    <p>Thanks!</p>
    """)
  end
end
