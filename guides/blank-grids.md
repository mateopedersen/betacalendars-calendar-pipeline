# Blank Grids

`BlankGrid.new/1` creates an undated planning surface. Its cells contain only zero-based row and column coordinates; it does not invent placeholder dates. A seven-column grid can include weekday headings in the requested order.

```elixir
grid = BetaCalendars.CalendarPipeline.BlankGrid.new(
  rows: 6, columns: 7, week_start: :monday
)
length(grid.cells)
#=> 42
```

This structure is useful for printable planning layouts, reusable empty templates, and interfaces where a date is selected later. The grid has positive bounded dimensions, and each coordinate appears once. For a human-facing undated calendar reference, see [blank calendar layouts](https://www.betacalendars.com/blank-calendar).
