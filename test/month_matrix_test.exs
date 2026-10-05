defmodule BetaCalendars.CalendarPipeline.MonthMatrixTest do
  use ExUnit.Case, async: true

  alias BetaCalendars.CalendarPipeline.{MonthMatrix, WeekStart, YearMonth}

  test "November 2026 supports Monday and Sunday layouts" do
    month = YearMonth.new!(2026, 11)
    monday = MonthMatrix.compile(month, week_start: :monday)
    sunday = MonthMatrix.compile(month, week_start: :sunday)
    assert YearMonth.days_in_month(month) == 30
    assert Date.day_of_week(YearMonth.first_date(month)) == 7
    assert Date.day_of_week(YearMonth.last_date(month)) == 1
    assert monday.rows == 6
    assert sunday.rows == 5
    assert hd(monday.cells).date == ~D[2026-10-26]
    assert hd(sunday.cells).date == ~D[2026-11-01]
    assert Enum.count(monday.cells, & &1.current_month?) == 30
  end

  test "fixed mode has 42 cells and current-month dates appear once" do
    for month <- [
          YearMonth.new!(2026, 11),
          YearMonth.new!(2026, 12),
          YearMonth.new!(2027, 1),
          YearMonth.new!(2027, 2)
        ] do
      matrix = MonthMatrix.compile(month, mode: :fixed_six_weeks)
      assert matrix.rows == 6
      assert length(matrix.cells) == 42
      assert Enum.count(matrix.cells, & &1.current_month?) == YearMonth.days_in_month(month)
    end
  end

  test "all seven week starts produce valid weekday columns" do
    for start <- [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday] do
      matrix = MonthMatrix.compile(YearMonth.new!(2027, 1), week_start: start)
      expected_weekdays = start |> WeekStart.days() |> Enum.map(&WeekStart.number/1)
      assert WeekStart.valid?(matrix.week_start)

      assert Enum.all?(MonthMatrix.to_rows(matrix), fn row ->
               length(row) == 7 and Enum.map(row, & &1.weekday) == expected_weekdays
             end)
    end
  end

  test "broad month range compiles with complete current-month coverage" do
    for year <- 1900..2100, month <- 1..12 do
      value = YearMonth.new!(year, month)
      matrix = MonthMatrix.compile(value)
      assert length(matrix.cells) == matrix.rows * 7
      assert Enum.count(matrix.cells, & &1.current_month?) == YearMonth.days_in_month(value)
    end
  end
end
