defmodule ConnectFour.Games.Supervisor do
  use Supervisor

  alias ConnectFour.{Games}

  def start_link, do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    children = [
      worker(Registry, [[keys: :unique, name: :game_server_registry]]),
      supervisor(Games.ServerSupervisor, []),
      worker(Games.Cache, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
