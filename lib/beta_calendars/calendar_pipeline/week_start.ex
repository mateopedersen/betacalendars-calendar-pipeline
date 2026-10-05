defmodule BetaCalendars.CalendarPipeline.WeekStart do
  @moduledoc "Validated weekday ordering helpers for month layouts."

  @days [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]
  @type t :: :monday | :tuesday | :wednesday | :thursday | :friday | :saturday | :sunday

  @doc "Returns the ISO weekday number for a supported week-start atom."
  @spec number(t()) :: 1..7
  def number(day) when day in @days, do: Enum.find_index(@days, &(&1 == day)) + 1

  @doc "Returns whether a value is one of the seven supported week starts."
  @spec valid?(term()) :: boolean()
  def valid?(day), do: day in @days

  @doc "Returns weekday names in display order for the requested week start."
  @spec days(t()) :: [t()]
  def days(start) when start in @days do
    offset = number(start) - 1
    Enum.drop(@days, offset) ++ Enum.take(@days, offset)
  end

  @doc false
  @spec leading_cells(Date.t(), t()) :: 0..6
  def leading_cells(date, start), do: Integer.mod(Date.day_of_week(date) - number(start), 7)
end
