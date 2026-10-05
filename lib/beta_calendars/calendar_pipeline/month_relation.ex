defmodule BetaCalendars.CalendarPipeline.MonthRelation do
  @moduledoc "Classifies a date relative to a target calendar month."

  alias BetaCalendars.CalendarPipeline.YearMonth

  @type t :: :previous | :current | :next

  @doc "Returns `:previous`, `:current`, or `:next` for a date and month."
  @spec for_date(Date.t(), YearMonth.t()) :: t()
  def for_date(%Date{year: year, month: month}, %YearMonth{year: year, month: month}),
    do: :current

  def for_date(%Date{year: year, month: month}, %YearMonth{} = target) do
    date_index = year * 12 + month
    target_index = target.year * 12 + target.month
    if date_index < target_index, do: :previous, else: :next
  end
end
