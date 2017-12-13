defmodule ConnectFour.Games.Cache do
  require Logger

  alias ConnectFour.Games

  def server(game_id) do
    case Games.Server.whereis(game_id) do
      :undefined ->
        {:error, "Game #{game_id} does not exist."}

      game_server ->
        {:ok, game_server}
    end
  end

  def start_server(game_id) do
    case Games.ServerSupervisor.start_child(game_id) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        {:ok, pid}
    end
  end
end
