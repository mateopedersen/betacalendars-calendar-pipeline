# Concurrent Compilation

`Concurrent.compile_range/3` uses `Task.async_stream/3` to compile independent months with a caller-selected concurrency ceiling. Results are chronological by default:

```elixir
{:ok, matrices} =
  BetaCalendars.CalendarPipeline.Concurrent.compile_range(
    {2026, 11}, {2027, 2}, max_concurrency: 4, timeout: 5_000
  )
```

`max_concurrency` must be positive. The default is the number of online schedulers. `timeout` applies per task and task failure returns `{:error, %{reason: reason, ordered: ordered}}`. Set `ordered: false` only when completion order is acceptable.

For short month ranges, sequential compilation may be simpler. The concurrent API exists for batching larger independent work, not as an unconditional speed guarantee.
