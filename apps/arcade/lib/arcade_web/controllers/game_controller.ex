defmodule ArcadeWeb.GameController do
  use ArcadeWeb, :controller

  alias Arcade.Games

  action_fallback ArcadeWeb.FallbackController

  def index(conn, %{}) do
    text conn, "ok"
  end

  def create(conn, %{}) do
    with {:ok, %ConnectFour.Game{} = game} <- Games.create_game() do
      # Arcade.Endpoint.broadcast("lobby", "update_games", %{games: Games.Supervisor.current_games})

      conn
      |> put_status(:created)
      |> put_resp_header("location", game_path(conn, :show, game))
      |> render("show.json", game: game)
    end
  end
end
