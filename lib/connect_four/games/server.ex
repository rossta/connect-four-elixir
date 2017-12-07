defmodule ConnectFour.Games.Server do
  use GenServer
  require Logger

  alias ConnectFour.Games.Game

  # Client

  def join(game_server, player_id, channel_pid) do
    GenServer.call(game_server, {:join, player_id, channel_pid})
  end

  def status(game_server) do
    GenServer.call(game_server, :status)
  end

  # Server

  def start_link(game_id) do
    GenServer.start_link(__MODULE__, game_id, name: ref(game_id))
  end

  def init(id) do
    {:ok, %Game{id: id}}
  end

  def handle_call({:join, player_id, channel_pid}, _from, game) do
    cond do
      game.red != nil and game.black != nil ->
        {:reply, {:error, "Already two players playing"}, game}

      Enum.member?([game.red, game.black], player_id) ->
        {:reply, {:ok, self}, game}

      true ->
        Process.flag(:trap_exit, true)
        Process.monitor(channel_pid)

        game = Game.add_player(game, player_id)
        {:reply, {:ok, self}, game}
    end
  end

  def handle_call(:status, _from, game) do
    {:reply, game, game}
  end

  defp ref(id), do: {:global, {:game, id}}

  def whereis(id) do
    case GenServer.whereis(ref(id)) do
      nil ->
        {:error, "Game does not exist"}
      pid ->
        {:ok, pid}
    end
  end
end
