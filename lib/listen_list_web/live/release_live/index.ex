defmodule ListenListWeb.ReleaseLive.Index do
  use ListenListWeb, :live_view

  alias ListenList.Releases
  alias ListenList.Subscribers

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       releases: Releases.list_top_releases(:week),
       selected_period: :week,
       release: nil,
       subscribe_modal?: false
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    period = Map.get(params, "period", "week") |> String.to_atom()
    releases = Releases.list_top_releases(period)

    {:noreply, assign(socket, releases: releases, selected_period: period)}
  end

  @impl true
  def handle_event("show_subscribe_modal", _params, socket) do
    {:noreply, assign(socket, subscribe_modal?: true)}
  end

  def handle_event("hide_subscribe_modal", _params, socket) do
    {:noreply, assign(socket, subscribe_modal?: false)}
  end

  def handle_event("change_period", %{"period" => period}, socket) do
    {:noreply, push_patch(socket, to: ~p"/?period=#{period}")}
  end

  def handle_event("show_release_modal", %{"id" => id}, socket) do
    release = Releases.get_release!(id)
    {:noreply, assign(socket, release: release)}
  end

  def handle_event("hide_release_modal", _params, socket) do
    {:noreply, assign(socket, release: nil)}
  end

  def handle_event("create_subscriber", %{"name" => name, "email" => email}, socket) do
    case Subscribers.create_subscriber_and_send_confirmation_email(%{
           "name" => name,
           "email" => email
         }) do
      {:ok, _subscriber} ->
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
