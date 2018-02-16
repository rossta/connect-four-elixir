defmodule Joshua.Score do
  alias ConnectFour.{Board, Game}

  @connect 4
  @offset @connect - 1

  require Logger

  def evaluate(%Board{} = board, color) do
    evaluate_all_segments(board, color) - evaluate_all_segments(board, Game.next_color(color))
  end

  def max(%Board{rows: rows, cols: cols}) do
    rows * (cols - @offset) + cols * (rows - @offset) + (rows - @offset) * (cols - @offset) * 2
  end

  defp evaluate_all_segments(board, color) do
    evaluate_rows(board, color) + evaluate_cols(board, color) +
      evaluate_rising_diags(board, color) + evaluate_falling_diags(board, color)
  end

  def evaluate_segment(colors, color) do
    in_a_row_4 = @connect - 0
    in_a_row_3 = @connect - 1
    in_a_row_2 = @connect - 2
    in_a_row_1 = @connect - 3

    case Enum.count(colors, fn c -> c == color || c == :empty end) do
      ^in_a_row_4 -> 1_000_000
      ^in_a_row_3 -> 4
      ^in_a_row_2 -> 1
      ^in_a_row_1 -> 0
      _ -> 0
    end
  end

  defp all_row_segments(%Board{rows: rows, cols: cols} = board) do
    for row <- 0..(rows - 1),
        first <- 0..(cols - @connect) do
      for col <- first..(first + @offset), do: Board.color(board, {row, col})
    end
  end

  defp evaluate_rows(%Board{} = board, color) do
    board
    |> all_row_segments()
    |> evaluate_segments(color)
  end

  defp all_col_segments(%Board{rows: rows, cols: cols} = board) do
    for col <- 0..(cols - 1),
        first <- 0..(rows - @connect) do
      for row <- first..(first + @offset), do: Board.color(board, {row, col})
    end
  end

  defp evaluate_cols(%Board{} = board, color) do
    board
    |> all_col_segments()
    |> evaluate_segments(color)
  end

  def all_rising_diag_segments(%Board{rows: rows, cols: cols} = board) do
    for first_row <- 0..(rows - @connect),
        first_col <- 0..(cols - @connect) do
      Enum.zip(first_row..(first_row + @offset), first_col..(first_col + @offset))
      |> Enum.map(fn {row, col} -> Board.color(board, {row, col}) end)
    end
  end

  defp evaluate_rising_diags(%Board{} = board, color) do
    board
    |> all_rising_diag_segments()
    |> evaluate_segments(color)
  end

  def all_falling_diag_segments(%Board{rows: rows, cols: cols} = board) do
    for first_row <- @offset..(rows - 1),
        first_col <- 0..(cols - @connect) do
      Enum.zip(first_row..(first_row - @offset), first_col..(first_col + @offset))
      |> Enum.map(fn {row, col} -> Board.color(board, {row, col}) end)
    end
  end

  defp evaluate_falling_diags(%Board{} = board, color) do
    board
    |> all_falling_diag_segments()
    |> evaluate_segments(color)
  end

  defp evaluate_segments(color_sets, color) do
    color_sets |> Enum.map(&evaluate_segment(&1, color)) |> Enum.sum()
  end
end
