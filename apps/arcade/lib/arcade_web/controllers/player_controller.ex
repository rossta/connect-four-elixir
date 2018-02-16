defmodule ArcadeWeb.PlayerController do
  use ArcadeWeb, :controller

  alias Arcade.Games

  action_fallback(ArcadeWeb.FallbackController)

  def create(conn, %{}) do
    with {:ok, %ConnectFour.Player{} = player} <- Games.create_player() do
      conn
      |> put_status(:created)
      |> put_resp_header("location", player_path(conn, :show, player))
      |> render("show.json", player: player)
    end
  end
end
