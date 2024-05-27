defmodule ListenList.Email.SubscribeConfirmation do
  use MjmlEEx, mjml_template: "subscribe_confirmation.mjml.eex"
  use ListenListWeb, :html
  import Swoosh.Email

  def create(subscriber, confirm_token) do
    confirmation_path = ~p"/subscribers/confirm/#{confirm_token}"
    confirmation_url = ListenListWeb.Endpoint.url() <> confirmation_path

    new()
    |> to({subscriber.name, subscriber.email})
    |> from({"Listen List", "notifications@mail.listenlist.app"})
    |> subject("Confirm your email | Listen List")
    |> html_body(render(subscriber: subscriber, confirmation_url: confirmation_url))
  end
end
