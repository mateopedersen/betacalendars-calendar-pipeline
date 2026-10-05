{:ok, matrices} =
  BetaCalendars.CalendarPipeline.Concurrent.compile_range(
    {2027, 1},
    {2027, 12},
    max_concurrency: System.schedulers_online()
  )

IO.puts("compiled #{length(matrices)} months")
