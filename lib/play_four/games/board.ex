defmodule PlayFour.Games.Board do
  @derive [Poison.Encoder]
  alias PlayFour.Games.Board
  require Logger

  @rows 6
  @cols 7

  defstruct [
    rows: nil,
    cols: nil,
    cells: nil,
    last: nil
  ]

  def new() do
    %Board{rows: @rows, cols: @cols, cells: Map.new}
  end

  def drop_checker(%Board{cols: cols}, {col, _color}) when col < 0 or cols <= col,
    do: {:error, :out_of_bounds}
  def drop_checker(%Board{} = board, {col, color}) do
    row = open_row(board, col)
    board |> drop_checker_in_row({row, col, color})
  end
  defp drop_checker_in_row(_board, {:none, _col, _color}), do: {:error, :full_column}
  defp drop_checker_in_row(%{cells: cells} = board, {row, col, color} = checker) do
    cells = Map.put(cells, cell_key(row, col), checker)
    %{board | cells: cells, last: checker}
  end


  def checker(%Board{rows: rows}, {row, _col}) when row < 0 or rows <= row, do: nil
  def checker(%Board{cols: cols}, {_row, col}) when col < 0 or cols <= col, do: nil
  def checker(%Board{cells: cells}, {row, col}) do
    case Map.fetch(cells, cell_key(row, col)) do
      {:ok, checker} -> checker
      :error -> {row, col, :empty}
    end
  end

  def color(board, {row, col}) do
    {_, _, checker_color} = checker(board, {row, col})
    checker_color
  end

  defp open_row(%{rows: rows} = board, col) do
    row = board.cells
          |> Map.values
          |> Enum.filter(fn {_, c, _} -> col == c end)
          |> Enum.map(fn {row, _, _} -> row end)
          |> Enum.max(fn -> -1 end)

    case row do
      row when row+1 >= rows -> :none

      row -> row + 1
    end
  end

  def cell_key(row, col) do
    "#{row}#{col}"
  end

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

  def to_string(%Board{cols: cols, rows: rows} = board) do
    string = for row <- (rows-1)..0 do
      for col <- 0..(cols-1) do
        case Board.color(board, {row, col}) do
          :red -> "R"
          :black -> "B"
          :empty -> "."
        end
      end
      |> Enum.join("")
    end
    |> Enum.join("\n")

    "\n" <> string
  end
end

defimpl Poison.Encoder, for: PlayFour.Games.Board do
  @moduledoc """
  Implements Poison.Encoder for Board
  """
  def encode(%PlayFour.Games.Board{rows: rows, cols: cols, cells: cells}, _options)  do
    cells = for {key, {row, col, color}} <- cells, into: %{} do
      {key, %{row: row, col: col, color: color}}
    end

    Poison.encode!(%{rows: rows, cols: cols, cells: cells})
  end

  def encode(board, _options) do
    raise Poison.EncodeError, value: board
  end
end

defimpl Inspect, for: PlayFour.Games.Board do
  alias PlayFour.Games.Board

  def inspect(%Board{} = board, opts) do
    Board.to_string(board)
  end
end
