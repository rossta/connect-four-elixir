defmodule PlayFourWeb.PlayerController do
  use PlayFourWeb, :controller

  alias PlayFour.Games
  alias PlayFour.Games.Player

  action_fallback PlayFourWeb.FallbackController

  def create(conn, %{}) do
    with {:ok, %Player{} = player} <- Games.create_player() do
      conn
      |> put_status(:created)
      |> put_resp_header("location", player_path(conn, :show, player))
      |> render("show.json", player: player)
    end
  end

  # def index(conn, _params) do
  #   players = Games.list_players()
  #   render(conn, "index.json", players: players)
  # end

  # def show(conn, %{"id" => id}) do
  #   player = Games.get_player!(id)
  #   render(conn, "show.json", player: player)
  # end
  #
  # def update(conn, %{"id" => id, "player" => player_params}) do
  #   player = Games.get_player!(id)
  #
  #   with {:ok, %Player{} = player} <- Games.update_player(player, player_params) do
  #     render(conn, "show.json", player: player)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   player = Games.get_player!(id)
  #   with {:ok, %Player{}} <- Games.delete_player(player) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
