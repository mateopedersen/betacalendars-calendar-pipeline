defmodule BetaCalendars.CalendarPipeline.YearMonthTest do
  use ExUnit.Case, async: true

  alias BetaCalendars.CalendarPipeline.YearMonth

  test "constructs, parses, and formats values" do
    month = YearMonth.new!(2027, 1)
    assert month == %YearMonth{year: 2027, month: 1}
    assert YearMonth.parse("2027-01") == {:ok, month}
    assert YearMonth.to_string(month) == "2027-01"
    assert YearMonth.parse("2027-1") == {:error, :invalid_format}
    assert YearMonth.new(2027, 13) == {:error, :invalid_month}
  end

  test "navigation crosses civil-year boundaries and shift round-trips" do
    december = YearMonth.new!(2026, 12)
    january = YearMonth.next(december)
    assert january == YearMonth.new!(2027, 1)
    assert YearMonth.previous(january) == december
    assert YearMonth.shift(january, -14) == YearMonth.new!(2025, 11)
    assert YearMonth.shift(YearMonth.shift(january, 37), -37) == january
  end

  test "leap-year rules follow the Gregorian calendar" do
    for {year, days} <- [{1900, 28}, {2000, 29}, {2024, 29}, {2027, 28}, {2100, 28}, {2400, 29}] do
      assert YearMonth.days_in_month(YearMonth.new!(year, 2)) == days
    end
  end
end
