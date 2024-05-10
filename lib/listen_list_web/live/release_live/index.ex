defmodule ListenListWeb.ReleaseLive.Index do
  use ListenListWeb, :live_view

  alias ListenList.Music
  alias ListenList.Utils.Time

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       releases: Music.list_top_releases(:week),
       selected_period: :week
     )}
  end

  @impl true
  def handle_event("change_period", %{"period" => period}, socket) do
    releases = Music.list_top_releases(String.to_atom(period))
    {:noreply, assign(socket, releases: releases, selected_period: String.to_atom(period))}
  end

  def humanize_releases_period_date(start_date, period) do
    is_latest_period = Time.date_in_latest_period?(start_date, period, :thursday)

    formatted_date =
      case [period, is_latest_period] do
        [_period, true] ->
          "this " <> Atom.to_string(period)

        [:week, false] ->
          # The period starts on Thursday to catch releases due to timezones etc, but we want to display as Friday.
          friday = Timex.shift(start_date, days: 1)
          "for " <> Calendar.strftime(friday, "%A %B %d, %Y")

        [:month, false] ->
          "for " <> Calendar.strftime(start_date, "%B %Y")

        [:year, false] ->
          "for " <> Calendar.strftime(start_date, "%Y")
      end

    "Top releases #{formatted_date}"
  end
end
