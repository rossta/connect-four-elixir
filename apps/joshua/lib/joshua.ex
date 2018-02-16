defmodule Joshua do
  @moduledoc """
  Documentation for Joshua.
  """
  alias Joshua.Minimax
  alias ConnectFour.{Game, Board}
  require Logger

  def pick_move(%Game{} = game, color), do: pick_move(game.board, color)

  def pick_move(%Board{} = board, color) do
    Logger.debug("pick_move #{inspect(board)}")
    {{_row, col, _color}, _score} = Minimax.minimax(board, _depth = 1)

    {col, color}
  end
end
