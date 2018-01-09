defmodule TicTacToe do
  use ExTurn

  alias ExTurn.Action

  defstruct board: %{}, current_player: :circles, players: %{}

  def initial_state do
    %TicTacToe{}
  end

  def on_add_player(%__MODULE__{players: players} = state, player) do
    case Map.keys(players) do
      [] -> {:ok, %{state | players: %{circles: player.id}}}
      [:circles] -> {:ok, %{state | players: Map.put(players, :crosses, player.id)}}
      [:circles, :crosses] -> {:error, :too_many_players, 2}
    end
  end

  def on_move(%__MODULE__{} = state, player, %Action{name: "place", params: [n, m]})
      when n < 3 and n >= 0 and m < 3 and m >= 0 do
    case Map.fetch(state.board, {n, m}) do
      {:ok, _val} ->
        {:error, :invalid_action}

      :error ->
        if state.players[state.current_player] == player.id do
          new_board = Map.put(state.board, {n, m}, state.current_player)

          new_state = %{
            state
            | board: new_board,
              current_player: next_player(state.current_player)
          }

          {:ok, new_state}
        else
          {:error, :not_your_turn}
        end
    end
  end

  def on_move(%__MODULE__{}, _player, _action) do
    {:error, :invalid_action}
  end

  def on_state(%__MODULE__{board: board} = state) do
    winners =
      lines()
      |> Enum.flat_map(fn line ->
           case winner_in_line(board, line) do
             :none -> []
             other -> [other]
           end
         end)
      |> Enum.uniq()

    case winners do
      [shape] -> {:winner, state.players[shape]}
      [] -> :playing
    end
  end

  defp winner_in_line(board, line) do
    case Map.take(board, line) |> Map.values() do
      [:crosses, :crosses, :crosses] -> :crosses
      [:circles, :circles, :circles] -> :circles
      _ -> :none
    end
  end

  defp lines do
    [
      [{0, 0}, {0, 1}, {0, 2}],
      [{1, 0}, {1, 1}, {1, 2}],
      [{2, 0}, {2, 1}, {2, 2}],
      [{0, 0}, {1, 0}, {2, 0}],
      [{0, 1}, {1, 1}, {2, 1}],
      [{0, 2}, {1, 2}, {2, 2}],
      [{0, 0}, {1, 1}, {2, 2}],
      [{0, 2}, {1, 1}, {0, 2}]
    ]
  end

  def place(n, m) do
    %Action{name: "place", params: [n, m]}
  end

  defp next_player(:circles), do: :crosses
  defp next_player(:crosses), do: :circles
end
