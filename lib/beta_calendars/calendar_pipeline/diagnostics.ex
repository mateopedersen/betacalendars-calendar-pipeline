defmodule BetaCalendars.CalendarPipeline.Diagnostics.Diagnostic do
  @moduledoc "A structured validation finding."
  @enforce_keys [:code, :severity, :message]
  defstruct [:code, :severity, :date, :coordinate, :message]

  @typedoc "An actionable validation diagnostic."
  @type t :: %__MODULE__{
          code: atom(),
          severity: :error | :warning,
          date: Date.t() | nil,
          coordinate: {non_neg_integer(), non_neg_integer()} | nil,
          message: String.t()
        }
end

defmodule BetaCalendars.CalendarPipeline.Diagnostics do
  @moduledoc "Helpers for constructing structured matrix diagnostics."

  alias BetaCalendars.CalendarPipeline.Diagnostics.Diagnostic

  @doc "Creates a diagnostic with optional date and matrix coordinate."
  @spec new(atom(), String.t(), keyword()) :: Diagnostic.t()
  def new(code, message, opts \\ []) do
    %Diagnostic{
      code: code,
      severity: Keyword.get(opts, :severity, :error),
      date: Keyword.get(opts, :date),
      coordinate: Keyword.get(opts, :coordinate),
      message: message
    }
  end
end
