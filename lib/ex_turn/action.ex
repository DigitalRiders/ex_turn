defmodule ExTurn.Action do
  @type t :: %__MODULE__{name: String.t(), params: list(any())}
  defstruct name: "", params: []
end
