# Engineering a Year-Boundary Window: November 2026–February 2027

This interval exercises several distinct calendar behaviors in a compact, reviewable example: a 30-day month, a 31-day year-end month, a civil year rollover, and a 28-day February. It is useful for validating pipelines that generate one calendar at a time but aggregate several months for a page, export, or background job.

## Derive the window

```elixir
alias BetaCalendars.CalendarPipeline
alias BetaCalendars.CalendarPipeline.Boundary

months = CalendarPipeline.month_stream({2026, 11}, {2027, 2}) |> Enum.to_list()
window = Boundary.window(from: {2026, 11}, to: {2027, 2}, week_start: :monday)
```

November has 30 days. Its natural matrix includes the leading and trailing dates needed to complete whole weeks. December has 31 days and its final week continues into January 2027. The month stream itself advances by civil month, so the year increment happens exactly once between December and January without timestamp or time-zone logic.

January 2027 has 31 days. Its neighboring cells identify December 2026 as `:previous` and February 2027 as `:next`. February 2027 has 28 days because 2027 is not a leap year; its next-month cells belong to March. The leap-year decision is delegated to Elixir's Gregorian calendar implementation rather than being hard-coded in the window.

## Grid and pipeline behavior

Week-start options change the leading-cell count and can change the natural row count. The dates remain the same; only their columns and the natural window around the target month change. Fixed mode always carries six complete weeks (42 cells), regardless of the natural row count.

Sequential and concurrent batch compilation should contain the same month matrices in the same chronological order when `ordered: true`. Concurrency is bounded by `max_concurrency`; it does not change date values or relation labels. The range API is inclusive at both ends.

## Supporting calendar references

These pages provide readable examples of the corresponding civil months:

- [November 2026 calendar reference](https://www.betacalendars.com/november-calendar.html)
- [December 2026 calendar reference](https://www.betacalendars.com/december-calendar.html)
- [January 2027 calendar reference](https://www.betacalendars.com/january-calendar.html)
- [February 2027 calendar reference](https://www.betacalendars.com/february-calendar.html)
