defmodule BetaCalendars.CalendarPipeline.Compiler do
  @moduledoc "Compiles month values and ranges into plain serializable Elixir data."

  alias BetaCalendars.CalendarPipeline.{MonthMatrix, Stream, Validator, YearMonth}

  @doc "Compiles one month, validating it before returning the matrix."
  @spec compile_month(YearMonth.t() | {integer(), integer()} | String.t(), keyword()) ::
          MonthMatrix.t()
  def compile_month(month, opts \\ []) do
    month
    |> Stream.normalize_month!()
    |> MonthMatrix.compile(opts)
    |> Validator.validate!()
  end

  @doc "Compiles an inclusive month range into a list of month matrices."
  @spec compile_range(
          YearMonth.t() | tuple() | String.t(),
          YearMonth.t() | tuple() | String.t(),
          keyword()
        ) :: [MonthMatrix.t()]
  def compile_range(from, to, opts \\ []) do
    from = Stream.normalize_month!(from)
    to = Stream.normalize_month!(to)
    opts = Keyword.take(opts, [:week_start, :mode])
    Enum.map(Stream.months(from, to), &compile_month(&1, opts))
  end

  @doc "Converts a month matrix into JSON-friendly maps with ISO date strings."
  @spec to_map(MonthMatrix.t()) :: map()
  def to_map(%MonthMatrix{} = matrix) do
    %{
      month: YearMonth.to_string(matrix.month),
      week_start: matrix.week_start,
      mode: matrix.mode,
      rows: matrix.rows,
      cells:
        Enum.map(matrix.cells, fn cell ->
          %{
            date: Date.to_iso8601(cell.date),
            day: cell.day,
            row: cell.row,
            column: cell.column,
            weekday: cell.weekday,
            month_relation: cell.month_relation,
            current_month?: cell.current_month?
          }
        end)
    }
  end
end
