defmodule ConnectFour.Winner do
  alias ConnectFour.{Board, Winner}

  @down {-1, 0}
  @right {0, +1}
  @down_right {-1, +1}
  @rise_right {+1, +1}

  defstruct [
    moves: [],
    color: :empty,
  ]

  require Logger

  def winner(%Board{last: nil}), do: nil
  def winner(%Board{last: last} = board), do: winner(board, last)
  def winner(_board, {_row, _col, :empty}), do: nil
  def winner(%Board{} = board, checker) do
    column_winner(board, checker) || row_winner(board, checker) || diagonal_winner(board, checker)
  end

  def to_tuple(%Winner{color: color, moves: moves}), do: {color, moves}

  defp column_winner(_board, {row, _col, _color}) when row + 1 < 4, do: nil
  defp column_winner(board, {_row, _col, _color} = checker) do
    collect_winner(board, checker, @down)
  end

  defp row_winner(board, {_row, _col, _color} = checker) do
    collect_winner(board, checker, @right)
  end

  defp diagonal_winner(board, {_row, _col, _color} = checker) do
    collect_winner(board, checker, @rise_right) || collect_winner(board, checker, @down_right)
  end

  defp collect_winner(board, {_row, _col, color} = checker, delta) do
    first_checker = winner_start_checker(board, checker, inverse_delta(delta))

    %Winner{color: color}
    |> collect_winner(board, first_checker, delta)
  end
  defp collect_winner(%Winner{moves: moves, color: color} = winner, _board, _checker, _delta) when length(moves) == 4, do: winner
  defp collect_winner(%Winner{color: color} = winner, board, {row, col, color}, delta) do
    next_checker = Board.checker(board, delta_move({row, col}, delta))

    %Winner{winner | moves: [{row, col} | winner.moves]}
    |> collect_winner(board, next_checker, delta)
  end
  defp collect_winner(_winner, _board, _checker, _delta), do: nil

  defp winner_start_checker(board, {row, col, color}, delta) do
    {row_left, col_left} = delta_move({row, col}, delta)
    case Board.checker(board, {row_left, col_left}) do
      {row_left, col_left, ^color} ->
        winner_start_checker(board, {row_left, col_left, color}, delta)
      _ ->
        {row, col, color}
    end
  end

  defp inverse_delta({row_diff, col_diff}), do: {row_diff * -1, col_diff * -1}
  defp delta_move({row, col}, {row_diff, col_diff}), do: {row+row_diff, col+col_diff}
end
