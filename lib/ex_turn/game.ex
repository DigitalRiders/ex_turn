defmodule ExTurn.Game do
  defstruct module: nil, players: [], state: nil

  def info(module), do: module.info

  def init(module, players) do
    if module.info.players == Enum.count(players) do
      module.init(players)
    else
      {:error, :expected_players, module.info.players}
    end
  end

  def play(game, action) do
    game.module.play(game, action)
  end

  @callback info() :: Game.Info.t()
  @callback init([Game.Player.t()]) :: {:ok, Game.t()} | {:error, atom, any}
  @callback play(Game.t(), Game.Action.t()) :: {:ok, Game.t()} | {:error, atom, any}
end
