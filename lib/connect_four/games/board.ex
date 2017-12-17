defmodule ConnectFour.Games.Board do
  @derive [Poison.Encoder]
  alias ConnectFour.Games.Board
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
end

defimpl Poison.Encoder, for: ConnectFour.Games.Board do
  @moduledoc """
  Implements Poison.Encoder for Board
  """
  def encode(%ConnectFour.Games.Board{rows: rows, cols: cols, cells: cells}, _options)  do
    cells = for {key, {row, col, color}} <- cells, into: %{} do
      {key, %{row: row, col: col, color: color}}
    end

    Poison.encode!(%{rows: rows, cols: cols, cells: cells})
  end

  def encode(board, _options) do
    raise Poison.EncodeError, value: board
  end
end
