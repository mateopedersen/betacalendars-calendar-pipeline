# Boundary Windows

`Boundary.window/1` derives a window summary from an inclusive month interval:

```elixir
window = BetaCalendars.CalendarPipeline.Boundary.window(
  from: {2026, 11}, to: {2027, 2}, week_start: :monday
)
window.crosses_year?
window.year_transitions
window.week_layout_changes
```

The result includes the months and years present, adjacent month transitions, quarter and year transitions, shortest month, February months, leap years, and changes in the natural grid signature `{leading_cells, row_count}`. The summary is calculated from calendar dates and does not encode a specific fixture.
