# BetaCalendars Calendar Pipeline

Deterministic, lazy month streams and calendar matrix compilation for Elixir. The library turns civil month values into grid data, boundary analysis, and bounded concurrent batches. It has no runtime dependencies and does not contact external services.

## Why

Calendar generation is often embedded in presentation code. This package keeps the date model pure and lets Elixir applications compose lazy enumeration, validation, and bounded BEAM concurrency before passing plain data to a UI or exporter.

## Installation

```elixir
def deps do
  [
    {:betacalendars_calendar_pipeline, "~> 0.1.0"}
  ]
end
```

Then run `mix deps.get`.

## Quick Start

```elixir
alias BetaCalendars.CalendarPipeline
alias BetaCalendars.CalendarPipeline.YearMonth

month = YearMonth.new!(2027, 1)
matrix = CalendarPipeline.compile(month, week_start: :monday, mode: :fixed_six_weeks)
length(matrix.cells)
#=> 42
```

## Lazy Month Streams

```elixir
CalendarPipeline.month_stream({2026, 11}, {2027, 2})
|> Stream.map(&CalendarPipeline.compile/1)
|> Enum.to_list()

CalendarPipeline.stream_from(YearMonth.new!(2026, 11))
|> Stream.take(24)
|> Enum.to_list()
```

The range stream includes both endpoints and is lazy. The explicit `stream_from/1` form is useful with `Stream.take/2` and other demand-limited consumers.

## Month Matrices

`MonthMatrix.compile/2` supports all seven `week_start` values, `mode: :natural`, and `mode: :fixed_six_weeks`. Cells carry their `Date`, weekday, zero-based row and column, and whether they belong to the previous, current, or next month.

## Boundary Windows

`Boundary.window(from: {2026, 11}, to: {2027, 2})` derives month, quarter, year, February, leap-year, and week-layout information from the dates. It does not rely on fixed fixtures.

## Concurrent Batch Compilation

```elixir
{:ok, calendars} =
  BetaCalendars.CalendarPipeline.Concurrent.compile_range(
    {2020, 1},
    {2030, 12},
    max_concurrency: System.schedulers_online(),
    ordered: true
  )
```

Task concurrency is bounded and output is ordered by default. Timeouts and task exits return an error tuple.

## Blank Grids

`BlankGrid.new(rows: 6, columns: 7, week_start: :monday)` builds coordinate-only cells. These cells do not contain dates.

## Phoenix Integration

Compile a matrix in your context or LiveView and assign the struct:

```elixir
calendar = BetaCalendars.CalendarPipeline.compile({2027, 1})
assign(socket, :calendar, calendar)
```

Phoenix is not a dependency of this package. See the [Phoenix guide](guides/phoenix-integration.md).

## Static Site Generation

The compiler returns ordinary Elixir terms. `Compiler.to_map/1` converts a month matrix to a JSON-friendly map with ISO date strings, without requiring a JSON library.

## Validation

`Validator.validate/1` returns structured diagnostics. `Validator.validate!/1` returns the matrix when valid and raises with the diagnostic set otherwise. The compiler validates its output before returning it.

## Reference Range: November 2026 → February 2027

The engineering walkthrough uses a 30-day month, the December-to-January rollover, a new-year January, and a 28-day February. See [Year boundary 2026–2027](guides/year-boundary-2026-2027.md).

## Determinism

Calendar output depends only on the input month and options. It uses no current date, network access, telemetry, or mutable global state.

## Performance

Month streams are lazy. Range compilation is eager by design because it returns a list; use `month_stream/2` to keep downstream processing lazy. Concurrent compilation uses `Task.async_stream/3` with a bounded worker count.

## Documentation

Start with [Getting started](guides/getting-started.md), then browse the HexDocs guides for streaming, boundaries, concurrency, blank grids, and integrations.

## Project

This library is maintained alongside [Beta Calendars](https://www.betacalendars.com/). Source code and issue tracking are available on GitHub.

## Development

Run `mix test`, `mix format --check-formatted`, `mix credo --strict`, `mix dialyzer`, `mix docs`, and `mix hex.build`.

## License

MIT. See [LICENSE](LICENSE).
