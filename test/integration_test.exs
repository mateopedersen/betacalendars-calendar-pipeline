defmodule BetaCalendars.CalendarPipeline.IntegrationTest do
  use ExUnit.Case, async: true

  alias BetaCalendars.CalendarPipeline.{Compiler, YearMonth}

  test "compiler output is JSON-friendly and serializable as ordinary terms" do
    matrix = Compiler.compile_month(YearMonth.new!(2027, 1))
    payload = Compiler.to_map(matrix)
    assert payload.month == "2027-01"
    assert Enum.any?(payload.cells, &(&1.date == "2027-01-01"))
    assert :erlang.term_to_binary(payload) |> is_binary()
  end
end
