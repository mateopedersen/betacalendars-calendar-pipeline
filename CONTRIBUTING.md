# Contributing

1. Install Elixir 1.18 or newer and Erlang/OTP 27 or newer.
2. Run `mix deps.get`.
3. Run `mix format`, `mix test`, `mix credo --strict`, `mix dialyzer`, and `mix docs`.
4. Add regression tests for behavior changes and keep the core free of network calls and application-global state.

Pull requests should explain the behavior change and include test coverage. Avoid adding runtime dependencies unless the core cannot reasonably remain dependency-free.
