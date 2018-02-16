defmodule Joshua.Minimax do
  alias Joshua.{Move, Score}
  alias ConnectFour.{Board, Winner}
  require Logger

  def minimax(%Board{} = board, 0), do: evaluate_board(board)
  def minimax(%Board{} = board, depth), do: minimax(board, depth, Winner.winner(board))
  def minimax(%Board{} = board, _depth, %Winner{}), do: evaluate_board(board)

  def minimax(%Board{} = board, depth, nil) do
    Logger.debug("minimax start (#{depth}) --------------")

    board
    |> Move.child_boards()
    |> evaluate_boards(board, depth)
  end

  defp evaluate_boards([], %Board{} = board, _depth), do: minimax(board, 0)

  defp evaluate_boards(child_boards, _board, depth) do
    results =
      child_boards
      |> Enum.map(fn board ->
        Logger.debug("minimax calculating (#{depth}) --------------")
        {_, score} = minimax(board, depth - 1)
        result = {board.last, score}
        Logger.debug("minimax result (#{depth}):" <> inspect(result))
        result
      end)

    {_, max_score} = results |> Enum.max_by(fn {_, score} -> score end)

    results
    |> Enum.filter(fn {_, score} -> max_score == score end)
    |> Enum.random()
  end

  defp evaluate_board(%Board{last: nil} = board) do
    # starting color irrelevant
    evaluate_board(board, :red)
  end

  defp evaluate_board(%Board{last: {_row, _col, color}} = board) do
    evaluate_board(board, color)
  end

  defp evaluate_board(%Board{last: last} = board, color), do: {last, Score.evaluate(board, color)}
end
