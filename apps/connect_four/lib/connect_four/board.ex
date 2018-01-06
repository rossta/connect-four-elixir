defmodule ConnectFour.Board do
  alias ConnectFour.Board
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

  def load(encoded) do
    [color, dim | rest] = encoded |> String.split("-")
    color = color |> String.to_atom

    [rows, cols] = dim |> String.split(":") |> Enum.map(&String.to_integer/1)

    moves = rest |> Enum.flat_map(&String.split(&1, ":")) |> Enum.map(&String.to_integer/1)

    load_moves(%{Board.new | rows: rows, cols: cols}, color, moves)
  end

  defp load_moves(board, color, []), do: board
  defp load_moves(board, color, [move | moves]) do
    load_moves(board |> drop_checker({move, color}), ConnectFour.Game.next_color(color), moves)
  end

  def drop_checker(%Board{cols: cols}, {col, _color}) when col < 0 or cols <= col, do: out_of_bounds
  def drop_checker(%Board{} = board, {col, color}) do
    row = open_row(board, col)
    board |> land_checker_in_row({row, col, color})
  end
  defp land_checker_in_row(_board, {:none, _col, _color}), do: {:error, "Column full"}
  defp land_checker_in_row(%{cells: cells} = board, {row, col, _color} = checker) do
    cells = Map.put(cells, cell_key(row, col), checker)
    %{board | cells: cells, last: checker}
  end

  def checker(%Board{rows: rows}, {row, _col}) when row < 0 or rows <= row, do: out_of_bounds
  def checker(%Board{cols: cols}, {_row, col}) when col < 0 or cols <= col, do: out_of_bounds
  def checker(%Board{cells: cells}, {row, col}) do
    case Map.fetch(cells, cell_key(row, col)) do
      {:ok, checker} -> checker
      :error -> {row, col, :empty}
    end
  end

  defp out_of_bounds, do: {:error, "Out of bounds"}

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

defimpl Inspect, for: ConnectFour.Board do
  alias ConnectFour.Board

  def inspect(%Board{} = board, _opts) do
    Board.to_string(board)
  end
end
