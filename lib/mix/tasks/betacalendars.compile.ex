defmodule Mix.Tasks.Betacalendars.Compile do
  @moduledoc "Compiles a range of months and prints inspectable calendar data."
  use Mix.Task

  alias BetaCalendars.CalendarPipeline.Compiler

  @shortdoc "Compile a calendar month range"

  @impl Mix.Task
  def run(args) do
    {opts, [], _invalid} =
      OptionParser.parse(args,
        strict: [
          from: :string,
          to: :string,
          week_start: :string,
          fixed_weeks: :boolean,
          format: :string,
          output: :string
        ]
      )

    from = Keyword.fetch!(opts, :from)
    to = Keyword.fetch!(opts, :to)
    week_start = opts |> Keyword.get(:week_start, "monday") |> parse_week_start!()
    mode = if Keyword.get(opts, :fixed_weeks, false), do: :fixed_six_weeks, else: :natural

    matrices =
      Compiler.compile_range(from, to,
        week_start: week_start,
        mode: mode
      )

    rendered = render(matrices, Keyword.get(opts, :format, "inspect"))

    case Keyword.get(opts, :output) do
      nil -> IO.puts(rendered)
      path -> File.write!(path, rendered <> "\n")
    end
  end

  defp parse_week_start!(value) do
    case value do
      "monday" -> :monday
      "tuesday" -> :tuesday
      "wednesday" -> :wednesday
      "thursday" -> :thursday
      "friday" -> :friday
      "saturday" -> :saturday
      "sunday" -> :sunday
      _ -> Mix.raise("--week-start must be a weekday name")
    end
  end

  defp render(matrices, "inspect"), do: inspect(matrices, pretty: true, limit: :infinity)

  defp render(matrices, "map"),
    do:
      inspect(Enum.map(matrices, &Compiler.to_map/1),
        pretty: true,
        limit: :infinity
      )

  defp render(_matrices, format),
    do: Mix.raise("unsupported --format #{inspect(format)}; use inspect or map")
end
