defmodule BetaCalendars.CalendarPipeline.MonthMatrix do
  @moduledoc "Compiles a civil month into a weekday-aligned, immutable matrix."

  alias BetaCalendars.CalendarPipeline.{DayCell, MonthRelation, WeekStart, YearMonth}

  @enforce_keys [:month, :week_start, :mode, :rows, :cells]
  defstruct [:month, :week_start, :mode, :rows, :cells]

  @typedoc "A complete week-aligned month grid. Rows and columns are zero-based coordinates."
  @type t :: %__MODULE__{
          month: YearMonth.t(),
          week_start: WeekStart.t(),
          mode: :natural | :fixed_six_weeks,
          rows: pos_integer(),
          cells: [DayCell.t()]
        }

  @doc "Compiles a month using `:natural` rows or exactly six weeks."
  @spec compile(YearMonth.t(), keyword()) :: t()
  def compile(%YearMonth{} = month, opts \\ []) do
    week_start = Keyword.get(opts, :week_start, :monday)
    mode = Keyword.get(opts, :mode, :natural)
    unless WeekStart.valid?(week_start), do: raise(ArgumentError, "invalid week_start")
    unless mode in [:natural, :fixed_six_weeks], do: raise(ArgumentError, "invalid mode")

    first = YearMonth.first_date(month)
    leading = WeekStart.leading_cells(first, week_start)
    day_count = YearMonth.days_in_month(month)
    rows = if mode == :fixed_six_weeks, do: 6, else: div(leading + day_count + 6, 7)
    grid_start = Date.add(first, -leading)

    cells =
      for offset <- 0..(rows * 7 - 1) do
        date = Date.add(grid_start, offset)
        row = div(offset, 7)
        column = rem(offset, 7)
        relation = MonthRelation.for_date(date, month)

        %DayCell{
          date: date,
          day: date.day,
          row: row,
          column: column,
          weekday: Date.day_of_week(date),
          month_relation: relation,
          current_month?: relation == :current
        }
      end

    %__MODULE__{month: month, week_start: week_start, mode: mode, rows: rows, cells: cells}
  end

  @doc "Returns the matrix as a list of row lists."
  @spec to_rows(t()) :: [[DayCell.t()]]
  def to_rows(%__MODULE__{rows: rows, cells: cells}) do
    for row <- 0..(rows - 1), do: Enum.slice(cells, row * 7, 7)
  end
end
