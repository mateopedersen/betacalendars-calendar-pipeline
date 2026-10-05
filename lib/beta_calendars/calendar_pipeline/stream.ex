defmodule BetaCalendars.CalendarPipeline.Stream do
  @moduledoc "Lazy, inclusive streams over calendar months."

  alias BetaCalendars.CalendarPipeline.YearMonth

  @doc "Creates a lazy inclusive stream from `from` through `to`; reversed ranges are empty."
  @spec months(YearMonth.t(), YearMonth.t()) :: Enumerable.t()
  def months(%YearMonth{} = from, %YearMonth{} = to) do
    Stream.resource(
      fn -> month_index(from) end,
      fn index ->
        last = month_index(to)

        if index > last do
          {:halt, index}
        else
          {[%YearMonth{year: div(index, 12), month: rem(index, 12) + 1}], index + 1}
        end
      end,
      fn _index -> :ok end
    )
  end

  @doc "Creates a lazy, unbounded forward stream starting at `from`."
  @spec from(YearMonth.t()) :: Enumerable.t()
  def from(%YearMonth{} = from) do
    Stream.unfold(from, fn month -> {month, YearMonth.next(month)} end)
  end

  @doc "Creates a range stream from keyword options `from:` and `to:`."
  @spec range(keyword()) :: Enumerable.t()
  def range(opts) do
    from = opts |> Keyword.fetch!(:from) |> normalize_month!()
    to = opts |> Keyword.fetch!(:to) |> normalize_month!()
    months(from, to)
  end

  @doc false
  @spec normalize_month!(YearMonth.t() | {integer(), integer()} | String.t()) :: YearMonth.t()
  def normalize_month!(%YearMonth{} = month), do: month
  def normalize_month!({year, month}), do: YearMonth.new!(year, month)

  def normalize_month!(value) when is_binary(value) do
    case YearMonth.parse(value) do
      {:ok, month} -> month
      {:error, reason} -> raise ArgumentError, "invalid month string: #{inspect(reason)}"
    end
  end

  defp month_index(%YearMonth{year: year, month: month}), do: year * 12 + month - 1
end
