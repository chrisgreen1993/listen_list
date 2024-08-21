defmodule ListenListWeb.ReleaseLive.Index do
  use ListenListWeb, :live_view

  alias ListenList.Releases
  alias ListenList.Subscribers
  alias ListenList.Utils.Time

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       selected_period: :week,
       release: nil,
       subscribe_modal?: false
     )
     |> stream_configure(:releases, dom_id: &"releases-#{&1.period_end}")}
  end

  def paginate_release_periods(socket, start_date, reset_stream \\ false) do
    %{
      start_date: current_start_date,
      selected_period: period,
      max_periods: max_periods,
      max_per_period: max_per_period
    } = socket.assigns

    releases =
      Releases.list_top_releases_grouped_by_period(start_date, period,
        max_per_period: max_per_period,
        max_periods: max_periods
      )

    #  Number of release periods the stream keeps around in the DOM
    stream_limit = max_periods * 3

    {releases, at, limit} =
      if DateTime.compare(current_start_date, start_date) in [:gt, :eq] do
        {releases, -1, stream_limit * -1}
      else
        {Enum.reverse(releases), 0, stream_limit}
      end

    at_start? =
      DateTime.compare(start_date, Time.end_of_release_period(DateTime.utc_now(), period)) == :eq

    case releases do
      [] ->
        assign(socket, end_of_releases?: at == -1, start_of_releases?: at_start?)

      [_ | _] = releases ->
        socket
        |> assign(end_of_releases?: false, start_date: start_date, start_of_releases?: at_start?)
        |> stream(:releases, releases, at: at, limit: limit, reset: reset_stream)
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    period = Map.get(params, "period", "week") |> String.to_atom()
    start_date = Time.end_of_release_period(DateTime.utc_now(), period)

    max_per_period =
      case period do
        :week -> 5
        :month -> 5
        :year -> 10
      end

    {:noreply,
     socket
     |> assign(
       selected_period: period,
       start_date: start_date,
       max_periods: 5,
       max_per_period: max_per_period
     )
     #  We reset the stream when the period changes, as all the data is new
     |> paginate_release_periods(start_date, true)}
  end

  @impl true
  def handle_event("next_periods", _, socket) do
    %{start_date: start_date, selected_period: period, max_periods: max_periods} = socket.assigns
    next_start_date = Timex.shift(start_date, [{String.to_atom("#{period}s"), -max_periods}])

    {:noreply,
     socket
     |> paginate_release_periods(next_start_date)}
  end

  def handle_event("prev_periods", _, socket) do
    %{start_date: start_date, selected_period: period, max_periods: max_periods} = socket.assigns
    prev_start_date = Timex.shift(start_date, [{String.to_atom("#{period}s"), max_periods}])

    {:noreply,
     socket
     |> paginate_release_periods(prev_start_date)}
  end

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
