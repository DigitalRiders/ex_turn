defmodule Exturn.GameTest do
  use ExUnit.Case

  alias ExTurn.{Game, Player}

  test "can add unique players until it reach the max permitted" do
    game = start_game()

    assert :ok = Game.add_player(game, player1())
    assert {:error, :player_already_added} == Game.add_player(game, player1())
    assert :ok = Game.add_player(game, player2())
    assert {:error, :too_many_players, 2} = Game.add_player(game, player3())
  end

  test "play succeed if it's player turn and action is valid" do
    game = start_game_with_players()

    assert :ok = Game.move(game, player1(), place(1, 1))
    assert :ok = Game.move(game, player2(), place(2, 1))
  end

  test "play fails if it's not player turn" do
    game = start_game_with_players()

    assert {:error, :not_your_turn} == Game.move(game, player2(), place(1, 1))

    assert :ok = Game.move(game, player1(), place(1, 1))

    assert {:error, :not_your_turn} == Game.move(game, player1(), place(1, 2))
  end

  test "play fails if action is not valid turn" do
    game = start_game_with_players()

    assert {:error, :invalid_action} = Game.move(game, player1(), place(1, 3))

    assert {:error, :invalid_action} = Game.move(game, player1(), {:invalid_action, 1, 1})
  end

  test "can check if game is finished and get a winner" do
    game = start_game_with_players()

    assert :ok = Game.move(game, player1(), place(0, 1))
    assert :ok = Game.move(game, player2(), place(0, 2))
    assert :ok = Game.move(game, player1(), place(1, 1))
    assert :ok = Game.move(game, player2(), place(2, 2))
    assert :playing == Game.state(game)

    assert :ok = Game.move(game, player1(), place(2, 1))

    assert {:winner, player1()} == Game.state(game)
  end

  defp place(n, m) do
    TicTacToe.place(n, m)
  end

  defp start_game do
    {:ok, game} = Game.start_link(TicTacToe)
    game
  end

  defp start_game_with_players do
    game = start_game()
    :ok = Game.add_player(game, player1())
    :ok = Game.add_player(game, player2())
    game
  end

  defp player1, do: %Player{id: 1}
  defp player2, do: %Player{id: 2}
  defp player3, do: %Player{id: 3}
end
