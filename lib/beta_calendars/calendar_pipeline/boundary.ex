defmodule BetaCalendars.CalendarPipeline.Boundary.Window do
  @moduledoc "Derived calendar characteristics for an inclusive month interval."
  @enforce_keys [
    :months,
    :years,
    :month_transitions,
    :quarter_transitions,
    :year_transitions,
    :crosses_year?,
    :crosses_quarter?,
    :shortest_month,
    :february_months,
    :leap_years,
    :week_layout_changes,
    :week_start
  ]
  defstruct [
    :months,
    :years,
    :month_transitions,
    :quarter_transitions,
    :year_transitions,
    :crosses_year?,
    :crosses_quarter?,
    :shortest_month,
    :february_months,
    :leap_years,
    :week_layout_changes,
    :week_start
  ]

  @typedoc "Computed month-range boundaries and grid-layout changes."
  @type t :: %__MODULE__{
          months: [BetaCalendars.CalendarPipeline.YearMonth.t()],
          years: [integer()],
          month_transitions: [map()],
          quarter_transitions: [map()],
          year_transitions: [map()],
          crosses_year?: boolean(),
          crosses_quarter?: boolean(),
          shortest_month: BetaCalendars.CalendarPipeline.YearMonth.t() | nil,
          february_months: [BetaCalendars.CalendarPipeline.YearMonth.t()],
          leap_years: [integer()],
          week_layout_changes: [map()],
          week_start: BetaCalendars.CalendarPipeline.WeekStart.t()
        }
end

defmodule BetaCalendars.CalendarPipeline.Boundary do
  @moduledoc "Analyzes month, quarter, year, February, leap-year, and grid boundaries."

  alias BetaCalendars.CalendarPipeline.{Boundary.Window, Stream, WeekStart, YearMonth}

  @doc "Analyzes an inclusive month range without fixture-specific assumptions."
  @spec window(keyword()) :: Window.t()
  def window(opts) do
    from = opts |> Keyword.fetch!(:from) |> Stream.normalize_month!()
    to = opts |> Keyword.fetch!(:to) |> Stream.normalize_month!()
    week_start = Keyword.get(opts, :week_start, :monday)
    unless WeekStart.valid?(week_start), do: raise(ArgumentError, "invalid week_start")
    months = Enum.to_list(Stream.months(from, to))
    adjacent = Enum.chunk_every(months, 2, 1, :discard)
    years = months |> Enum.map(& &1.year) |> Enum.uniq()

    month_transitions = Enum.map(adjacent, fn [a, b] -> %{from: a, to: b} end)

    quarter_transitions =
      Enum.filter(adjacent, fn [a, b] -> quarter(a.month) != quarter(b.month) end)

    year_transitions = Enum.filter(adjacent, fn [a, b] -> a.year != b.year end)

    layout_changes =
      adjacent
      |> Enum.flat_map(fn [a, b] ->
        layout_a = layout(a, week_start)
        layout_b = layout(b, week_start)

        if layout_a == layout_b,
          do: [],
          else: [%{from: a, to: b, before: layout_a, after: layout_b}]
      end)

    lengths = Enum.map(months, &{YearMonth.days_in_month(&1), &1})

    shortest =
      case Enum.min_by(lengths, &elem(&1, 0), fn -> nil end) do
        nil -> nil
        {_days, month} -> month
      end

    quarters_crossed = length(Enum.uniq_by(months, &{&1.year, quarter(&1.month)})) > 1

    %Window{
      months: months,
      years: years,
      month_transitions: month_transitions,
      quarter_transitions: Enum.map(quarter_transitions, fn [a, b] -> %{from: a, to: b} end),
      year_transitions: Enum.map(year_transitions, fn [a, b] -> %{from: a, to: b} end),
      crosses_year?: length(years) > 1,
      crosses_quarter?: quarters_crossed,
      shortest_month: shortest,
      february_months: Enum.filter(months, &(&1.month == 2)),
      leap_years:
        months
        |> Enum.filter(&(&1.month == 2 and Calendar.ISO.leap_year?(&1.year)))
        |> Enum.map(& &1.year)
        |> Enum.uniq(),
      week_layout_changes: layout_changes,
      week_start: week_start
    }
  end

  defp quarter(month), do: div(month - 1, 3) + 1

  defp layout(month, week_start) do
    {WeekStart.leading_cells(YearMonth.first_date(month), week_start),
     div(
       WeekStart.leading_cells(YearMonth.first_date(month), week_start) +
         YearMonth.days_in_month(month) + 6,
       7
     )}
  end
end
