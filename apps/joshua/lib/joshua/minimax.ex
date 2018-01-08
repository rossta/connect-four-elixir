defmodule Joshua.Minimax do
  alias Joshua.Score
  alias ConnectFour.{Board, Game}
  require Logger

  def minimax(%Board{} = board, 0), do: evaluate_board(board)
  def minimax(%Board{} = board, depth) do
    Logger.debug "minimax start (#{depth}) --------------"
    board
    |> collect_boards()
    |> evaluate_boards(board, depth)
  end

  defp evaluate_boards([], %Board{} = board, _depth), do: minimax(board, 0)
  defp evaluate_boards(child_boards, _board, depth) do
    results = child_boards
    |> Enum.map(fn board ->
      Logger.debug "minimax calculating (#{depth}) --------------"
      {_, score} = minimax(board, depth-1)
      result = {board.last, score}
      Logger.debug "minimax result (#{depth}):" <> inspect result
      result
    end)

    {_, max_score} = results |> Enum.max_by(fn {_, score} -> score end)
    results
    |> Enum.filter(fn {_, score} -> max_score == score end)
    |> Enum.random()
  end

  defp evaluate_board(%Board{last: nil} = board) do
    evaluate_board(board, :red) # starting color irrelevant
  end
  defp evaluate_board(%Board{last: {_row, _col, color}} = board) do
    evaluate_board(board, color)
  end
  defp evaluate_board(%Board{last: last} = board, color), do: {last, Score.evaluate(board, color)}

  defp collect_boards(%Board{} = board), do: board |> collect_boards(0..board.cols |> Enum.to_list, [])
  defp collect_boards(%Board{}, [], boards), do: boards
  defp collect_boards(%Board{last: {_row, _col, color}} = board, cols, boards) do
    collect_boards(board, cols, boards, color)
  end
  defp collect_boards(%Board{last: nil} = board, cols, boards) do
    collect_boards(board, cols, boards, :black)
  end
  defp collect_boards(%Board{} = board, [col |cols], boards, opponent) do
    color = Game.next_color(opponent)
    boards = Board.drop_checker(board, {col, color}) |> collect_board(boards)
    collect_boards(board, cols, boards)
  end

  defp collect_board({:error, _}, boards), do: boards
  defp collect_board(board, boards), do: [board | boards]

end
