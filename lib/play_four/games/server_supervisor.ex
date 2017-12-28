defmodule PlayFour.Games.ServerSupervisor do
  use Supervisor

  alias PlayFour.Games

  def start_link do
    Supervisor.start_link(__MODULE__, nil, name: :game_server_supervisor)
  end

  def start_child(game_id) do
    Supervisor.start_child(:game_server_supervisor, [game_id])
  end

  def terminate_child(game_server_pid) do
    Supervisor.terminate_child(:game_server_supervisor, game_server_pid)
  end

  def init(_) do
    children = [
      worker(Games.Server, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
