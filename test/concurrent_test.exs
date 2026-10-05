defmodule BetaCalendars.CalendarPipeline.ConcurrentTest do
  use ExUnit.Case, async: true

  alias BetaCalendars.CalendarPipeline.{Compiler, Concurrent}

  test "bounded concurrent results equal sequential compilation and retain order" do
    sequential = Compiler.compile_range({2026, 11}, {2027, 2})
    assert {:ok, parallel} = Concurrent.compile_range({2026, 11}, {2027, 2}, max_concurrency: 2)
    assert parallel == sequential
    assert Enum.map(parallel, & &1.month) == Enum.map(sequential, & &1.month)
  end

  test "rejects unbounded or invalid concurrency settings" do
    assert_raise ArgumentError, fn ->
      Concurrent.compile_range({2027, 1}, {2027, 2}, max_concurrency: 0)
    end
  end
end
