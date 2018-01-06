defmodule Joshua do
  @moduledoc """
  Documentation for Joshua.
  """
  alias Joshua.Minimax
  alias ConnectFour.Board

  def pick_move(%Board{} = board, color)do
    {{_row, col, _color}, _score} = Minimax.minimax(board, _depth = 3)

    {col, color}
  end
end
