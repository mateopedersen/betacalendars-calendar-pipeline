alias BetaCalendars.CalendarPipeline

CalendarPipeline.month_stream({2026, 11}, {2027, 2})
|> Stream.map(&BetaCalendars.CalendarPipeline.Compiler.compile_month/1)
|> Enum.each(&IO.puts(BetaCalendars.CalendarPipeline.YearMonth.to_string(&1.month)))
