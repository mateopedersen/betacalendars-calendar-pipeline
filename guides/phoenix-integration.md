# Phoenix Integration

The package returns immutable structs and has no Phoenix dependency. Build calendar data in an application context, then pass it to a LiveView or template:

```elixir
calendar = BetaCalendars.CalendarPipeline.compile({2027, 1})
assign(socket, :calendar, calendar)
```

In a template, iterate over `MonthMatrix.to_rows(calendar)` and use each cell's `current_month?`, `date`, and coordinate fields to render state. Keep localization, markup, and user preferences in the application layer.
