defmodule ConnectFour.Games.Board do
  alias ConnectFour.Games.Board

  @rows 6
  @cols 7

  defstruct [
    rows: nil,
    cols: nil,
    cells: nil
  ]

  def new() do
    %Board{rows: @row, cols: @cols, cells: Map.new}
  end

  def drop_checker(board, {color, col}) do
    row = open_row(board)

    %{board | cells: Map.put(board.cells, cell_key(row, col), {row, color, col})}
  end

  defp open_row(board) do
    board.cells |> Map.values |> Enum.max(fn -> 0 end)
  end

  def cell_key(row, col) do
    "#{row}#{col}"
  end
end
