defmodule BetaCalendars.CalendarPipeline.BlankGrid.Cell do
  @moduledoc "An undated structural cell in a blank grid."
  @enforce_keys [:row, :column]
  defstruct [:row, :column]
  @typedoc "A zero-based grid coordinate with no date value."
  @type t :: %__MODULE__{row: non_neg_integer(), column: non_neg_integer()}
end

defmodule BetaCalendars.CalendarPipeline.BlankGrid do
  @moduledoc "Creates undated calendar planning grids with optional weekday headings."

  alias BetaCalendars.CalendarPipeline.{BlankGrid.Cell, WeekStart}

  @enforce_keys [:rows, :columns, :cells, :weekday_headers]
  defstruct [:rows, :columns, :cells, :weekday_headers]

  @type t :: %__MODULE__{
          rows: pos_integer(),
          columns: pos_integer(),
          cells: [Cell.t()],
          weekday_headers: [atom()] | nil
        }

  @doc "Builds a bounded blank grid. Seven-column grids receive weekday headings."
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    rows = Keyword.get(opts, :rows, 6)
    columns = Keyword.get(opts, :columns, 7)
    week_start = Keyword.get(opts, :week_start, :monday)

    unless is_integer(rows) and rows in 1..12,
      do: raise(ArgumentError, "rows must be between 1 and 12")

    unless is_integer(columns) and columns in 1..14,
      do: raise(ArgumentError, "columns must be between 1 and 14")

    unless WeekStart.valid?(week_start), do: raise(ArgumentError, "invalid week_start")

    cells =
      for row <- 0..(rows - 1), column <- 0..(columns - 1), do: %Cell{row: row, column: column}

    headers = if columns == 7, do: WeekStart.days(week_start), else: nil
    %__MODULE__{rows: rows, columns: columns, cells: cells, weekday_headers: headers}
  end
end
