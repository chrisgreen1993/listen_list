defmodule ListenListWeb.ReleaseLive.Period do
  use ListenListWeb, :live_view
  alias ListenList.Releases
  alias ListenList.Subscribers

  @impl true
  def mount(%{"start" => start, "end" => end_, "period" => period}, _session, socket) do
    start_date = Timex.parse!(start, "{ISOdate}")
    end_date = Timex.parse!(end_, "{ISOdate}")

    {:ok,
     socket
     |> assign(
       period: String.to_atom(period),
       start_date: start_date,
       end_date: end_date,
       page: 1,
       per_page: 20,
       release: nil,
       subscribe_modal?: false
     )
     |> paginate_releases(1)}
  end

  # Redirect home if we don't have the correct params
  def mount(_params, _session, socket) do
    {:ok, redirect(socket, to: "/")}
  end

  defp paginate_releases(socket, new_page) when new_page >= 1 do
    %{per_page: per_page, page: cur_page, start_date: start_date, end_date: end_date} =
      socket.assigns

    releases =
      Releases.list_releases_for_period(
        start_date,
        end_date,
        per_page,
        (new_page - 1) * per_page
      )

    # Number of releases the stream keeps around in the DOM
    stream_limit = per_page * 3

    {releases, at, limit} =
      if new_page >= cur_page do
        {releases, -1, stream_limit * -1}
      else
        {Enum.reverse(releases), 0, stream_limit}
      end

    case releases do
      [] ->
        assign(socket, end_of_releases?: at == -1)

      [_ | _] = releases ->
        socket
        |> assign(end_of_releases?: false)
        |> assign(:page, new_page)
        |> stream(:releases, releases, at: at, limit: limit)
    end
  end

  @impl true
  def handle_event("next_page", _, socket) do
    {:noreply, paginate_releases(socket, socket.assigns.page + 1)}
  end

  # If the user immediately returns the scrollbar to the top we
  # reset to the first page
  def handle_event("prev_page", %{"_overran" => true}, socket) do
    {:noreply, paginate_releases(socket, 1)}
  end

  def handle_event("prev_page", _, socket) do
    if socket.assigns.page > 1 do
      {:noreply, paginate_releases(socket, socket.assigns.page - 1)}
    else
      {:noreply, socket}
    end
  end

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
