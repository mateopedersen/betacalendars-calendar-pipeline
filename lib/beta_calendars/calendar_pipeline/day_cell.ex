defmodule BetaCalendars.CalendarPipeline.DayCell do
  @moduledoc "A dated cell in a compiled month matrix."

  @enforce_keys [:date, :day, :row, :column, :weekday, :month_relation, :current_month?]
  defstruct [:date, :day, :row, :column, :weekday, :month_relation, :current_month?]

  @typedoc "A day cell with zero-based coordinates and its relation to the target month."
  @type t :: %__MODULE__{
          date: Date.t(),
          day: 1..31,
          row: non_neg_integer(),
          column: 0..6,
          weekday: 1..7,
          month_relation: :previous | :current | :next,
          current_month?: boolean()
        }
end
