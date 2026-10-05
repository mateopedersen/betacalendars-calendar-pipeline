# Getting Started

Add `{:betacalendars_calendar_pipeline, "~> 0.1.0"}` to your dependencies and fetch packages with `mix deps.get`.

```elixir
alias BetaCalendars.CalendarPipeline
alias BetaCalendars.CalendarPipeline.YearMonth

{:ok, month} = YearMonth.new(2027, 1)
calendar = CalendarPipeline.compile(month, week_start: :monday)
calendar.rows
```

Invalid year-month values return tagged errors from `new/2`; use `new!/2` when invalid input should raise. Dates are represented by `Date` because the model is a civil calendar rather than a timestamp.
