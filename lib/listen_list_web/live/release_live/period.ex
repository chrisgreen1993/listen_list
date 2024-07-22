defmodule ListenListWeb.ReleaseLive.Period do
  use ListenListWeb, :live_view
  alias ListenList.Releases
  alias ListenList.Subscribers
  alias ListenList.Mailer
  alias ListenList.Email

  @impl true
  def mount(%{"start" => start, "end" => end_, "period" => period}, _session, socket) do
    start_date = Timex.parse!(start, "{ISOdate}")
    end_date = Timex.parse!(end_, "{ISOdate}")
    # TODO: add pagination / infinite scroll
    releases = Releases.list_releases_for_period(start_date, end_date, 100)

    {:ok,
     assign(socket,
       releases: releases,
       period: String.to_atom(period),
       start_date: start_date,
       end_date: end_date,
       release: nil,
       subscribe_modal?: false
     )}
  end

  # Redirect home if we don't have the correct params
  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/")}
  end

  @impl true
  def handle_event("show_release_modal", %{"id" => id}, socket) do
    release = Releases.get_release!(id)
    {:noreply, assign(socket, release: release)}
  end

  def handle_event("hide_release_modal", _params, socket) do
    {:noreply, assign(socket, release: nil)}
  end

  def handle_event("show_subscribe_modal", _params, socket) do
    {:noreply, assign(socket, subscribe_modal?: true)}
  end

  def handle_event("hide_subscribe_modal", _params, socket) do
    {:noreply, assign(socket, subscribe_modal?: false)}
  end

  def handle_event("create_subscriber", %{"name" => name, "email" => email}, socket) do
    case Subscribers.create_subscriber(%{"name" => name, "email" => email}) do
      {:ok, subscriber} ->
        token = Subscribers.Token.sign_confirm_token(subscriber.id)
        email = Email.subscribe_confirmation(subscriber, token)
        # Deliver async as we don't need to wait around for a response
        Task.async(fn -> Mailer.deliver(email) end)

        {:noreply,
         socket
         |> assign(:subscribe_modal?, false)
         |> put_flash(:info, "We've sent you a confirmation email.")}

      {:error, _reason} ->
        {:noreply,
         put_flash(socket, :error, "Looks like something went wrong, please try again.")}
    end
  end
end
