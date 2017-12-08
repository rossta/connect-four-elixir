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

  # def create_game(id), do: Supervisor.start_child(__MODULE__, [id])
  #
  # def current_games do
  #   Supervisor.which_children(__MODULE__)
  #   |> Enum.map(&game_data/1)
  # end
  #
  # defp game_data({_id, pid, _type, _modules}) do
  #   pid
  #   |> GenServer.call(:get_data)
  #   |> Map.take([:id])
  # end
end
