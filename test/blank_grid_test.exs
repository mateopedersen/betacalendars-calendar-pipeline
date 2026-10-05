defmodule BetaCalendars.CalendarPipeline.BlankGridTest do
  use ExUnit.Case, async: true

  alias BetaCalendars.CalendarPipeline.BlankGrid

  test "creates undated six-week grid and ordered weekday headings" do
    grid = BlankGrid.new(rows: 6, columns: 7, week_start: :sunday)
    assert length(grid.cells) == 42

    assert grid.weekday_headers == [
             :sunday,
             :monday,
             :tuesday,
             :wednesday,
             :thursday,
             :friday,
             :saturday
           ]

    assert Enum.all?(grid.cells, fn cell -> is_nil(Map.get(cell, :date)) end)
    assert Enum.uniq_by(grid.cells, &{&1.row, &1.column}) == grid.cells
  end

  test "custom columns do not imply weekday names" do
    assert BlankGrid.new(rows: 5, columns: 10).weekday_headers == nil
  end
end
