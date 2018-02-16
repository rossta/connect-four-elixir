defmodule Joshua.Move do
  alias ConnectFour.{Board, Game}

  def child_boards(%Board{} = board),
    do: board |> child_boards(0..board.cols |> Enum.to_list(), [])

  def child_boards(%Board{}, [], boards), do: boards

  def child_boards(%Board{last: {_row, _col, color}} = board, cols, boards) do
    child_boards(board, cols, boards, color)
  end

  def child_boards(%Board{last: nil} = board, cols, boards) do
    child_boards(board, cols, boards, :black)
  end

  def child_boards(%Board{} = board, [col | cols], boards, opponent) do
    color = Game.next_color(opponent)
    boards = Board.drop_checker(board, {col, color}) |> child_board(boards)
    child_boards(board, cols, boards)
  end

  defp child_board({:error, _}, boards), do: boards
  defp child_board(board, boards), do: [board | boards]
end
