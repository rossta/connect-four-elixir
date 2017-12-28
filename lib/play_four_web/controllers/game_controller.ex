defmodule PlayFourWeb.GameController do
  use PlayFourWeb, :controller

  alias PlayFour.Games
  alias PlayFour.Games.Game

  action_fallback PlayFourWeb.FallbackController

  def index(conn, %{}) do
    text conn, "ok"
  end

  def create(conn, %{}) do
    with {:ok, %Game{} = game} <- Games.create_game() do
      # PlayFour.Endpoint.broadcast("lobby", "update_games", %{games: Games.Supervisor.current_games})

      conn
      |> put_status(:created)
      |> put_resp_header("location", game_path(conn, :show, game))
      |> render("show.json", game: game)
    end
  end

  # def index(conn, _params) do
  #   games = Games.list_games()
  #   render(conn, "index.json", games: games)
  # end

  # def show(conn, %{"id" => id}) do
  #   game = Games.get_game!(id)
  #   render(conn, "show.json", game: game)
  # end
  #
  # def update(conn, %{"id" => id, "game" => game_params}) do
  #   game = Games.get_game!(id)
  #
  #   with {:ok, %Game{} = game} <- Games.update_game(game, game_params) do
  #     render(conn, "show.json", game: game)
  #   end
  # end
  #
  # def delete(conn, %{"id" => id}) do
  #   game = Games.get_game!(id)
  #   with {:ok, %Game{}} <- Games.delete_game(game) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
