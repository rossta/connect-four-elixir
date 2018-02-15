defmodule ConnectFour.Supervisor do
  def start_link, do: Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)

  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: :game_server_registry},
      ConnectFour.ServerSupervisor,
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
