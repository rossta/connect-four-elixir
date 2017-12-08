defmodule ConnectFourWeb.GameView do
  use ConnectFourWeb, :view
  alias ConnectFourWeb.GameView

  def render("index.json", %{games: games}) do
    render_many(games, GameView, "game.json")
  end

  def render("show.json", %{game: game}) do
    render_one(game, GameView, "game.json")
  end

  def render("game.json", %{game: game}) do
    %{id: game.id}
  end
end
