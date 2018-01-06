defmodule Joshua.Minimax do
  alias ConnectFour.{Board, Game}
  require Logger

  @connect 4
  @offset @connect-1

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

  def evaluate_board(%Board{last: {_row, _col, color} = last} = board) do
    {last, evaluate(board, color)}
  end

  defp collect_boards(%Board{} = board), do: board |> collect_boards(0..board.cols |> Enum.to_list, [])
  defp collect_boards(%Board{}, [], boards), do: boards
  defp collect_boards(%Board{last: {_row, _col, opponent}} = board, [col |cols], boards) do
    color = Game.next_color(opponent)
    boards = Board.drop_checker(board, {col, color}) |> collect_board(boards)
    collect_boards(board, cols, boards)
  end

  defp collect_board({:error, _}, boards), do: boards
  defp collect_board(board, boards), do: [board | boards]

  def evaluate(%Board{} = board, color) do
    opponent = Game.next_color(color)
    evaluate_rows(board, color) - evaluate_rows(board, opponent) +
    evaluate_cols(board, color) - evaluate_cols(board, opponent) +
    evaluate_diagonals_rise(board, color) - evaluate_diagonals_rise(board, opponent) +
    evaluate_diagonals_fall(board, color) - evaluate_diagonals_fall(board, opponent)
  end

  defp evaluate_rows(%Board{rows: rows, cols: cols} = board, color) do
    for row <- 0..rows-1, first <- 0..cols-@connect do
      (for col <- first..first+@offset, do: Board.color(board, {row, col}))
    end
    |> evaluate_combos(color)
  end

  defp evaluate_cols(%Board{rows: rows, cols: cols} = board, color) do
    for col <- 0..cols-1, first <- 0..rows-@connect do
      (for row <- first..first+@offset, do: Board.color(board, {row, col}))
    end
    |> evaluate_combos(color)
  end

  defp evaluate_diagonals_rise(%Board{rows: rows, cols: cols} = board, color) do
    for first_row <- 0..rows-@connect, first_col <- 0..cols-@connect  do
      Enum.zip(first_row..first_row+@offset, first_col..first_col+@offset)
      |> Enum.map(fn {row, col} -> Board.color(board, {row, col}) end)
    end
    |> evaluate_combos(color)
  end

  defp evaluate_diagonals_fall(%Board{rows: rows, cols: cols} = board, color) do
    for first_row <- @offset..rows-1, first_col <- 0..cols-@connect  do
      Enum.zip(first_row..first_row-@offset, first_col..first_col+@offset)
      |> Enum.map(fn {row, col} -> Board.color(board, {row, col}) end)
    end
    |> evaluate_combos(color)
  end

  defp evaluate_combos(color_sets, color) do
    color_sets |> Enum.map(&evaluate_combo(&1, color)) |> Enum.sum()
  end

  def evaluate_combo(colors, color) do
    case Enum.any?(colors, fn c -> c not in [:empty, color] end) do
      false -> 1
      true -> 0
    end
  end
end
