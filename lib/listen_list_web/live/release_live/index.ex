defmodule ListenListWeb.ReleaseLive.Index do
  use ListenListWeb, :live_view

  alias ListenList.Music
  alias ListenList.Subscribers
  alias ListenList.Mailer
  alias ListenList.Email

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       releases: Music.list_top_releases(:week),
       selected_period: :week,
       release: nil,
       subscribe_modal?: false
     )}
  end

  @impl true
  def handle_event("show_subscribe_modal", _params, socket) do
    {:noreply, assign(socket, subscribe_modal?: true)}
  end

  def handle_event("hide_subscribe_modal", _params, socket) do
    {:noreply, assign(socket, subscribe_modal?: false)}
  end

  def handle_event("change_period", %{"period" => period}, socket) do
    releases = Music.list_top_releases(String.to_atom(period))

    {:noreply,
     assign(socket, releases: releases, selected_period: String.to_atom(period), release: nil)}
  end

  def handle_event("show_release_modal", %{"id" => id}, socket) do
    release = Music.get_release!(id)
    {:noreply, assign(socket, release: release)}
  end

  def handle_event("hide_release_modal", _params, socket) do
    {:noreply, assign(socket, release: nil)}
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
