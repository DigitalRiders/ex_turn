defmodule Exturn.GameTest do
  use ExUnit.Case

  alias ExTurn.Game

  defmodule TicTacToe do
    @behaviour Game

    defstruct board: %{}, current_player: :circles, players: %{}

    def info() do
      %Game.Info{name: "TicTacToe", players: 2}
    end

    def init([player1, player2]) do
      state = %TicTacToe{players: %{player1 => :circles, player2 => :crosses}}

      {:ok, %Game{module: TicTacToe, players: [player1, player2], state: state}}
    end

    def play(%{state: state} = game, %{player: player, action: {:place, n, m}})
        when n < 3 and n >= 0 and m < 3 and m >= 0 do
      case Map.fetch(state.board, {n, m}) do
        {:ok, val} ->
          {:error, :already_placed, {n, m}}

        :error ->
          if state.players[player] == state.current_player do
            new_board = Map.put(state.board, {n, m}, state.current_player)

            new_state = %{
              state
              | board: new_board,
                current_player: next_player(state.current_player)
            }

            {:ok, %{game | state: new_state}}
          else
            {:error, :not_your_turn, player}
          end
      end
    end

    def play(_state, action) do
      {:error, :invalid_action, action}
    end

    defp next_player(:circles), do: :crosses
    defp next_player(:crosses), do: :circles
  end

  test "info returns info" do
    assert Game.info(TicTacToe) == %Game.Info{name: "TicTacToe", players: 2}
  end

  test "init succeeds with required number of players" do
    assert {:ok, %Game{}} = Game.init(TicTacToe, [1, 2])
  end

  test "init fails when number of players is incorrect" do
    assert {:error, :expected_players, 2} = Game.init(TicTacToe, [1])
    assert {:error, :expected_players, 2} = Game.init(TicTacToe, [1, 2, 3])
  end

  test "play succeed if it's player turn and action is valid" do
    {:ok, game} = Game.init(TicTacToe, [1, 2])

    assert {:ok, new_game} = Game.play(game, %Game.Action{player: 1, action: {:place, 1, 1}})

    assert {:ok, other_new_game} =
             Game.play(new_game, %Game.Action{player: 2, action: {:place, 2, 1}})
  end

  test "play fails if it's not player turn" do
    {:ok, game} = Game.init(TicTacToe, [1, 2])

    assert {:error, :not_your_turn, 2} =
             Game.play(game, %Game.Action{player: 2, action: {:place, 1, 1}})

    assert {:ok, new_game} = Game.play(game, %Game.Action{player: 1, action: {:place, 1, 1}})

    assert {:error, :not_your_turn, 1} =
             Game.play(new_game, %Game.Action{player: 1, action: {:place, 1, 2}})
  end

  test "play fails if action is not valid turn" do
    {:ok, game} = Game.init(TicTacToe, [1, 2])

    assert {:error, :invalid_action, _action} =
             Game.play(game, %Game.Action{player: 1, action: {:place, 1, 3}})

    assert {:error, :invalid_action, _action} =
             Game.play(game, %Game.Action{player: 1, action: {:invalid_action, 1, 1}})
  end
end
