defmodule ListenList.Utils.TimeTest do
  use ExUnit.Case
  alias ListenList.Utils.Time
  alias Timex

  describe "end_of_release_period/2" do
    test "returns the start of the next week" do
      date_time = ~U[2024-08-06T00:00:00Z]
      end_date = Time.end_of_release_period(date_time, :week)

      assert end_date == ~U[2024-08-08T00:00:00Z]
    end

    test "returns the start of the next month" do
      date_time = ~U[2024-01-06T00:00:00Z]
      end_date = Time.end_of_release_period(date_time, :month)

      assert end_date == ~U[2024-02-01T00:00:00Z]
    end

    test "returns the start of the next year" do
      date_time = ~U[2024-01-06T00:00:00Z]
      end_date = Time.end_of_release_period(date_time, :year)

      assert end_date == ~U[2025-01-01T00:00:00Z]
    end
  end

  describe "past_intervals_for_period/4" do
    test "generates correct periods for weeks" do
      start_date_time = ~U[2022-01-06T00:00:00Z]
      periods = Time.past_intervals_for_period(start_date_time, :week, 2)

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
      start_date_time = ~U[2022-02-01T00:00:00Z]
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
      start_date_time = ~U[2023-01-01T00:00:00Z]
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
end
