defmodule ConnectFour.Server do
  use GenServer
  require Logger

  alias ConnectFour.Game

  def start_link(game_id) do
    Logger.debug("Starting game server.")

    GenServer.start_link(__MODULE__, game_id, name: via_tuple(game_id))
  end

  def child_spec(game_id) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [game_id]},
      type: :worker,
      restart: :permanent
    }
  end

  def init(game_id) do
    {:ok, %Game{id: game_id}}
  end

  def whereis(game_id) do
    case Registry.lookup(:game_server_registry, game_id) do
      [] ->
        :undefined

      [{pid, _}] ->
        pid
    end
  end

  # Client

  def join(game_server, player_id, channel_pid) do
    GenServer.call(game_server, {:join, player_id, channel_pid})
  end

  def game(game_server), do: GenServer.call(game_server, :game)

  def move(game_server, player_id, column) do
    GenServer.call(game_server, {:move, player_id, column})
  end

  def next_player(game_server) do
    GenServer.call(game_server, :next_player)
  end

  # Server

  def handle_call({:join, player_id, channel_pid}, _from, game) do
    cond do
      player_id != nil && Enum.member?([game.red, game.black], player_id) ->
        {:reply, {:ok, game}, game}

      game.red != nil and game.black != nil ->
        {:reply, {:fail, game}, game}

      true ->
        Process.flag(:trap_exit, true)
        Process.monitor(channel_pid)

        game = Game.add_player(game, player_id)
        {:reply, {:ok, game}, game}
    end
  end

  def handle_call(:game, _from, game), do: {:reply, game, game}

  def handle_call({:move, player_id, column}, _from, game) do
    case Game.move(game, player_id, column) do
      {:ok, new_game} ->
        {:reply, {:ok, new_game}, new_game}

      not_ok ->
        {:reply, not_ok, game}
    end
  end

  def handle_call(:next_player, _from, game) do
    {:reply, Game.next_player(game), game}
  end

  def handle_info({:DOWN, _ref, :process, _pid, _info} = message, game) do
    Logger.info("Handling disconnected ref in Game #{game.id}")
    Logger.info("#{inspect(message)}")

    # {:stop, :normal, game}
    {:noreply, game}
  end

  defp via_tuple(id), do: {:via, Registry, {:game_server_registry, id}}
end
