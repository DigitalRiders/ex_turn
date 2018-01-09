defmodule ExTurn.GameSupervisor do
  @moduledoc false
  use Supervisor

  def child_spec(game_module, opts) do
    %{
      id: ExTurn.GameSupervisor,
      restart: :permanent,
      start: {ExTurn.GameSupervisor, :start_link, [game_module, opts]},
      type: :supervisor
    }
  end

  def start_link(game_module, opts) do
    name = Keyword.fetch!(opts, :name)
    Supervisor.start_link(__MODULE__, game_module, name: name)
  end

  def init(game_module) do
    game_spec =
      Supervisor.child_spec(ExTurn.Game, start: {ExTurn.Game, :start_link, [game_module]})

    Supervisor.init([game_spec], strategy: :simple_one_for_one)
  end
end
