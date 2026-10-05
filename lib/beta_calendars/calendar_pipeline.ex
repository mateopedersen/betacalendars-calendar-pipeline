defmodule BetaCalendars.CalendarPipeline do
  @moduledoc """
  Deterministic lazy calendar data pipelines for Elixir and the BEAM.

  The core is pure and has no production dependencies. It produces ordinary
  structs and maps suitable for Phoenix assigns, static generation, and export.
  """

  alias BetaCalendars.CalendarPipeline.{Compiler, MonthMatrix, Stream, Validator, YearMonth}

  @doc "Creates an inclusive lazy stream of months."
  @spec month_stream(YearMonth.t() | tuple() | String.t(), YearMonth.t() | tuple() | String.t()) ::
          Enumerable.t()
  def month_stream(from, to),
    do: Stream.months(Stream.normalize_month!(from), Stream.normalize_month!(to))

  @doc "Creates an unbounded lazy forward stream of months."
  @spec stream_from(YearMonth.t() | tuple() | String.t()) :: Enumerable.t()
  def stream_from(from), do: from |> Stream.normalize_month!() |> Stream.from()

  @doc "Creates a lazy stream from `from:` and `to:` keyword options."
  @spec stream(keyword()) :: Enumerable.t()
  def stream(opts), do: Stream.range(opts)

  @doc "Compiles one month using the selected week start and grid mode."
  @spec compile(YearMonth.t() | tuple() | String.t(), keyword()) :: MonthMatrix.t()
  def compile(month, opts \\ []),
    do: Compiler.compile_month(month, opts)

  @doc "Returns the matrix unchanged when valid, raising on invariant violations."
  @spec validate!(MonthMatrix.t()) :: MonthMatrix.t()
  def validate!(matrix), do: Validator.validate!(matrix)
end
