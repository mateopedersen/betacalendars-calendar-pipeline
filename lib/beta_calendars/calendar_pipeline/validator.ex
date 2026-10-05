defmodule BetaCalendars.CalendarPipeline.Validator do
  @moduledoc "Checks structural and date invariants for month matrices."

  alias BetaCalendars.CalendarPipeline.{Diagnostics, MonthMatrix, MonthRelation, YearMonth}

  @doc "Returns all invariant violations found in a matrix."
  @spec validate(MonthMatrix.t()) :: [Diagnostics.Diagnostic.t()]
  def validate(%MonthMatrix{} = matrix) do
    expected_cells = matrix.rows * 7

    count_errors =
      if length(matrix.cells) == expected_cells and
           (matrix.mode != :fixed_six_weeks or expected_cells == 42) do
        []
      else
        [
          Diagnostics.new(
            :incorrect_cell_count,
            "matrix cell count does not match its dimensions"
          )
        ]
      end

    {coordinate_errors, dates} =
      matrix.cells
      |> Enum.with_index()
      |> Enum.reduce({[], []}, fn {cell, index}, {errors, seen} ->
        row = div(index, 7)
        column = rem(index, 7)
        coordinate = {row, column}
        expected_weekday = Date.day_of_week(cell.date)
        expected_relation = MonthRelation.for_date(cell.date, matrix.month)

        errors =
          errors
          |> maybe_error(
            cell.row != row,
            :invalid_row,
            "cell row is inconsistent",
            cell,
            coordinate
          )
          |> maybe_error(
            cell.column != column,
            :invalid_column,
            "cell column is inconsistent",
            cell,
            coordinate
          )
          |> maybe_error(
            cell.weekday != expected_weekday,
            :weekday_mismatch,
            "weekday does not match date",
            cell,
            coordinate
          )
          |> maybe_error(
            cell.month_relation != expected_relation,
            :invalid_relation,
            "month relation does not match date",
            cell,
            coordinate
          )
          |> maybe_error(
            cell.current_month? != (expected_relation == :current),
            :invalid_relation,
            "current_month? does not match date",
            cell,
            coordinate
          )

        duplicate? = cell.date in seen

        errors =
          maybe_error(
            errors,
            duplicate?,
            :duplicate_date,
            "date occurs more than once",
            cell,
            coordinate
          )

        {errors, [cell.date | seen]}
      end)

    target_dates =
      Enum.filter(dates, &(&1.year == matrix.month.year and &1.month == matrix.month.month))

    expected_dates =
      1..YearMonth.days_in_month(matrix.month)
      |> Enum.map(&Date.new!(matrix.month.year, matrix.month.month, &1))

    missing_errors =
      expected_dates
      |> Enum.reject(&(&1 in target_dates))
      |> Enum.map(
        &Diagnostics.new(:missing_date, "target month is missing #{Date.to_iso8601(&1)}",
          date: &1
        )
      )

    count_errors ++ Enum.reverse(coordinate_errors) ++ missing_errors
  end

  @doc "Raises `ArgumentError` with structured violations when validation fails."
  @spec validate!(MonthMatrix.t()) :: MonthMatrix.t()
  def validate!(%MonthMatrix{} = matrix) do
    case validate(matrix) do
      [] -> matrix
      diagnostics -> raise ArgumentError, "invalid month matrix: #{inspect(diagnostics)}"
    end
  end

  defp maybe_error(errors, false, _code, _message, _cell, _coordinate), do: errors

  defp maybe_error(errors, true, code, message, cell, coordinate),
    do: [Diagnostics.new(code, message, date: cell.date, coordinate: coordinate) | errors]
end
