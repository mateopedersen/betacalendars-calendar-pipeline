defmodule BetaCalendars.CalendarPipeline.YearMonth do
  @moduledoc "An immutable year-and-month value for proleptic Gregorian calendars."

  @enforce_keys [:year, :month]
  defstruct [:year, :month]

  @typedoc "A valid civil year and month."
  @type t :: %__MODULE__{year: pos_integer(), month: 1..12}

  @doc "Builds a year-month value, returning an error for an invalid month."
  @spec new(integer(), integer()) :: {:ok, t()} | {:error, :invalid_year | :invalid_month}
  def new(year, _month) when not is_integer(year) or year < 1,
    do: {:error, :invalid_year}

  def new(_year, month) when not is_integer(month) or month < 1 or month > 12,
    do: {:error, :invalid_month}

  def new(year, month), do: {:ok, %__MODULE__{year: year, month: month}}

  @doc "Builds a year-month value or raises `ArgumentError`."
  @spec new!(integer(), integer()) :: t()
  def new!(year, month) do
    case new(year, month) do
      {:ok, value} -> value
      {:error, reason} -> raise ArgumentError, "invalid year-month: #{inspect(reason)}"
    end
  end

  @doc "Parses a zero-padded `YYYY-MM` string."
  @spec parse(String.t()) ::
          {:ok, t()} | {:error, :invalid_format | :invalid_year | :invalid_month}
  def parse(value) when is_binary(value) do
    case Regex.run(~r/^(\d{4,})-(\d{2})$/, value) do
      [_, year, month] -> new(String.to_integer(year), String.to_integer(month))
      _ -> {:error, :invalid_format}
    end
  end

  def parse(_value), do: {:error, :invalid_format}

  @doc "Formats a value as zero-padded `YYYY-MM`."
  @spec to_string(t()) :: String.t()
  def to_string(%__MODULE__{year: year, month: month}),
    do:
      "#{year |> Integer.to_string() |> String.pad_leading(4, "0")}-#{month |> Integer.to_string() |> String.pad_leading(2, "0")}"

  @doc "Returns the following calendar month."
  @spec next(t()) :: t()
  def next(month), do: shift(month, 1)

  @doc "Returns the preceding calendar month."
  @spec previous(t()) :: t()
  def previous(month), do: shift(month, -1)

  @doc "Shifts a month by a signed number of months."
  @spec shift(t(), integer()) :: t()
  def shift(%__MODULE__{year: year, month: month}, amount) when is_integer(amount) do
    index = year * 12 + month - 1 + amount
    shifted_year = Integer.floor_div(index, 12)
    shifted_month = Integer.mod(index, 12) + 1
    new!(shifted_year, shifted_month)
  end

  @doc "Returns the number of days in the month."
  @spec days_in_month(t()) :: pos_integer()
  def days_in_month(%__MODULE__{} = month), do: month |> first_date() |> Date.days_in_month()

  @doc "Returns the first date of the month."
  @spec first_date(t()) :: Date.t()
  def first_date(%__MODULE__{year: year, month: month}), do: Date.new!(year, month, 1)

  @doc "Returns the last date of the month."
  @spec last_date(t()) :: Date.t()
  def last_date(%__MODULE__{year: year, month: month}),
    do: Date.new!(year, month, Date.days_in_month(Date.new!(year, month, 1)))
end
