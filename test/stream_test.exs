defmodule BetaCalendars.CalendarPipeline.StreamTest do
  use ExUnit.Case, async: true

  alias BetaCalendars.CalendarPipeline
  alias BetaCalendars.CalendarPipeline.YearMonth

  test "range stream is lazy, inclusive, and crosses the new year" do
    stream = CalendarPipeline.month_stream({2026, 11}, {2027, 2})
    assert is_function(stream)

    assert Enum.map(stream, &YearMonth.to_string/1) == [
             "2026-11",
             "2026-12",
             "2027-01",
             "2027-02"
           ]
  end

  test "forward stream composes with take" do
    months = CalendarPipeline.stream_from({2026, 11}) |> Stream.take(5)

    assert Enum.map(months, &YearMonth.to_string/1) == [
             "2026-11",
             "2026-12",
             "2027-01",
             "2027-02",
             "2027-03"
           ]
  end

  test "reversed bounded range is empty" do
    assert CalendarPipeline.month_stream({2027, 2}, {2026, 11}) |> Enum.to_list() == []
  end
end
