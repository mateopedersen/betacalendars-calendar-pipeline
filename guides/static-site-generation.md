# Static Site Generation

The pure compiler fits static generators and background jobs. A date-bearing matrix remains ordinary Elixir data; use `Compiler.to_map/1` when an exporter expects maps and ISO date strings:

```elixir
matrix = BetaCalendars.CalendarPipeline.Compiler.compile_month({2027, 1})
payload = BetaCalendars.CalendarPipeline.Compiler.to_map(matrix)
```

The library deliberately leaves JSON encoding and file persistence to the consuming application. This avoids a runtime JSON dependency and keeps file-system effects outside the calendar core.
