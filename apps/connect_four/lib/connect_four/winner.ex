defmodule ConnectFour.Winner do
  alias ConnectFour.Board

  require Logger

  def winner(%Board{last: nil}), do: nil
  def winner(%Board{last: last} = board) do
    column_winner(board, last) || row_winner(board, last) || diagonal_winner(board, last)
  end

  defp column_winner(_board, {row, _col, _color}) when row + 1 < 4, do: nil
  defp column_winner(_board, {_row, _col, :empty}), do: nil
  defp column_winner(board, {row, col, color} = checker) do
    column_winner(board, checker, color, [{row, col}])
  end
  defp column_winner(_board, _checker, color, moves) when length(moves) == 4, do: {color, moves}
  defp column_winner(board, {row, col, color}, color, moves) do
    column_winner(board, Board.checker(board, {row-1, col}), color, [{row-1, col} | moves])
  end
  defp column_winner(_board, _checker, _color, _moves), do: nil

  defp row_winner(_board, {_row, _col, :empty}), do: nil
  defp row_winner(board, {_row, _col, color} = checker) do
    row_winner(board, winner_start_checker(board, checker), color, [])
  end
  defp row_winner(_board, _checker, color, moves) when length(moves) == 4, do: {color, moves}
  defp row_winner(board, {row, col, color}, color, moves) do
    row_winner(board, Board.checker(board, {row, col+1}), color, [{row, col} | moves])
  end
  defp row_winner(_board, _checker, _color, _moves), do: nil

  defp diagonal_winner(_board, {_row, _col, :empty}), do: nil
  defp diagonal_winner(board, {_row, _col, color} = checker) do
    diagonal_winner(board, winner_start_checker(board, checker, -1), +1, color, [])
    || diagonal_winner(board, winner_start_checker(board, checker, +1), -1, color, [])
  end
  defp diagonal_winner(_board, _checker, _row_diff, color, moves) when length(moves) == 4, do: {color, moves}
  defp diagonal_winner(board, {row, col, color}, row_diff, color, moves) do
    diagonal_winner(board, Board.checker(board, {row+row_diff, col+1}), row_diff, color, [{row, col} | moves])
  end
  defp diagonal_winner(_board, _checker, _diff, _color, _moves), do: nil

  defp winner_start_checker(board, checker), do: winner_start_checker(board, checker, 0)
  defp winner_start_checker(board, {row, col, color}, row_diff) do
    row_left = row+row_diff
    col_left = col-1
    case Board.checker(board, {row_left, col_left}) do
      {row_left, col_left, ^color} ->
        winner_start_checker(board, {row_left, col_left, color}, row_diff)
      _ ->
        {row, col, color}
    end
  end
end
