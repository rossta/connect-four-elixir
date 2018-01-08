defmodule Joshua.Score do
  alias ConnectFour.{Board, Game}

  @connect 4
  @offset @connect-1
  @weight 100

  require Logger

  def evaluate(%Board{} = board, color) do
    evaluate_rows(board, color) +
    evaluate_cols(board, color) +
    evaluate_rising_diags(board, color) +
    evaluate_falling_diags(board, color)
  end

  def max(%Board{rows: rows, cols: cols}) do
    (rows * (cols - @offset)) +
    (cols * (rows - @offset)) +
    ((rows - @offset) * (cols - @offset) * 2)
  end

  def evaluate_combo(colors, color) do
    opponent = Game.next_color(color)
    cond do
      Enum.member?(colors, color) && Enum.member?(colors, opponent) -> 0
      Enum.member?(colors, color) -> weighted_count(Enum.count(colors, fn c -> c == color end))
      true -> weighted_count(Enum.count(colors, fn c -> c != :empty end)) * -1
    end
  end
  def weighted_count(count), do: count * :math.pow(10, count)

  defp all_row_combos(%Board{rows: rows, cols: cols} = board) do
    for row <- 0..rows-1, first <- 0..cols-@connect do
      (for col <- first..first+@offset, do: Board.color(board, {row, col}))
    end
  end

  defp evaluate_rows(%Board{} = board, color) do
    board
    |> all_row_combos()
    |> evaluate_combos(color)
  end

  defp all_col_combos(%Board{rows: rows, cols: cols} = board) do
    for col <- 0..cols-1, first <- 0..rows-@connect do
      (for row <- first..first+@offset, do: Board.color(board, {row, col}))
    end
  end

  defp evaluate_cols(%Board{} = board, color) do
    board
    |> all_col_combos()
    |> evaluate_combos(color)
  end

  def all_rising_diag_combos(%Board{rows: rows, cols: cols} = board) do
    for first_row <- 0..rows-@connect, first_col <- 0..cols-@connect  do
      Enum.zip(first_row..first_row+@offset, first_col..first_col+@offset)
      |> Enum.map(fn {row, col} -> Board.color(board, {row, col}) end)
    end
  end

  defp evaluate_rising_diags(%Board{} = board, color) do
    board
    |> all_rising_diag_combos()
    |> evaluate_combos(color)
  end

  def all_falling_diag_combos(%Board{rows: rows, cols: cols} = board) do
    for first_row <- @offset..rows-1, first_col <- 0..cols-@connect  do
      Enum.zip(first_row..first_row-@offset, first_col..first_col+@offset)
      |> Enum.map(fn {row, col} -> Board.color(board, {row, col}) end)
    end
  end

  defp evaluate_falling_diags(%Board{} = board, color) do
    board
    |> all_falling_diag_combos()
    |> evaluate_combos(color)
  end

  defp evaluate_combos(color_sets, color) do
    color_sets |> Enum.map(&evaluate_combo(&1, color)) |> Enum.sum()
  end
end
