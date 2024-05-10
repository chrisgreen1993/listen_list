defmodule ListenList.Utils.Time do
  defp beginning_of_period(date_time, period, week_start) do
    case period do
      :week -> Timex.beginning_of_week(date_time, week_start)
      :month -> Timex.beginning_of_month(date_time)
      :year -> Timex.beginning_of_year(date_time)
    end
  end

  # Generate a list of past intervals for a period (:week, :month, :year)
  # starting from the given start_date_time.
  # The week start day can be specified as a string atom (:sunday, :monday, etc.).
  def past_intervals_for_period(start_date_time, period, num_periods, week_start \\ nil) do
    shift_unit = String.to_atom("#{period}s")

    Enum.map(0..(num_periods - 1), fn i ->
      start_date =
        Timex.shift(
          start_date_time,
          [{shift_unit, -i}]
        )
        |> beginning_of_period(period, week_start)

      end_date = Timex.shift(start_date, [{shift_unit, 1}])
      %{start_date: start_date, end_date: end_date}
    end)
  end

  # Checks whether a date is in this week, month, year
  def date_in_latest_period?(start_date, period, week_start, now \\ DateTime.utc_now()) do
    period_start_today = beginning_of_period(now, period, week_start)

    DateTime.compare(period_start_today, start_date) ==
      :eq
  end
end
