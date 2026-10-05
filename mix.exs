defmodule BetaCalendars.CalendarPipeline.MixProject do
  use Mix.Project

  @version "0.1.0"
  @github_url "https://github.com/mateopedersen/betacalendars-calendar-pipeline"

  def project do
    [
      app: :betacalendars_calendar_pipeline,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: "Deterministic lazy calendar pipelines and bounded BEAM compilation.",
      package: package(),
      name: "BetaCalendars Calendar Pipeline",
      source_url: @github_url,
      homepage_url: "https://www.betacalendars.com/",
      docs: docs(),
      deps: deps(),
      dialyzer: [
        flags: [:error_handling, :underspecs, :unmatched_returns],
        plt_add_apps: [:mix]
      ]
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp deps do
    [
      {:ex_doc, "~> 0.40", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "Beta Calendars" => "https://www.betacalendars.com/",
        "GitHub" => @github_url,
        "Blank Calendar Reference" => "https://www.betacalendars.com/blank-calendar"
      },
      files: ["lib", "mix.exs", "README.md", "LICENSE", "CHANGELOG.md", "guides"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md",
        "LICENSE",
        "CHANGELOG.md",
        "guides/getting-started.md",
        "guides/lazy-month-streams.md",
        "guides/concurrent-compilation.md",
        "guides/boundary-windows.md",
        "guides/blank-grids.md",
        "guides/phoenix-integration.md",
        "guides/static-site-generation.md",
        "guides/year-boundary-2026-2027.md"
      ],
      groups_for_extras: [
        "Getting Started": ["README.md", "guides/getting-started.md"],
        "Core Concepts": [
          "guides/lazy-month-streams.md",
          "guides/boundary-windows.md",
          "guides/blank-grids.md",
          "guides/year-boundary-2026-2027.md"
        ],
        "BEAM and Integrations": [
          "guides/concurrent-compilation.md",
          "guides/phoenix-integration.md",
          "guides/static-site-generation.md"
        ],
        Project: ["LICENSE", "CHANGELOG.md"]
      ],
      groups_for_modules: [
        "Calendar data": [
          BetaCalendars.CalendarPipeline.YearMonth,
          BetaCalendars.CalendarPipeline.MonthMatrix,
          BetaCalendars.CalendarPipeline.DayCell
        ],
        "Pipelines and analysis": [
          BetaCalendars.CalendarPipeline.Stream,
          BetaCalendars.CalendarPipeline.Boundary,
          BetaCalendars.CalendarPipeline.Compiler
        ],
        "Validation and layout": [
          BetaCalendars.CalendarPipeline.Validator,
          BetaCalendars.CalendarPipeline.Diagnostics,
          BetaCalendars.CalendarPipeline.BlankGrid
        ],
        Concurrency: [BetaCalendars.CalendarPipeline.Concurrent]
      ]
    ]
  end
end
