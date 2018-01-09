defmodule ExTurn.Player do
  @type t :: %__MODULE__{id: non_neg_integer(), data: any()}
  defstruct id: nil, data: nil
end
