defmodule ExTurn.Game do
  alias ExTurn.{Game, Player, Action}

  use GenServer

  @type t :: %__MODULE__{
          game: atom(),
          players: %{optional(non_neg_integer()) => Player.t()},
          game_state: any()
        }
  defstruct game: nil, players: %{}, game_state: nil

  def start_link(game_module, opts \\ []) do
    GenServer.start_link(__MODULE__, game_module, opts)
  end

  def init(game_module) do
    {:ok, %__MODULE__{game: game_module, game_state: game_module.initial_state}}
  end

  def add_player(game, player) do
    GenServer.call(game, {:add_player, player})
  end

  def players(game) do
    GenServer.call(game, :players)
  end

  def move(game, player, move) do
    GenServer.call(game, {:move, player, move})
  end

  def state(game) do
    GenServer.call(game, :state)
  end

  def handle_call({:add_player, player}, _from, state) do
    if Map.has_key?(state.players, player.id) do
      {:reply, {:error, :player_already_added}, state}
    else
      case state.game.on_add_player(state.game_state, player) do
        {:ok, new_game_state} ->
          {:reply, :ok, %{
            state
            | game_state: new_game_state,
              players: Map.put(state.players, player.id, player)
          }}

        error ->
          {:reply, error, state}
      end
    end
  end

  def handle_call(:players, _from, state) do
    {:reply, state.players, state}
  end

  def handle_call({:move, player, move}, _from, state) do
    if Map.has_key?(state.players, player.id) do
      case state.game.on_move(state.game_state, player, move) do
        {:ok, new_game_state} ->
          {:reply, :ok, %{state | game_state: new_game_state}}

        error ->
          {:reply, error, state}
      end
    else
      {:reply, {:error, :invalid_player}, state}
    end
  end

  def handle_call(:state, _from, state) do
    case state.game.on_state(state.game_state) do
      {:winner, player_id} ->
        {:reply, {:winner, state.players[player_id]}, state}

      :playing ->
        {:reply, :playing, state}
    end
  end
end
