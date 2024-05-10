defmodule ListenList.Utils.TimeTest do
  use ExUnit.Case
  alias ListenList.Utils.Time
  alias Timex

  describe "past_intervals_for_period/4" do
    test "generates correct periods for weeks" do
      start_date_time = ~U[2022-01-01T00:00:00Z]
      periods = Time.past_intervals_for_period(start_date_time, :week, 2, :thursday)

      assert periods == [
               %{
                 start_date: ~U[2021-12-30T00:00:00Z],
                 end_date: ~U[2022-01-06T00:00:00Z]
               },
               %{
                 start_date: ~U[2021-12-23T00:00:00Z],
                 end_date: ~U[2021-12-30T00:00:00Z]
               }
             ]
    end

    test "generates correct periods for months" do
      start_date_time = ~U[2022-01-01T00:00:00Z]
      periods = Time.past_intervals_for_period(start_date_time, :month, 2)

      assert periods == [
               %{
                 start_date: ~U[2022-01-01T00:00:00Z],
                 end_date: ~U[2022-02-01T00:00:00Z]
               },
               %{
                 start_date: ~U[2021-12-01T00:00:00Z],
                 end_date: ~U[2022-01-01T00:00:00Z]
               }
             ]
    end

    test "generates correct periods for years" do
      start_date_time = ~U[2022-01-01T00:00:00Z]
      periods = Time.past_intervals_for_period(start_date_time, :year, 2)

      assert periods == [
               %{
                 start_date: ~U[2022-01-01T00:00:00Z],
                 end_date: ~U[2023-01-01T00:00:00Z]
               },
               %{
                 start_date: ~U[2021-01-01T00:00:00Z],
                 end_date: ~U[2022-01-01T00:00:00Z]
               }
             ]
    end
  end

  describe "date_in_latest_period?" do
    test "returns true when current date is within the latest period for the period" do
      now = ~U[2024-01-06T00:00:00Z]
      period_start = ~U[2024-01-04T00:00:00Z]
      assert Time.date_in_latest_period?(period_start, :week, :thursday, now)
    end

    test "returns false when current date is not within the latest period for weeks" do
      now = ~U[2024-01-06T00:00:00Z]
      period_start = ~U[2023-12-28T00:00:00Z]
      refute Time.date_in_latest_period?(period_start, :week, :thursday, now)
    end

    test "returns true when current date is within the latest period for months" do
      now = ~U[2024-01-06T00:00:00Z]
      period_start = ~U[2024-01-01T00:00:00Z]
      assert Time.date_in_latest_period?(period_start, :month, :thursday, now)
    end

    test "returns false when current date is not within the latest period for months" do
      now = ~U[2024-01-06T00:00:00Z]
      period_start = ~U[2023-12-01T00:00:00Z]
      refute Time.date_in_latest_period?(period_start, :month, :thursday, now)
    end

    test "returns true when current date is within the latest period for years" do
      now = ~U[2024-01-06T00:00:00Z]
      period_start = ~U[2024-01-01T00:00:00Z]
      assert Time.date_in_latest_period?(period_start, :year, :thursday, now)
    end

    test "returns false when current date is not within the latest period for years" do
      now = ~U[2024-01-06T00:00:00Z]
      period_start = ~U[2023-01-01T00:00:00Z]
      refute Time.date_in_latest_period?(period_start, :year, :thursday, now)
    end
  end
end
