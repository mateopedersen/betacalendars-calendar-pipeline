# Lazy Month Streams

`CalendarPipeline.month_stream/2` returns a lazy inclusive stream. It produces a month only when downstream enumeration requests one:

```elixir
CalendarPipeline.month_stream({2026, 11}, {2027, 2})
|> Stream.map(&BetaCalendars.CalendarPipeline.Compiler.compile_month/1)
|> Enum.to_list()
```

For demand-limited processing, `stream_from/1` produces a forward stream that can be consumed with `Stream.take/2`. The finite civil date domain can be consumed in bounded slices. Each yielded value is a `YearMonth` struct; tuples and `YYYY-MM` strings are accepted at API boundaries for convenience.

Streams compose with standard `Enum` and `Stream` functions. No custom `Enumerable` implementation is required.
