defmodule ConnectFour.Games.Server do
  use GenServer
  require Logger

  alias ConnectFour.Games.Game

  def start_link(game_id) do
    Logger.info "Starting game server."

    GenServer.start_link(__MODULE__, game_id, name: via_tuple(game_id))
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

  def status(game_server) do
    GenServer.call(game_server, :status)
  end

  # Server

  def handle_call({:join, player_id, channel_pid}, _from, game) do
    cond do
      game.red != nil and game.black != nil ->
        {:reply, {:error, "Already two players playing"}, game}

      Enum.member?([game.red, game.black], player_id) ->
        {:reply, {:ok, self()}, game}

      true ->
        Process.flag(:trap_exit, true)
        Process.monitor(channel_pid)

        game = Game.add_player(game, player_id)
        {:reply, {:ok, self()}, game}
    end
  end

  def handle_call(:status, _from, game) do
    {:reply, game, game}
  end

  defp via_tuple(id), do: {:via, Registry, {:game_server_registry, id}}
end
