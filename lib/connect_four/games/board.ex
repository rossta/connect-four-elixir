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
    %Board{rows: @rows, cols: @cols, cells: Map.new}
  end

  def drop_checker(%{rows: rows} = board, {col, color}) do
    case open_row(board) do
      row when row >= rows ->
        {:error, :full_column}

      row ->
        %{board | cells: Map.put(board.cells, cell_key(row, col), {row, col, color})}
    end
  end

  def checker(board, {row, col}) do
    case Map.fetch(board.cells, cell_key(row, col)) do
      {:ok, checker} -> checker
      :error -> {row, col, :empty}
    end
  end

  defp open_row(board) do
    row = board.cells
          |> Map.values
          |> Enum.map(fn {row, _, _} -> row end)
          |> Enum.max(fn -> -1 end)

    row + 1
  end

  def cell_key(row, col) do
    "#{row}#{col}"
  end
end
