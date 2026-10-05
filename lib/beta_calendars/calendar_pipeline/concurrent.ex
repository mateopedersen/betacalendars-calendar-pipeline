defmodule BetaCalendars.CalendarPipeline.Concurrent do
  @moduledoc "Bounded, ordered parallel compilation of month ranges."

  alias BetaCalendars.CalendarPipeline.{Compiler, Stream}

  @doc "Compiles a range using bounded tasks; results stay in chronological order by default."
  @spec compile_range(
          BetaCalendars.CalendarPipeline.YearMonth.t() | {integer(), integer()} | String.t(),
          BetaCalendars.CalendarPipeline.YearMonth.t() | {integer(), integer()} | String.t(),
          keyword()
        ) :: {:ok, [BetaCalendars.CalendarPipeline.MonthMatrix.t()]} | {:error, map()}
  def compile_range(from, to, opts \\ []) do
    months = Stream.months(Stream.normalize_month!(from), Stream.normalize_month!(to))
    max_concurrency = Keyword.get(opts, :max_concurrency, System.schedulers_online())
    timeout = Keyword.get(opts, :timeout, 5_000)
    ordered = Keyword.get(opts, :ordered, true)
    compile_opts = Keyword.take(opts, [:week_start, :mode])

    unless is_integer(max_concurrency) and max_concurrency > 0,
      do: raise(ArgumentError, "max_concurrency must be a positive integer")

    results =
      Task.async_stream(
        months,
        fn month -> {month, Compiler.compile_month(month, compile_opts)} end,
        max_concurrency: max_concurrency,
        timeout: timeout,
        ordered: ordered,
        on_timeout: :kill_task
      )
      |> Enum.to_list()

    case Enum.find(results, &match?({:exit, _}, &1)) do
      nil -> {:ok, Enum.map(results, fn {:ok, {_month, result}} -> result end)}
      {:exit, reason} -> {:error, %{reason: reason, ordered: ordered}}
    end
  end
end
