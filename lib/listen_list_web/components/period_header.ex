defmodule ListenListWeb.Components.PeriodHeader do
  use Phoenix.Component

  attr :period, :string
  attr :period_start_date, :string
  attr :period_end_date, :string
  attr :last_period?, :boolean

  def period_header(assigns) do
    ~H"""
    <div class="flex justify-between align-baseline flex-col sm:flex-row py-8">
      <h2 id={@period_end_date} class="font-bold text-xl md:text-3xl">
        <%= humanize_releases_period_date(@period_start_date, @period_end_date, @period) %>
      </h2>
      <%= if @last_period? do %>
        <a class="pt-2 sm:pt-0 text-blue-500 font-bold underline text-xl md:text-2xl" href="#">
          Back to top ↑
        </a>
      <% else %>
        <a
          class="pt-2 sm:pt-0 text-blue-500 font-bold underline text-xl md:text-2xl"
          href={"##{@period_start_date}"}
        >
          Previous <%= @period %> ↓
        </a>
      <% end %>
    </div>
    """
  end

  defp humanize_releases_period_date(start_date, end_date, period) do
    latest_period? = Date.compare(Date.utc_today(), end_date) == :lt

    formatted_date =
      case [period, latest_period?] do
        [_period, true] ->
          "this " <> Atom.to_string(period)

        [:week, false] ->
          # The period starts on Thursday to catch releases due to timezones etc, but we want to display as Friday.
          friday = Timex.shift(start_date, days: 1)
          "for " <> Calendar.strftime(friday, "%A %d %b, %Y")

        [:month, false] ->
          "for " <> Calendar.strftime(start_date, "%B %Y")

        [:year, false] ->
          "for " <> Calendar.strftime(start_date, "%Y")
      end

    "Top releases #{formatted_date}"
  end
end
