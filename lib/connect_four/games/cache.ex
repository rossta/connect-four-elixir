defmodule ConnectFour.Games.Cache do
  use GenServer
  require Logger

  alias ConnectFour.Games

  def start_link do
    Logger.info "Starting game cache."

    GenServer.start_link(__MODULE__, nil, name: :game_cache)
  end

  def init(_) do
    {:ok, Map.new}
  end

  def game_server(game_id) do
    GenServer.call(:game_cache, {:game_server, game_id})
  end

  def start_game_server(game_id) do
    GenServer.call(:game_cache, {:start_game_server, game_id})
  end

  def handle_call({:game_server, game_id}, _, game_servers) do
    case Map.fetch(game_servers, game_id) do
      {:ok, game_server} ->
        {:reply, game_server, game_servers}

      :error ->
        {:error, "Game does not exist"}
    end
  end

  def handle_call({:start_game_server, game_id}, _, game_servers) do
    {:ok, new_server} = Games.Server.start_link(game_id)

    {:reply, new_server, Map.put(game_servers, game_id, new_server)}
  end
end
