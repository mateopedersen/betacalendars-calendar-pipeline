defmodule BetaCalendars.CalendarPipeline.BoundaryTest do
  use ExUnit.Case, async: true

  alias BetaCalendars.CalendarPipeline.{Boundary, YearMonth}

  test "derives the November 2026 through February 2027 boundary window" do
    window = Boundary.window(from: {2026, 11}, to: {2027, 2})
    assert length(window.months) == 4
    assert window.crosses_year?
    assert window.crosses_quarter?
    assert length(window.year_transitions) == 1
    assert window.shortest_month == YearMonth.new!(2027, 2)
    assert window.february_months == [YearMonth.new!(2027, 2)]
    assert window.leap_years == []
    assert window.week_start == :monday
  end

  test "leap years are derived only when February is in the interval" do
    window = Boundary.window(from: {2024, 2}, to: {2024, 3})
    assert window.leap_years == [2024]
  end
end
