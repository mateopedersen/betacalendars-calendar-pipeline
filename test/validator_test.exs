defmodule BetaCalendars.CalendarPipeline.ValidatorTest do
  use ExUnit.Case, async: true

  alias BetaCalendars.CalendarPipeline.{MonthMatrix, Validator, YearMonth}

  test "validates compiler output" do
    matrix = MonthMatrix.compile(YearMonth.new!(2027, 1))
    assert Validator.validate(matrix) == []
    assert Validator.validate!(matrix) == matrix
  end

  test "reports structured coordinate and duplicate-date errors" do
    matrix = MonthMatrix.compile(YearMonth.new!(2027, 1))
    first = hd(matrix.cells)
    altered = %{matrix | cells: [%{first | row: 9}, first | tl(matrix.cells)]}
    diagnostics = Validator.validate(altered)
    assert Enum.any?(diagnostics, &(&1.code == :invalid_row and &1.coordinate == {0, 0}))
    assert Enum.any?(diagnostics, &(&1.code == :duplicate_date and &1.date == first.date))
  end
end
