defmodule ConnectFour.Games.Cache do
  use GenServer
  require Logger

  alias ConnectFour.Games

  def start_link do
    Logger.info "Starting game cache."

    GenServer.start_link(__MODULE__, nil, name: :game_cache)
  end

  def game_server(game_id) do
    case Games.Server.whereis(game_id) do
      :undefined ->
        {:error, "Game #{game_id} does not exist."}

      game_server ->
        {:ok, game_server}
    end
  end

  def start_game_server(game_id) do
    case Games.Server.whereis(game_id) do
      :undefined ->
        GenServer.call(:game_cache, {:start_game_server, game_id})

      game_server ->
        {:ok, game_server}
    end
  end

  def handle_call({:start_game_server, game_id}, _, state) do
    game_server = case Games.Server.whereis(game_id) do
      :undefined ->
        {:ok, new_pid} = Games.ServerSupervisor.start_child(game_id)
        new_pid

      pid ->
        pid
    end

    {:reply, {:ok, game_server}, state}
  end
end
