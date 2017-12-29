defmodule ConnectFour.Winner do
  alias ConnectFour.Board

  def winner(%Board{last: nil}), do: nil
  def winner(%Board{last: last} = board) do
    column_winner(board, last) || row_winner(board, last) || diagonal_winner(board, last)
  end

  defp column_winner(_board, {row, _col, _color}) when row + 1 < 4, do: nil
  defp column_winner(_board, {_row, _col, :empty}), do: nil
  defp column_winner(board, {_row, _col, color} = checker) do
    column_winner(board, checker, color, 1)
  end
  defp column_winner(_board, {_, _, color}, color, 4), do: color
  defp column_winner(board, {row, col, color} , color, count) do
    column_winner(board, Board.checker(board, {row-1, col}), color, count+1)
  end
  defp column_winner(_board, _checker, _color, _count), do: nil

  defp row_winner(_board, {_row, _col, :empty}), do: nil
  defp row_winner(board, {_row, _col, color} = checker) do
    row_winner(board, winner_start_checker(board, checker, 0), color, 1)
  end
  defp row_winner(_board, {_, _, color}, color, 4), do: color
  defp row_winner(board, {row, col, color}, color, count) do
    row_winner(board, Board.checker(board, {row, col+1}), color, count+1)
  end
  defp row_winner(_board, _checker, _color, _count), do: nil

  defp diagonal_winner(_board, {_row, _col, :empty}), do: nil
  defp diagonal_winner(board, {_row, _col, color} = checker) do
    diagonal_winner(board, winner_start_checker(board, checker, -1), +1, color, 1)
    || diagonal_winner(board, winner_start_checker(board, checker, +1), -1, color, 1)
  end
  defp diagonal_winner(_board, {_, _, color}, _row_diff, color, 4), do: color
  defp diagonal_winner(board, {row, col, color}, row_diff, color, count) do
    diagonal_winner(board, Board.checker(board, {row+row_diff, col+1}), row_diff, color, count+1)
  end
  defp diagonal_winner(_board, _checker, _diff, _color, _count), do: nil

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
