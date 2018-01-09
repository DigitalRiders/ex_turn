defmodule ExTurn do
  alias ExTurn.{Player, Action}

  @moduledoc """
  Documentation for ExTurn.
  """

  @type game_id :: binary()
  @type game_state :: any()
  @type on_add_player_ret :: {:ok, game_state()} | {:error, :too_many_players, non_neg_integer}
  @type on_move_ret ::
          {:ok, game_state()}
          | {:error, :invalid_action}
          | {:error, :not_your_turn}

  @callback initial_state() :: game_state()
  @callback on_add_player(game_state(), Player.t()) :: on_add_player_ret
  @callback on_move(game_state(), Player.t(), Action.t()) :: on_move_ret

  @doc false
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour ExTurn

      def child_spec(opts) do
        %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [opts]},
          type: :supervisor
        }
      end

      def start_link() do
        Supervisor.start_link(
          [
            {Registry, [keys: :unique, name: registry()]},
            ExTurn.GameSupervisor.child_spec(__MODULE__, name: game_supervisor())
          ],
          strategy: :one_for_one,
          name: __MODULE__
        )
      end

      @spec start_game() :: {:ok, ExTurn.game_id()}
      def start_game() do
        game_id = :crypto.strong_rand_bytes(16)

        {:ok, pid} = Supervisor.start_child(game_supervisor(), [[name: game_process(game_id)]])

        {:ok, game_id}
      end

      @spec add_player(ExTurn.game_id(), Player.t()) ::
              ExTurn.on_add_player_ret() | {:error, :player_already_added}
      def add_player(game, player) do
        ExTurn.Game.add_player(game_process(game), player)
      end

      @spec players(ExTurn.game_id()) :: %{optional(non_neg_integer()) => Player.t()}
      def players(game) do
        ExTurn.Game.players(game_process(game))
      end

      @spec move(ExTurn.game_id(), Player.t(), Action.t()) ::
              ExTurn.on_move_ret() | {:error, :invalid_player}
      def move(game, player, move) do
        ExTurn.Game.move(game_process(game), player, move)
      end

      @spec state(ExTurn.game_id()) :: :playing | {:winner, Player.t()}
      def state(game) do
        ExTurn.Game.state(game_process(game))
      end

      defp game_process(name) do
        {:via, Registry, {registry(), name}}
      end

      defp registry do
        Module.concat(__MODULE__, Registry)
      end

      defp game_supervisor do
        Module.concat(__MODULE__, GameSupervisor)
      end
    end
  end
end
