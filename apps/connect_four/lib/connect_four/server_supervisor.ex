defmodule ConnectFour.ServerSupervisor do
  use DynamicSupervisor

  require Logger

  alias ConnectFour

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, nil, name: :game_server_supervisor)
  end

  def start_child(game_id) do
    Logger.debug "Starting game dynamic server supervisor for game #{game_id}"

    DynamicSupervisor.start_child(:game_server_supervisor, {ConnectFour.Server, game_id})
  end

  def terminate_child(game_server_pid) do
    DynamicSupervisor.terminate_child(:game_server_supervisor, game_server_pid)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
