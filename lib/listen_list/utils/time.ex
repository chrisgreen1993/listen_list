defmodule ListenList.Utils.Time do
  # We start the week on Thursday as most music is released on Fridays
  @release_day :thursday

  def end_of_release_period(date_time, period) do
    case period do
      :week -> Timex.beginning_of_week(date_time, @release_day)
      :month -> Timex.beginning_of_month(date_time)
      :year -> Timex.beginning_of_year(date_time)
    end
    |> Timex.shift([{String.to_atom("#{period}s"), 1}])
  end

  # Generate a list of past intervals for a period (:week, :month, :year)
  # starting from the given start_date_time.
  def past_intervals_for_period(start_date_time, period, num_periods) do
    shift_unit = String.to_atom("#{period}s")

    Enum.map(0..(num_periods - 1), fn i ->
      end_date = Timex.shift(start_date_time, [{shift_unit, -i}])

      start_date = Timex.shift(end_date, [{shift_unit, -1}])
      %{start_date: start_date, end_date: end_date}
    end)
  end
end
