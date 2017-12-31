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

  def drop_checker(%Board{cols: cols}, {col, _color}) when col < 0 or cols <= col,
    do: {:error, "Out of bounds"}
  def drop_checker(%Board{} = board, {col, color}) do
    row = open_row(board, col)
    board |> drop_checker_in_row({row, col, color})
  end
  defp drop_checker_in_row(_board, {:none, _col, _color}), do: {:error, "Column full"}
  defp drop_checker_in_row(%{cells: cells} = board, {row, col, _color} = checker) do
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
