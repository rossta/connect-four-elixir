defmodule ConnectFour.Client do
  require Logger

  alias ConnectFour.{Server, ServerSupervisor}

  def server(game_id) do
    case Server.whereis(game_id) do
      :undefined ->
        {:error, "Game #{game_id} does not exist."}

      game_server ->
        {:ok, game_server}
    end
  end

  def start_game(game_id) do
    {:ok, pid} = start_server(game_id)
    {:ok, Server.game(pid)}
  end

  def start_server(game_id) do
    case ServerSupervisor.start_child(game_id) do
      {:ok, pid} ->
        {:ok, pid}
      {:error, {:already_started, pid}} ->
        {:ok, pid}
    end
  end

  def join_game(game_id, player_id, pid) do
    {:ok, game_server} = server(game_id)
    join = Server.join(game_server, player_id, pid)
    case join do
      {:ok, _} -> Process.monitor(game_server)
      {:fail, _} -> true
    end
    join
  end

  def fetch_game(game_id) do
    {:ok, game_server} = server(game_id)
    Server.game(game_server)
  end

  def move(game_id, player_id, col) do
   {:ok, game_server} = server(game_id)
   Server.move(game_server, player_id, col)
  end

  def next_player(game_id) do
   {:ok, game_server} = server(game_id)
   Server.next_player(game_server)
  end

  def stop_server(game_id) do
    game_id |> server |> handle_stop_server
  end

  defp handle_stop_server({:error, _reason}), do: :ok
  defp handle_stop_server(:ok), do: :ok
  defp handle_stop_server({:ok, game_server}) do
    ServerSupervisor.terminate_child(game_server)
    |> handle_stop_server
  end
end
